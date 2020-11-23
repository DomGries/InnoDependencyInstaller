{
	--- TYPES AND VARIABLES ---
}
type
	TProduct = record
		URL: String;
		Filename: String;
		Checksum: String;
		Path: String;
		Title: String;
		Parameters: String;
		ForceSuccess: Boolean;
		InstallClean: Boolean;
		RebootAfter: Boolean;
	end;

	InstallResult = (InstallSuccessful, InstallRebootRequired, InstallError);

var
	MemoInstallInfo: String;
	Products: array of TProduct;
	DelayedReboot, ForceX86: Boolean;
	DownloadPage: TDownloadWizardPage;

procedure AddProduct(Filename, Parameters, Title, URL, Checksum: String; ForceSuccess, InstallClean, RebootAfter: Boolean);
{
	Adds a product to the list of products to download.
	Parameters:
		Filename: the file name under which to save the file
		Parameters: the Parameters with which to run the file
		Title: the product title
		URL: the URL to download from
		ForceSuccess: whether to continue in case of setup failure
		InstallClean: whether the product needs a reboot before installing
		RebootAfter: whether the product needs a reboot after installing
}
var
	Product: TProduct;
	I: Integer;
begin
	MemoInstallInfo := MemoInstallInfo + #13 + '%1' + Title;

	Product.URL := '';
	Product.Filename := '';
	Product.Checksum := Checksum;
	Product.Title := Title;
	Product.Parameters := Parameters;
	Product.ForceSuccess := ForceSuccess;
	Product.InstallClean := InstallClean;
	Product.RebootAfter := RebootAfter;

	try
		Product.Path := CustomMessage('DependenciesDir');
	except
		// catch exception on undefined custom message
		Product.Path := '';
	end;

	if (Product.Path = '') or not FileExists(ExpandConstant('{src}{\}') + Product.Path + '\' + Filename) then begin
		Product.Path := ExpandConstant('{tmp}{\}') + Filename;

		if not FileExists(Product.Path) then begin
			Product.URL := URL;
			Product.Filename := Filename;
		end;
	end else begin
		Product.Path := ExpandConstant('{src}{\}') + Product.Path + '\' + Filename;
	end;

	I := GetArrayLength(Products);
	SetArrayLength(Products, I + 1);
	Products[I] := Product;
end;

function PendingReboot: Boolean;
{
	Checks whether the machine has a pending reboot.
}
var
	Names: String;
begin
	Result := RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'PendingFileRenameOperations', Names) or
		(RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'SetupExecute', Names) and (Names <> ''));
end;

function InstallProducts: InstallResult;
{
	Installs the downloaded products
}
var
	ResultCode, I, ProductCount, FinishCount: Integer;
