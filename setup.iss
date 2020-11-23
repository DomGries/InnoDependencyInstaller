// contribute: https://github.com/DomGries/InnoDependencyInstaller
// official article: https://codeproject.com/Articles/20868/Inno-Setup-Dependency-Installer

// comment out product defines to disable installing them
#define InstallMsi45

#define InstallDotNet11
#define InstallDotNet20
#define InstallDotNet35
#define InstallDotNet40Client
#define InstallDotNet40Full
#define InstallDotNet45
#define InstallDotNet46
#define InstallDotNet47
#define InstallDotNet48

// requires netcorecheck.exe and netcorecheck_x64.exe in src dir
#define InstallNetCoreCheck
#define InstallNetCore31
#define InstallNetCore31asp
#define InstallNetCore31desktop
#define InstallDotNet50
#define InstallDotNet50asp
#define InstallDotNet50desktop

#define InstallMsiProduct
#define InstallVC2005
#define InstallVC2008
#define InstallVC2010
#define InstallVC2012
#define InstallVC2013
#define InstallVC2015
#define InstallVC2017
#define InstallVC2019

// requires dxwebsetup.exe in src dir
//#define InstallDirectX

#define InstallSqlCompact35
#define InstallSql2008Express


#define MyAppSetupName 'MyProgram'
#define MyAppVersion '1.0'
#define MyAppPublisher 'DomGries'
#define MyAppCopyright 'Copyright © DomGries'
#define MyAppURL 'https://github.com/DomGries/InnoDependencyInstaller'

