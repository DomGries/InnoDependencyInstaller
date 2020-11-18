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
		MustRebootAfter: Boolean;
	end;

	InstallResult = (InstallSuccessful, InstallRebootRequired, InstallError);

var
	installMemo, downloadMemo: String;
	products: array of TProduct;
	delayedReboot, isForcedX86: Boolean;
	DownloadPage: TDownloadWizardPage;

procedure AddProduct(filename, parameters, title, size, url, checksum: String; forceSuccess, installClean, mustRebootAfter: Boolean);
{
	Adds a product to the list of products to download.
	Parameters:
		filename: the file name under which to save the file
		parameters: the parameters with which to run the file
		title: the product title
		size: the file size
		url: the URL to download from
		forceSuccess: whether to continue in case of setup failure
		installClean: whether the product needs a reboot before installing
		mustRebootAfter: whether the product needs a reboot after installing
}
var
	product: TProduct;
	i: Integer;
begin
	product.URL := '';
	product.Filename := '';
	product.Checksum := checksum;
	product.Title := title;
	product.Parameters := parameters;
	product.ForceSuccess := forceSuccess;
	product.InstallClean := installClean;
	product.MustRebootAfter := mustRebootAfter;

	try
		product.Path := CustomMessage('DependenciesDir');
	except
		// catch exception on undefined custom message
		product.Path := '';
	end;

	if (product.Path = '') or not FileExists(ExpandConstant('{src}{\}') + product.Path + '\' + filename) then begin
		product.Path := ExpandConstant('{tmp}{\}') + filename;

		if not FileExists(product.Path) then begin
			product.URL := url;
			product.Filename := filename;

			downloadMemo := downloadMemo + '%1' + title + ' (' + size + ')' + #13;
		end else begin
			installMemo := installMemo + '%1' + title + #13;
		end;
	end else begin
		product.Path := ExpandConstant('{src}{\}') + product.Path + '\' + filename;
		installMemo := installMemo + '%1' + title + #13;
	end;

	i := GetArrayLength(products);
	SetArrayLength(products, i + 1);
	products[i] := product;
end;

function PendingReboot: Boolean;
{
	Checks whether the machine has a pending reboot.
}
var
	names: String;
begin
	Result := RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'PendingFileRenameOperations', names) or
		(RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'SetupExecute', names) and (names <> ''));
end;

function InstallProducts: InstallResult;
{
	Installs the downloaded products
}
var
	resultCode, i, productCount, finishCount: Integer;