begin
	Result := InstallSuccessful;
	ProductCount := GetArrayLength(Products);

	if ProductCount > 0 then begin
		for I := 0 to ProductCount - 1 do begin
			if Products[I].InstallClean and (DelayedReboot or PendingReboot) then begin
				Result := InstallRebootRequired;
				break;
			end;

			DownloadPage.Show;
			DownloadPage.SetText(Products[I].Title, '');
			DownloadPage.SetProgress(I + 1, ProductCount);

			while True do begin
				// set 0 as used code for shown error if ShellExec fails
				ResultCode := 0;
				if ShellExec('', Products[I].Path, Products[I].Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then begin
					// setup executed; ResultCode contains the exit code
					if Products[I].RebootAfter then begin
						// delay reboot after install if we installed the last dependency anyways
						if I = ProductCount - 1 then begin
							DelayedReboot := True;
						end else begin
							Result := InstallRebootRequired;
						end;
						break;
					end else if (ResultCode = 0) or Products[I].ForceSuccess then begin
						FinishCount := FinishCount + 1;
						break;
					end else if ResultCode = 3010 then begin
						// Windows Installer ResultCode 3010: ERROR_SUCCESS_REBOOT_REQUIRED
						DelayedReboot := True;
						FinishCount := FinishCount + 1;
						break;
					end;
				end;

				case SuppressibleMsgBox(FmtMessage(SetupMessage(msgErrorFunctionFailed), [Products[I].Title, IntToStr(ResultCode)]), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
					IDABORT: begin
						Result := InstallError;
						break;
					end;
					IDIGNORE: begin
						break;
					end;
				end;
			end;

			if Result <> InstallSuccessful then begin
				break;
			end;
		end;

		// only leave not installed products for error message
		for I := 0 to ProductCount - FinishCount - 1 do begin
			Products[I] := Products[I + FinishCount];
		end;
		SetArrayLength(Products, ProductCount - FinishCount);

		DownloadPage.Hide;
	end;
end;

{
	--------------------
	INNO EVENT FUNCTIONS
	--------------------
}

procedure InitializeWizard;
begin
	DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
{
	Before the "preparing to install" page.
	See: https://www.jrsoftware.org/ishelp/index.php?topic=scriptevents
}
var
	I: Integer;
begin
	DelayedReboot := False;

	case InstallProducts of
		InstallError: begin
			Result := SetupMessage(msgReadyMemoTasks);

			for I := 0 to GetArrayLength(Products) - 1 do begin
				Result := Result + #13 + '	' + Products[I].Title;
			end;
		end;
		InstallRebootRequired: begin
			Result := Products[0].Title;
			NeedsRestart := True;

			// write into the registry that the installer needs to be executed again after restart
			RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', 'InstallBootstrap', ExpandConstant('{srcexe}'));
		end;
	end;
end;

function NeedRestart: Boolean;
{
	Checks whether a restart is needed at the end of install
	See: https://www.jrsoftware.org/ishelp/index.php?topic=scriptevents
}
begin
	Result := DelayedReboot;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
{
	Just before the "ready" page.
	See: https://www.jrsoftware.org/ishelp/index.php?topic=scriptevents
}
begin
	Result := '';
	if MemoUserInfoInfo <> '' then begin
		Result := Result + MemoUserInfoInfo + Newline + NewLine;
	end;
	if MemoDirInfo <> '' then begin
		Result := Result + MemoDirInfo + Newline + NewLine;
	end;
	if MemoTypeInfo <> '' then begin
		Result := Result + MemoTypeInfo + Newline + NewLine;
	end;
	if MemoComponentsInfo <> '' then begin
		Result := Result + MemoComponentsInfo + Newline + NewLine;
	end;
	if MemoGroupInfo <> '' then begin
		Result := Result + MemoGroupInfo + Newline + NewLine;
	end;
	if MemoTasksInfo <> '' then begin
		Result := Result + MemoTasksInfo;
	end;

	if MemoInstallInfo <> '' then begin
		if MemoTasksInfo = '' then begin
			Result := Result + SetupMessage(msgReadyMemoTasks);
		end;
		Result := Result + FmtMessage(MemoInstallInfo, [Space]);
	end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
{
	At each "next" button click
	See: https://www.jrsoftware.org/ishelp/index.php?topic=scriptevents
}
var
	Retry: Boolean;
	I, ProductCount: Integer;
begin
	Result := True;

	if (CurPageID = wpReady) and (MemoInstallInfo <> '') then begin
		DownloadPage.Show;

		ProductCount := GetArrayLength(Products);
		for I := 0 to ProductCount - 1 do begin
			if Products[I].URL <> '' then begin
				DownloadPage.Clear;
				DownloadPage.Add(Products[I].URL, Products[I].Filename, Products[I].Checksum);

				Retry := True;
				while Retry do begin
					Retry := False;

					try
						DownloadPage.Download;
					except
						if GetExceptionMessage = SetupMessage(msgErrorDownloadAborted) then begin
							Result := False;
							I := ProductCount;
						end else begin
							case SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
								IDABORT: begin
									Result := False;
									I := ProductCount;
								end;
								IDRETRY: begin
									Retry := True;
								end;
							end;
						end;
					end;
				end;
			end;
		end;

		DownloadPage.Hide;
	end;
end;

{
	-----------------------------
	ARCHITECTURE HELPER FUNCTIONS
	-----------------------------
}

function IsX64: Boolean;
{
	Gets whether the computer is x64 (64 bits).
}
begin
	Result := not ForceX86 and Is64BitInstallMode;
end;

function GetString(x86, x64: String): String;
{
	Gets a string depending on the computer architecture.
	Parameters:
		x86: the string if the computer is x86
		x64: the string if the computer is x64
}
begin
	if IsX64 and (x64 <> '') then begin
		Result := x64;
	end else begin
		Result := x86;
	end;
end;

function GetArchitectureSuffix: String;
{
	Gets the architecture suffix string.
}
begin
	if IsX64 then begin
		Result := '_x64';
	end else begin
		Result := '';
	end;
end;

function GetArchitectureTitle: String;
{
	Gets the architecture title string.
}
begin
	if IsX64 then begin
		Result := ' (x64)';
	end else begin
		Result := ' (x86)';
	end;
end;

procedure SetForceX86(value: Boolean);
{
	Forces the setup to use x86 products
}
begin
	ForceX86 := value;
end;