[Setup]
AppName={#MyAppSetupName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppSetupName} {#MyAppVersion}
AppCopyright={#MyAppCopyright}
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
OutputBaseFilename={#MyAppSetupName}-{#MyAppVersion}
DefaultGroupName={#MyAppSetupName}
DefaultDirName={autopf}\{#MyAppSetupName}
UninstallDisplayIcon={app}\MyProgram.exe
OutputDir=bin
SourceDir=.
AllowNoIcons=yes

MinVersion=6.0
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64

// dependency installation requires ready page and ready memo to be enabled (default behaviour)
DisableReadyPage=no
DisableReadyMemo=no


// shared code for installing the products
[Code]
// types and variables
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
var
	Names: String;
begin
	Result := RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'PendingFileRenameOperations', Names) or
		(RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'SetupExecute', Names) and (Names <> ''));
end;

function InstallProducts: InstallResult;
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

// Inno Setup event functions
procedure InitializeWizard;
begin
	DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
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
begin
	Result := DelayedReboot;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
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

// architecture helper functions
function IsX64: Boolean;
begin
	Result := not ForceX86 and Is64BitInstallMode;
end;

function GetString(x86, x64: String): String;
begin
	if IsX64 and (x64 <> '') then begin
		Result := x64;
	end else begin
		Result := x86;
	end;
end;

function GetArchitectureSuffix: String;
begin
	if IsX64 then begin
		Result := '_x64';
	end else begin
		Result := '';
	end;
end;

function GetArchitectureTitle: String;
begin
	if IsX64 then begin
		Result := ' (x64)';
	end else begin
		Result := ' (x86)';
	end;
end;

function StringToVersion(var Temp: String): Integer;
var
	Part: String;
	Pos1: Integer;
begin
	if Length(Temp) = 0 then begin
		Result := -1;
		Exit;
	end;

	Pos1 := Pos('.', Temp);
	if Pos1 = 0 then begin
		Result := StrToIntDef(Temp, 0);
		Temp := '';
	end else begin
		Part := Copy(Temp, 1, Pos1 - 1);
		Temp := Copy(Temp, Pos1 + 1, Length(Temp));
		Result := StrToIntDef(Part, 0);
	end;
end;

function CompareInnerVersion(var X, Y: String): Integer;
var
	Num1, Num2: Integer;
begin
	Num1 := StringToVersion(X);
	Num2 := StringToVersion(Y);
	if (Num1 = -1) and (Num2 = -1) then begin
		Result := 0;
		Exit;
	end;

	if Num1 < 0 then begin
		Num1 := 0;
	end;
	if Num2 < 0 then begin
		Num2 := 0;
	end;

	if Num1 < Num2 then begin
		Result := -1;
	end else if Num1 > Num2 then begin
		Result := 1;
	end else begin
		Result := CompareInnerVersion(X, Y);
	end;
end;

function CompareVersion(VersionA, VersionB: String): Integer;
var
	Temp1, Temp2: String;
begin
	Temp1 := VersionA;
	Temp2 := VersionB;
	Result := CompareInnerVersion(Temp1, Temp2);
end;


#ifdef InstallNetCoreCheck
// https://github.com/dotnet/deployment-tools/tree/master/src/clickonce/native/projects/NetCoreCheck
// download netcorecheck.exe: https://go.microsoft.com/fwlink/?linkid=2135256
// download netcorecheck_x64.exe: https://go.microsoft.com/fwlink/?linkid=2135504

[Files]
Source: "src\netcorecheck.exe"; Flags: dontcopy noencryption
Source: "src\netcorecheck_x64.exe"; Flags: dontcopy noencryption

[Code]
function netcoreinstalled(Version: String): Boolean;
var
	ResultCode: Integer;
begin
	if not FileExists(ExpandConstant('{tmp}{\}') + 'netcorecheck' + GetArchitectureSuffix + '.exe') then begin
		ExtractTemporaryFile('netcorecheck' + GetArchitectureSuffix + '.exe');
	end;
	Result := Exec(ExpandConstant('{tmp}{\}') + 'netcorecheck' + GetArchitectureSuffix + '.exe', Version, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;
#endif


#ifdef InstallMsiProduct
type
	INSTALLSTATE = Longint;
const
	INSTALLSTATE_INVALIDARG = -2;	// An invalid parameter was passed to the function.
	INSTALLSTATE_UNKNOWN = -1;		// The product is neither advertised or installed.
	INSTALLSTATE_ADVERTISED = 1;	// The product is advertised but not installed.
	INSTALLSTATE_ABSENT = 2;		// The product is installed for a different user.
	INSTALLSTATE_DEFAULT = 5;		// The product is installed for the current user.

function MsiQueryProductState(Product: String): INSTALLSTATE;
external 'MsiQueryProductStateW@msi.dll stdcall';

function MsiEnumRelatedProducts(UpgradeCode: String; Reserved: DWORD; Index: DWORD; ProductCode: String): Integer;
external 'MsiEnumRelatedProductsW@msi.dll stdcall';

function MsiGetProductInfo(ProductCode: String; PropertyName: String; Value: String; var ValueSize: DWORD): Integer;
external 'MsiGetProductInfoW@msi.dll stdcall';

function MsiProduct(ProductId: String): Boolean;
begin
	Result := MsiQueryProductState(ProductId) = INSTALLSTATE_DEFAULT;
end;

function MsiProductUpgrade(UpgradeCode: String; MinVersion: String): Boolean;
var
	ProductCode, Version: String;
	ValueSize: DWORD;
begin
	SetLength(ProductCode, 39);
	Result := False;

	if MsiEnumRelatedProducts(UpgradeCode, 0, 0, ProductCode) = 0 then begin
		SetLength(Version, 39);
		ValueSize := Length(Version);

		if MsiGetProductInfo(ProductCode, 'VersionString', Version, ValueSize) = 0 then begin
			Result := CompareVersion(Version, MinVersion) >= 0;
		end;
	end;
end;
#endif


#ifdef InstallDirectX
[Files]
Source: "src\dxwebsetup.exe"; Flags: dontcopy noencryption
#endif


// content
[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "pt"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "ja"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"

[Files]
Source: "src\MyProgram-x64.exe"; DestDir: "{app}"; DestName: "MyProgram.exe"; Check: IsX64; Flags: ignoreversion
Source: "src\MyProgram.exe"; DestDir: "{app}"; Check: not IsX64; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppSetupName}"; Filename: "{app}\MyProgram.exe"
Name: "{group}\{cm:UninstallProgram,{#MyAppSetupName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppSetupName}"; Filename: "{app}\MyProgram.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\MyProgram.exe"; Description: "{cm:LaunchProgram,{#MyAppSetupName}}"; Flags: nowait postinstall skipifsilent

[CustomMessages]
DependenciesDir=MyProgramDependencies

[Code]
function InitializeSetup: Boolean;
var
	Version: String;
begin
#ifdef InstallMsi45
	if GetVersionNumbersString(ExpandConstant('{sys}{\}msi.dll'), Version) and (CompareVersion(Version, '4.5') < 0) then begin
		AddProduct('msi45' + GetArchitectureSuffix + '.msu',
			'/quiet /norestart',
			'Windows Installer 4.5',
			GetString('https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x86.msu', 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x64.msu'),
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet11
	// https://www.microsoft.com/downloads/details.aspx?FamilyID=262d25e3-f589-4842-8157-034d1e7cf3a3
	if not IsX64 and not IsDotNetInstalled(net11, 0) then begin
		AddProduct('dotnetfx11.exe',
			'/q:a /c:"install /qb /l"',
			'.NET Framework 1.1',
			'https://download.microsoft.com/download/a/a/c/aac39226-8825-44ce-90e3-bf8203e74006/dotnetfx.exe',
			'', False, False, False);
	end;

	// https://www.microsoft.com/downloads/details.aspx?familyid=A8F5654F-088E-40B2-BBDB-A83353618B38
	if not IsX64 and not IsDotNetInstalled(net11, 1) then begin
		AddProduct('dotnetfx11sp1.exe',
			'/q',
			'.NET Framework 1.1 Service Pack 1',
			'https://download.microsoft.com/download/8/b/4/8b4addd8-e957-4dea-bdb8-c4e00af5b94b/NDP1.1sp1-KB867460-X86.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet20
	// https://www.microsoft.com/downloads/details.aspx?familyid=5B2C0358-915B-4EB5-9B1D-10E506DA9D0F
	if not IsDotNetInstalled(net20, 0) then begin
		AddProduct('dotnetfx20' + GetArchitectureSuffix + '.exe',
			'/passive /norestart /lang:ENU',
			'.NET Framework 2.0',
			GetString('https://download.microsoft.com/download/c/6/e/c6e88215-0178-4c6c-b5f3-158ff77b1f38/NetFx20SP2_x86.exe', 'https://download.microsoft.com/download/c/6/e/c6e88215-0178-4c6c-b5f3-158ff77b1f38/NetFx20SP2_x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet35
	// https://www.microsoft.com/downloads/details.aspx?FamilyID=ab99342f-5d1a-413d-8319-81da479ab0d7
	if not IsDotNetInstalled(net35, 0) then begin
		AddProduct('dotnetfx35.exe',
			'/lang:enu /passive /norestart',
			'.NET Framework 3.5',
			'https://download.microsoft.com/download/0/6/1/061f001c-8752-4600-a198-53214c69b51f/dotnetfx35setup.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet40Client
	// https://www.microsoft.com/downloads/en/details.aspx?FamilyID=5765d7a8-7722-4888-a970-ac39b33fd8ab
	if not IsDotNetInstalled(net4client, 0) and not IsDotNetInstalled(net4full, 0) then begin
		AddProduct('dotNetFx40_Client_setup.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.0',
			'https://download.microsoft.com/download/7/B/6/7B629E05-399A-4A92-B5BC-484C74B5124B/dotNetFx40_Client_setup.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet40Full
	// https://www.microsoft.com/downloads/en/details.aspx?FamilyID=9cfb2d51-5ff4-4491-b0e5-b386f32c0992
	if not IsDotNetInstalled(net4full, 0) then begin
		AddProduct('dotNetFx40_Full_setup.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.0',
			'https://download.microsoft.com/download/1/B/E/1BE39E79-7E39-46A3-96FF-047F95396215/dotNetFx40_Full_setup.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet45
	// https://www.microsoft.com/en-us/download/details.aspx?id=42642
	if not IsDotNetInstalled(net45, 0) then begin
		AddProduct('dotnetfx45.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.5.2',
			'https://download.microsoft.com/download/B/4/1/B4119C11-0423-477B-80EE-7A474314B347/NDP452-KB2901954-Web.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet46
	// https://www.microsoft.com/en-US/download/details.aspx?id=53345
	if not IsDotNetInstalled(net46, 0) then begin
		AddProduct('dotnetfx46.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.6.2',
			'https://download.microsoft.com/download/D/5/C/D5C98AB0-35CC-45D9-9BA5-B18256BA2AE6/NDP462-KB3151802-Web.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet47
	// https://support.microsoft.com/en-us/help/4054531
	if not IsDotNetInstalled(net47, 0) then begin
		AddProduct('dotnetfx47.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.7.2',
			'https://download.microsoft.com/download/0/5/C/05C1EC0E-D5EE-463B-BFE3-9311376A6809/NDP472-KB4054531-Web.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet48
	// https://dotnet.microsoft.com/download/dotnet-framework/net48
	if not IsDotNetInstalled(net48, 0) then begin
		AddProduct('dotnetfx48.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.8',
			'https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/c9b8749dd99fc0d4453b2a3e4c37ba16/ndp48-web.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallNetCore31
	// https://dotnet.microsoft.com/download/dotnet-core/3.1
	if not netcoreinstalled('Microsoft.NETCore.App 3.1.0') then begin
		AddProduct('netcore31' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Core Runtime 3.1.10' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/abb3fb5d-4e82-4ca8-bc03-ac13e988e608/b34036773a72b30c5dc5520ee6a2768f/dotnet-runtime-3.1.10-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/9845b4b0-fb52-48b6-83cf-4c431558c29b/41025de7a76639eeff102410e7015214/dotnet-runtime-3.1.10-win-x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallNetCore31asp
	// https://dotnet.microsoft.com/download/dotnet-core/3.1
	if not netcoreinstalled('Microsoft.AspNetCore.App 3.1.0') then begin
		AddProduct('netcore31asp' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'ASP.NET Core Runtime 3.1.10' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/c0a1f953-81d3-4a1a-a584-a627b518c434/16e1af0d3ebe6edacde1eab155dd4d90/aspnetcore-runtime-3.1.10-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/c1ea0601-abe4-4c6d-96ed-131764bf5129/a1823d8ff605c30af412776e2e617a36/aspnetcore-runtime-3.1.10-win-x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallNetCore31desktop
	// https://dotnet.microsoft.com/download/dotnet-core/3.1
	if not netcoreinstalled('Microsoft.WindowsDesktop.App 3.1.0') then begin
		AddProduct('netcore31desktop' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Desktop Runtime 3.1.10' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/865d0be5-16e2-4b3d-a990-f4c45acd280c/ec867d0a4793c0b180bae85bc3a4f329/windowsdesktop-runtime-3.1.10-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/513acf37-8da2-497d-bdaa-84d6e33c1fee/eb7b010350df712c752f4ec4b615f89d/windowsdesktop-runtime-3.1.10-win-x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet50
	// https://dotnet.microsoft.com/download/dotnet/5.0
	if not netcoreinstalled('Microsoft.NETCore.App 5.0.0') then begin
		AddProduct('dotnet50' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Runtime 5.0' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/a7e15da3-7a15-43c2-a481-cf50bf305214/c69b951e8b47101e90b1289c387bb01a/dotnet-runtime-5.0.0-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/36a9dc4e-1745-4f17-8a9c-f547a12e3764/ae25e38f20a4854d5e015a88659a22f9/dotnet-runtime-5.0.0-win-x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet50asp
	// https://dotnet.microsoft.com/download/dotnet/5.0
	if not netcoreinstalled('Microsoft.AspNetCore.App 5.0.0') then begin
		AddProduct('dotnet50asp' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'ASP.NET Core Runtime 5.0' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/115edeeb-c883-45be-90f7-8db7b6b3fa2f/6bf92152b2b9fa9c0d0b08a13b60e525/aspnetcore-runtime-5.0.0-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/92866d29-a298-4cab-b501-a65e43820f97/88d287b9fb4a12cfcdf4a6be85f4a638/aspnetcore-runtime-5.0.0-win-x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallDotNet50desktop
	// https://dotnet.microsoft.com/download/dotnet/5.0
	if not netcoreinstalled('Microsoft.WindowsDesktop.App 5.0.0') then begin
		AddProduct('dotnet50desktop' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Desktop Runtime 5.0' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/b2780d75-e54a-448a-95fc-da9721b2b4c2/62310a9e9f0ba7b18741944cbae9f592/windowsdesktop-runtime-5.0.0-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/1b3a8899-127a-4465-a3c2-7ce5e4feb07b/1e153ad470768baa40ed3f57e6e7a9d8/windowsdesktop-runtime-5.0.0-win-x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallVC2005
	// https://www.microsoft.com/en-us/download/details.aspx?id=3387
	if not MsiProductUpgrade(GetString('{86C9D5AA-F00C-4921-B3F2-C60AF92E2844}', '{A8D19029-8E5C-4E22-8011-48070F9E796E}'), '6') then begin
		AddProduct('vcredist2005' + GetArchitectureSuffix + '.exe',
			'/q:a /c:"install /qb /l',
			'Visual C++ 2005 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE', 'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE'),
			'', False, False, False);
	end;
#endif

#ifdef InstallVC2008
	// https://www.microsoft.com/en-us/download/details.aspx?id=29
	if not MsiProductUpgrade(GetString('{DE2C306F-A067-38EF-B86C-03DE4B0312F9}', '{FDA45DDF-8E17-336F-A3ED-356B7B7C688A}'), '9') and not MsiProductUpgrade('{AA783A14-A7A3-3D33-95F0-9A351D530011}', '9') then begin
		AddProduct('vcredist2008' + GetArchitectureSuffix + '.exe',
			'/q',
			'Visual C++ 2008 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe', 'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallVC2010
	// https://www.microsoft.com/en-us/download/details.aspx?id=5555
	if not MsiProductUpgrade(GetString('{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}', '{5B75F761-BAC8-33BC-A381-464DDDD813A3}'), '10') then begin
		AddProduct('vcredist2010' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2010 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallVC2012
	// https://www.microsoft.com/en-us/download/details.aspx?id=30679
	if not MsiProductUpgrade(GetString('{4121ED58-4BD9-3E7B-A8B5-9F8BAAE045B7}', '{EFA6AFA1-738E-3E00-8101-FD03B86B29D1}'), '11') then begin
		AddProduct('vcredist2012' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2012 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallVC2013
	//ForceX86 := True; // force 32-bit install of next products
	// https://www.microsoft.com/en-us/download/details.aspx?id=40784
	if not MsiProductUpgrade(GetString('{B59F5BF1-67C8-3802-8E59-2CE551A39FC5}', '{20400CF0-DE7C-327E-9AE4-F0F38D9085F8}'), '12') then begin
		AddProduct('vcredist2013' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2013 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe', 'https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe'),
			'', False, False, False);
	end;
	//ForceX86 := False; // disable forced 32-bit install again
#endif

#ifdef InstallVC2015
	// https://www.microsoft.com/en-us/download/details.aspx?id=48145
	if not MsiProductUpgrade(GetString('{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}'), '14') then begin
		AddProduct('vcredist2015' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2015 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/d/e/c/dec58546-c2f5-40a7-b38e-4df8d60b9764/vc_redist.x86.exe', 'https://download.microsoft.com/download/2/c/6/2c675af0-2155-4961-b32e-289d7addfcec/vc_redist.x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallVC2017
	// https://www.visualstudio.com/en-us/downloads/
	if not MsiProductUpgrade(GetString('{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}'), '14.10') then begin
		AddProduct('vcredist2017' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2017 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/1/f/e/1febbdb2-aded-4e14-9063-39fb17e88444/vc_redist.x86.exe', 'https://download.microsoft.com/download/3/b/f/3bf6e759-c555-4595-8973-86b7b4312927/vc_redist.x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallVC2019
	// https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads
	if not MsiProductUpgrade(GetString('{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}'), '14.20') then begin
		AddProduct('vcredist2019' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2015-2019 Redistributable' + GetArchitectureTitle,
			GetString('https://aka.ms/vs/16/release/vc_redist.x86.exe', 'https://aka.ms/vs/16/release/vc_redist.x64.exe'),
			'', False, False, False);
	end;
#endif

#ifdef InstallDirectX
	// https://www.microsoft.com/en-US/download/details.aspx?id=35
	ExtractTemporaryFile('dxwebsetup.exe');
	AddProduct('dxwebsetup.exe',
		'/Q',
		'DirectX Runtime',
		'https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe',
		'', True, False, False);
#endif

#ifdef InstallSqlCompact35
	if not IsX64 and not RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server Compact Edition\v3.5') then begin
		AddProduct('sqlcompact35sp2.msi',
			'/qb',
			'SQL Server Compact 3.5',
			'https://download.microsoft.com/download/E/C/1/EC1B2340-67A0-4B87-85F0-74D987A27160/SSCERuntime-ENU.exe',
			'', False, False, False);
	end;
#endif

#ifdef InstallSql2008Express
	if (not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\SQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (CompareVersion(Version, '10.5') < 0)) and
		(not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\SQLEXPRESS\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (CompareVersion(Version, '10.5') < 0)) then begin
		AddProduct('sql2008express' + GetArchitectureSuffix + '.exe',
			'/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=Install /FEATURES=All /INSTANCENAME=SQLEXPRESS /SQLSVCACCOUNT="NT AUTHORITY\Network Service" /SQLSYSADMINACCOUNTS="builtin\administrators"',
			'SQL Server 2008 Express',
			GetString('https://download.microsoft.com/download/5/1/A/51A153F6-6B08-4F94-A7B2-BA1AD482BC75/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/5/1/A/51A153F6-6B08-4F94-A7B2-BA1AD482BC75/SQLEXPR_x64_ENU.exe'),
			'', False, False, False);
	end;
#endif

	Result := True;
end;