begin
	Result := InstallSuccessful;
	productCount := GetArrayLength(products);

	if productCount > 0 then begin
		for i := 0 to productCount - 1 do begin
			if products[i].InstallClean and (delayedReboot or PendingReboot()) then begin
				Result := InstallRebootRequired;
				break;
			end;

			DownloadPage.Show;
			DownloadPage.SetText(FmtMessage(CustomMessage('depinstall_status'), [products[i].Title]), '');
			DownloadPage.SetProgress(i + 1, productCount);

			while True do begin
				// set 0 as used code for shown error if ShellExec fails
				resultCode := 0;
				if ShellExec('', products[i].Path, products[i].Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, resultCode) then begin
					// setup executed; resultCode contains the exit code
					if products[i].MustRebootAfter then begin
						// delay reboot after install if we installed the last dependency anyways
						if i = productCount - 1 then begin
							delayedReboot := True;
						end else begin
							Result := InstallRebootRequired;
						end;
						break;
					end else if (resultCode = 0) or products[i].ForceSuccess then begin
						finishCount := finishCount + 1;
						break;
					end else if resultCode = 3010 then begin
						// Windows Installer resultCode 3010: ERROR_SUCCESS_REBOOT_REQUIRED
						delayedReboot := True;
						finishCount := finishCount + 1;
						break;
					end;
				end;

				case SuppressibleMsgBox(FmtMessage(SetupMessage(msgErrorFunctionFailed), [products[i].Title, IntToStr(resultCode)]), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
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
		for i := 0 to productCount - finishCount - 1 do begin
			products[i] := products[i + finishCount];
		end;
		SetArrayLength(products, productCount - finishCount);

		DownloadPage.Hide;
	end;
end;

{
	--------------------
	INNO EVENT FUNCTIONS
	--------------------
}

procedure InitializeWizard();
begin
	DownloadPage := CreateDownloadPage(CustomMessage('depinstall_title'), CustomMessage('depinstall_description'), nil);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
{
	Before the "preparing to install" page.
	See: https://www.jrsoftware.org/ishelp/index.php?topic=scriptevents
}
var
	i: Integer;
	s: String;
begin
	delayedReboot := False;

	case InstallProducts() of
		InstallError: begin
			s := CustomMessage('depinstall_error');

			for i := 0 to GetArrayLength(products) - 1 do begin
				s := s + #13 + '	' + products[i].Title;
			end;

			Result := s;
		end;
		InstallRebootRequired: begin
			Result := products[0].Title;
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
	Result := delayedReboot;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
{
	Just before the "ready" page.
	See: https://www.jrsoftware.org/ishelp/index.php?topic=scriptevents
}
begin
	Result := ''

	if downloadMemo <> '' then begin
		Result := Result + CustomMessage('depdownload_memo_title') + ':' + NewLine + FmtMessage(downloadMemo, [Space]) + NewLine;
	end;
	if installMemo <> '' then begin
		Result := Result + CustomMessage('depinstall_memo_title') + ':' + NewLine + FmtMessage(installMemo, [Space]) + NewLine;
	end;

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
		Result := Result + MemoTasksInfo + Newline + NewLine;
	end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
{
	At each "next" button click
	See: https://www.jrsoftware.org/ishelp/index.php?topic=scriptevents
}
var
	retry: Boolean;
	i, productCount: Integer;
begin
	Result := True;

	if (CurPageID = wpReady) and (downloadMemo <> '') then begin
		DownloadPage.Clear;
		productCount := GetArrayLength(products);
		for i := 0 to productCount - 1 do begin
			if products[i].URL <> '' then begin
				DownloadPage.Add(products[i].URL, products[i].Filename, products[i].Checksum);
			end;
		end;

		DownloadPage.Show;
		retry := True;
		while retry do begin
			retry := False;
			try
				DownloadPage.Download;
			except
				if GetExceptionMessage = SetupMessage(msgErrorDownloadAborted) then begin
					Result := False;
				end else begin
					case SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
						IDABORT: begin
							Result := False;
						end;
						IDRETRY: begin
							retry := True;
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

function IsX86: Boolean;
{
	Gets whether the computer is x86 (32 bits).
}
begin
	Result := isForcedX86 or (ProcessorArchitecture = paX86) or (ProcessorArchitecture = paUnknown);
end;

function IsX64: Boolean;
{
	Gets whether the computer is x64 (64 bits).
}
begin
	Result := not isForcedX86 and Is64BitInstallMode and (ProcessorArchitecture = paX64);
end;

function IsIA64: Boolean;
{
	Gets whether the computer is IA64 (Itanium 64 bits).
}
begin
	Result := not isForcedX86 and Is64BitInstallMode and (ProcessorArchitecture = paIA64);
end;

function GetString(x86, x64, ia64: String): String;
{
	Gets a string depending on the computer architecture.
	Parameters:
		x86: the string if the computer is x86
		x64: the string if the computer is x64
		ia64: the string if the computer is IA64
}
begin
	if IsX64() and (x64 <> '') then begin
		Result := x64;
	end else if IsIA64() and (ia64 <> '') then begin
		Result := ia64;
	end else begin
		Result := x86;
	end;
end;

function GetArchitectureString(): String;
{
	Gets the "standard" architecture suffix string.
	Returns either _x64, _ia64 or nothing.
}
begin
	if IsX64() then begin
		Result := '_x64';
	end else if IsIA64() then begin
		Result := '_ia64';
	end else begin
		Result := '';
	end;
end;

procedure SetForceX86(value: Boolean);
{
	Forces the setup to use X86 products
}
begin
	isForcedX86 := value;
end;
