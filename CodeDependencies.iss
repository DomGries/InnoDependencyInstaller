#if Ver < EncodeVer(6,7,0)
  #error Inno Setup 6.7 or newer is required
#endif
#ifndef Dependency_DownloadRetryCount
  #define Dependency_DownloadRetryCount 3
#endif
#ifndef Dependency_DownloadRetryBackoffMs
  #define Dependency_DownloadRetryBackoffMs 2000
#endif
#ifndef Dependency_InstallBusyRetryCount
  #define Dependency_InstallBusyRetryCount 30
#endif
#ifndef Dependency_InstallBusyRetryDelayMs
  #define Dependency_InstallBusyRetryDelayMs 10000
#endif

[Code]
// https://github.com/DomGries/InnoDependencyInstaller

type
  TDependency_Entry = record
    Filename: String;
    Parameters: String;
    Title: String;
    URL: String;
    Checksum: String;
    ForceSuccess: Boolean;
    RestartAfter: Boolean;
    Components: String;
    SkipInstall: Boolean;
  end;

var
  Dependency_List: array of TDependency_Entry;
  Dependency_NeedToRestart, Dependency_ForceX86, Dependency_ForceX64: Boolean;
  Dependency_Components: String;
  Dependency_DownloadPage: TDownloadWizardPage;

function Dependency_IsEntryActive(const Entry: TDependency_Entry): Boolean;
begin
  Result := (Entry.Components = '') or WizardIsComponentSelected(Entry.Components);
end;

// a file name is downloaded to and run from {tmp}, a full path is run where it is
function Dependency_FilePath(const Filename: String): String;
begin
  if PathIsRooted(Filename) then begin
    Result := Filename;
  end else begin
    Result := ExpandConstant('{tmp}{\}') + Filename;
  end;
end;

procedure Dependency_Add(const Filename, Parameters, Title, URL, Checksum: String; const ForceSuccess, RestartAfter: Boolean);
var
  Dependency: TDependency_Entry;
  DependencyCount: Integer;
begin
  Dependency.Filename := Filename;
  Dependency.Parameters := Parameters;
  Dependency.Title := Title;

  if FileExists(Dependency_FilePath(Filename)) then begin
    Dependency.URL := '';
    Log('Dependency queued (already present): ' + Title);
  end else if URL = '' then begin
    Log('Dependency not available for this architecture: ' + Title);
    exit;
  end else begin
    Dependency.URL := URL;
    Log('Dependency queued for download: ' + Title + ' (' + Filename + ')');
  end;

  Dependency.Checksum := Checksum;
  Dependency.ForceSuccess := ForceSuccess;
  Dependency.RestartAfter := RestartAfter;
  Dependency.Components := Dependency_Components;
  Dependency.SkipInstall := False;

  DependencyCount := GetArrayLength(Dependency_List);
  SetArrayLength(Dependency_List, DependencyCount + 1);
  Dependency_List[DependencyCount] := Dependency;
end;

procedure Dependency_AddIfMissing(const Missing: Boolean; const Filename, Parameters, Title, URL, Checksum: String; const ForceSuccess, RestartAfter: Boolean);
begin
  if Missing then begin
    Dependency_Add(Filename, Parameters, Title, URL, Checksum, ForceSuccess, RestartAfter);
  end else begin
    Log('Dependency already installed: ' + Title);
  end;
end;

<event('InitializeWizard')>
procedure Dependency_InitializeWizard;
begin
  Dependency_DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

// Sleep alone would freeze the wizard
procedure Dependency_Wait(const Title, Reason: String; const Milliseconds: Integer);
var
  Step: Integer;
begin
  for Step := 1 to Milliseconds div 100 do begin
    Dependency_DownloadPage.SetText(Title, Reason);
    Sleep(100);
  end;
end;

function Dependency_Download(const Index: Integer): Boolean;
var
  Attempt: Integer;
  Retry: Boolean;
begin
  Result := True;
  Dependency_DownloadPage.Clear;
  Dependency_DownloadPage.Add(Dependency_List[Index].URL, Dependency_List[Index].Filename, Dependency_List[Index].Checksum);
  Dependency_DownloadPage.SetText(Dependency_List[Index].Title, '');

  // break inside try does not leave the loop in Pascal Script, so loop on a flag
  Attempt := 0;
  Retry := True;
  while Retry do begin
    Retry := False;
    try
      Dependency_DownloadPage.Download;
    except
      if Dependency_DownloadPage.AbortedByUser then begin
        Log('Download aborted by user: ' + Dependency_List[Index].Title);
        Result := False;
      end else begin
        Log('Download failed: ' + Dependency_List[Index].Title + ': ' + GetExceptionMessage);
        Attempt := Attempt + 1;
        if Attempt <= {#Dependency_DownloadRetryCount} then begin
          Log('Retrying download (attempt ' + IntToStr(Attempt) + ' of ' + IntToStr({#Dependency_DownloadRetryCount}) + '): ' + Dependency_List[Index].Title);
          Dependency_Wait(Dependency_List[Index].Title, GetExceptionMessage, Attempt * {#Dependency_DownloadRetryBackoffMs});
          Retry := True;
        end else begin
          case SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbError, MB_ABORTRETRYIGNORE, IDABORT) of
            IDABORT: begin
              Result := False;
            end;
            IDRETRY: begin
              Attempt := 0;
              Retry := True;
            end;
            IDIGNORE: begin
              Dependency_List[Index].SkipInstall := True;
              Log('Dependency skipped after failed download: ' + Dependency_List[Index].Title);
            end;
          end;
        end;
      end;
    end;
  end;
end;

function Dependency_Install(const Index: Integer; const IsLast: Boolean; var NeedsRestart: Boolean): Boolean;
var
  ResultCode, Attempt, ShowCmd: Integer;
begin
  Result := True;
  Attempt := 0;
  if WizardSilent then begin
    ShowCmd := SW_HIDE;
  end else begin
    ShowCmd := SW_SHOWNORMAL;
  end;
  while True do begin
    Dependency_DownloadPage.SetText(Dependency_List[Index].Title, '');
    ResultCode := 0;
#ifdef Dependency_CustomExecute
    if {#Dependency_CustomExecute}(Dependency_FilePath(Dependency_List[Index].Filename), Dependency_List[Index].Parameters, ResultCode) then begin
#else
    if ShellExec('', Dependency_FilePath(Dependency_List[Index].Filename), Dependency_List[Index].Parameters, '', ShowCmd, ewWaitUntilTerminated, ResultCode) then begin
#endif
      Log('Dependency exit code ' + IntToStr(ResultCode) + ': ' + Dependency_List[Index].Title);
      if ResultCode = 1641 then begin // ERROR_SUCCESS_REBOOT_INITIATED
        NeedsRestart := True;
        Result := False;
        exit;
      end else if ResultCode = 3010 then begin // ERROR_SUCCESS_REBOOT_REQUIRED
        Dependency_NeedToRestart := True;
        exit;
      end else if ResultCode = 1638 then begin // ERROR_PRODUCT_VERSION
        exit;
      end else if ResultCode = 1618 then begin // ERROR_INSTALL_ALREADY_RUNNING
        Attempt := Attempt + 1;
        if Attempt <= {#Dependency_InstallBusyRetryCount} then begin
          Log('Another installation is in progress, waiting (attempt ' + IntToStr(Attempt) + ' of ' + IntToStr({#Dependency_InstallBusyRetryCount}) + '): ' + Dependency_List[Index].Title);
          Dependency_Wait(Dependency_List[Index].Title, SysErrorMessage(ResultCode), {#Dependency_InstallBusyRetryDelayMs});
          continue;
        end;
      end else if (ResultCode = 0) or Dependency_List[Index].ForceSuccess then begin // ERROR_SUCCESS
        if Dependency_List[Index].RestartAfter then begin
          if IsLast then begin
            Dependency_NeedToRestart := True;
          end else begin
            NeedsRestart := True;
            Result := False;
          end;
        end;
        exit;
      end;
    end else begin
      Log('Dependency failed to start with error ' + IntToStr(ResultCode) + ': ' + Dependency_List[Index].Title);
    end;

    case SuppressibleMsgBox(FmtMessage(SetupMessage(msgErrorFunctionFailed), [Dependency_List[Index].Title, IntToStr(ResultCode)]), mbError, MB_ABORTRETRYIGNORE, IDABORT) of
      IDABORT: begin
        Result := False;
        exit;
      end;
      IDRETRY: begin
        Attempt := 0;
      end;
      IDIGNORE: begin
        exit;
      end;
    end;
  end;
end;

function Dependency_DownloadAndInstall(var NeedsRestart: Boolean): String;
var
  DependencyIndex, InstallCount, InstallIndex: Integer;
begin
  InstallCount := 0;
  for DependencyIndex := 0 to GetArrayLength(Dependency_List) - 1 do begin
    if not Dependency_IsEntryActive(Dependency_List[DependencyIndex]) then begin
      Log('Dependency skipped (component not selected): ' + Dependency_List[DependencyIndex].Title);
      continue;
    end;
    if Dependency_List[DependencyIndex].URL <> '' then begin
      if not Dependency_Download(DependencyIndex) then begin
        Result := Dependency_List[DependencyIndex].Title;
        exit;
      end;
    end;
    if not Dependency_List[DependencyIndex].SkipInstall then begin
      InstallCount := InstallCount + 1;
    end;
  end;

  InstallIndex := 0;
  for DependencyIndex := 0 to GetArrayLength(Dependency_List) - 1 do begin
    if Dependency_IsEntryActive(Dependency_List[DependencyIndex]) and not Dependency_List[DependencyIndex].SkipInstall then begin
      InstallIndex := InstallIndex + 1;
      Dependency_DownloadPage.SetProgress(InstallIndex, InstallCount + 1);
      if not Dependency_Install(DependencyIndex, InstallIndex = InstallCount, NeedsRestart) then begin
        Result := Dependency_List[DependencyIndex].Title;
        exit;
      end;
    end;
  end;
end;

procedure Dependency_RegisterResume;
var
  ParameterIndex: Integer;
  Parameter, ParameterName, CommandLine: String;
begin
  Log('Dependency requires restart: registering RunOnce to resume setup');
  CommandLine := '"' + ExpandConstant('{srcexe}') + '" /restart=1 /LANG="' + ExpandConstant('{language}') + '" /DIR="' + RemoveBackslashUnlessRoot(WizardDirValue) + '" /GROUP="' + RemoveBackslashUnlessRoot(WizardGroupValue) + '" /TYPE="' + WizardSetupType(False) + '" /COMPONENTS="' + WizardSelectedComponents(False) + '" /TASKS="' + WizardSelectedTasks(False) + '"';
  for ParameterIndex := 1 to ParamCount do begin
    Parameter := ParamStr(ParameterIndex);
    ParameterName := Uppercase(Copy(Parameter, 1, Pos('=', Parameter + '=')));
    if ParameterName = '/LOG=' then begin
      // a fixed log file would be overwritten
      Parameter := Copy(Parameter, 6, Length(Parameter));
      Parameter := '/LOG=' + ChangeFileExt(Parameter, '') + '-2' + ExtractFileExt(Parameter);
    end;
    // set above, or would store a password or override the wizard
    if Pos(' ' + ParameterName + ' ', ' /RESTART= /LANG= /DIR= /GROUP= /TYPE= /COMPONENTS= /TASKS= /MERGETASKS= /NOICONS /PASSWORD= /LOADINF= ') = 0 then begin
      if Pos(' ', Parameter) > 0 then begin
        Parameter := '"' + Parameter + '"';
      end;
      CommandLine := CommandLine + ' ' + Parameter;
    end;
  end;
  if WizardNoIcons then begin
    CommandLine := CommandLine + ' /NOICONS';
  end;
  if Length(CommandLine) > 260 then begin
    Log('RunOnce command has ' + IntToStr(Length(CommandLine)) + ' characters, Windows documents a limit of 260: setup may not resume');
  end;
  RegWriteStringValue(HKA, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', ExpandConstant('{srcexe}'), CommandLine);
end;

<event('PrepareToInstall')>
function Dependency_PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if GetArrayLength(Dependency_List) > 0 then begin
    Dependency_DownloadPage.Show;
    try
      Result := Dependency_DownloadAndInstall(NeedsRestart);
    finally
      Dependency_DownloadPage.Hide;
    end;

    if NeedsRestart then begin
      Dependency_RegisterResume;
    end;
  end;
end;

#ifndef Dependency_NoUpdateReadyMemo
<event('UpdateReadyMemo')>
#endif
function Dependency_UpdateReadyMemo(const Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  DependencyIndex: Integer;
  DependencyMemo: String;
begin
  Result := '';
  if MemoUserInfoInfo <> '' then begin
    Result := Result + MemoUserInfoInfo + NewLine + NewLine;
  end;
  if MemoDirInfo <> '' then begin
    Result := Result + MemoDirInfo + NewLine + NewLine;
  end;
  if MemoTypeInfo <> '' then begin
    Result := Result + MemoTypeInfo + NewLine + NewLine;
  end;
  if MemoComponentsInfo <> '' then begin
    Result := Result + MemoComponentsInfo + NewLine + NewLine;
  end;
  if MemoGroupInfo <> '' then begin
    Result := Result + MemoGroupInfo + NewLine + NewLine;
  end;
  if MemoTasksInfo <> '' then begin
    Result := Result + MemoTasksInfo;
  end;

  DependencyMemo := '';
  for DependencyIndex := 0 to GetArrayLength(Dependency_List) - 1 do begin
    if Dependency_IsEntryActive(Dependency_List[DependencyIndex]) then begin
      DependencyMemo := DependencyMemo + NewLine + Space + Dependency_List[DependencyIndex].Title;
    end;
  end;

  if DependencyMemo <> '' then begin
    if MemoTasksInfo = '' then begin
      Result := Result + SetupMessage(msgReadyMemoTasks);
    end;
    Result := Result + DependencyMemo;
  end;
end;

<event('NeedRestart')>
function Dependency_NeedRestart: Boolean;
begin
  Result := Dependency_NeedToRestart;
end;

function Dependency_IsArm64: Boolean;
begin
  Result := not Dependency_ForceX86 and not Dependency_ForceX64 and IsArm64 and Is64BitInstallMode;
end;

function Dependency_IsX64: Boolean;
begin
  Result := not Dependency_IsArm64 and not Dependency_ForceX86 and (Is64BitInstallMode or (Dependency_ForceX64 and IsX64Compatible));
end;

function Dependency_String(const x86, x64, arm64: String): String;
begin
  if Dependency_IsArm64 then begin
    Result := arm64;
  end else if Dependency_IsX64 then begin
    Result := x64;
  end else begin
    Result := x86;
  end;
end;

function Dependency_StringX64(const x86, x64: String): String;
begin
  Result := Dependency_String(x86, x64, x64);
end;

// machine-wide components follow Windows rather than the setup
function Dependency_StringWin(const x86, x64, arm64: String): String;
begin
  if IsArm64 and (arm64 <> '') then begin
    Result := arm64;
  end else if IsWin64 then begin
    Result := x64;
  end else begin
    Result := x86;
  end;
end;

function Dependency_ArchSuffix: String;
begin
  Result := Dependency_String('', '_x64', '_arm64');
end;

function Dependency_ArchTitle: String;
begin
  Result := Dependency_String(' (x86)', ' (x64)', ' (arm64)');
end;

function Dependency_ArchHKLM: Integer;
begin
  if Dependency_IsArm64 or Dependency_IsX64 then begin
    Result := HKLM64;
  end else begin
    Result := HKLM32;
  end;
end;

function Dependency_PassiveOrQuiet(const Passive, Quiet: String): String;
begin
  if WizardSilent then begin
    Result := Quiet;
  end else begin
    Result := Passive;
  end;
end;

function Dependency_Latest(const URL: String): String;
begin
#ifdef Dependency_Evergreen
  Result := URL;
#else
  Result := '';
#endif
end;

procedure Dependency_AddLatestIfMissing(const Missing: Boolean; const Filename, Parameters, Title, URL, Checksum, LatestURL: String; const ForceSuccess, RestartAfter: Boolean);
begin
  if (URL <> '') and (LatestURL <> '') then begin
    Dependency_AddIfMissing(Missing, Filename, Parameters, Title, LatestURL, '', ForceSuccess, RestartAfter);
  end else begin
    Dependency_AddIfMissing(Missing, Filename, Parameters, Title, URL, Checksum, ForceSuccess, RestartAfter);
  end;
end;

function Dependency_IsMsiProductInstalled(const UpgradeCode: String; const PackedMinVersion: Int64): Boolean;
begin
  try
    Result := IsMsiProductInstalled(UpgradeCode, PackedMinVersion);
  except
    Log('Failed to query MSI product ' + UpgradeCode + ': ' + GetExceptionMessage);
    Result := False;
  end;
end;

var
  Dependency_NetCoreRuntimesArch: String;
  Dependency_NetCoreRuntimes: TArrayOfString;

procedure Dependency_ListNetCoreRuntimes;
var
  Arch, Path: String;
  ResultCode: Integer;
  Output: TExecOutput;
begin
  Arch := Dependency_String('x86', 'x64', 'arm64');
  if Dependency_NetCoreRuntimesArch = Arch then begin
    exit;
  end;
  Dependency_NetCoreRuntimesArch := Arch;
  SetArrayLength(Dependency_NetCoreRuntimes, 0);

  // never keep a relative location: it would run whatever dotnet.exe sits in the current directory
  if not (RegQueryStringValue(HKLM32, 'SOFTWARE\dotnet\Setup\InstalledVersions\' + Arch, 'InstallLocation', Path)
    and PathIsRooted(Path) and FileExists(AddBackslash(Path) + 'dotnet.exe')) then begin
    Path := ExpandConstant(Dependency_StringX64('{commonpf32}', '{commonpf64}')) + '\dotnet';
    if IsArm64 and (Arch = 'x64') then begin
      Path := Path + '\x64';
    end;
  end;
  Path := AddBackslash(Path);

  if FileExists(Path + 'dotnet.exe') and ExecAndCaptureOutput(Path + 'dotnet.exe', '--list-runtimes', '', SW_HIDE, ewWaitUntilTerminated, ResultCode, Output) and (ResultCode = 0) then begin
    Dependency_NetCoreRuntimes := Output.StdOut;
  end;
end;

function Dependency_IsNetCoreInstalled(Runtime: String; Major, Minor, Revision: Word): Boolean;
var
  LineIndex: Integer;
  LineParts: TArrayOfString;
  PackedVersion: Int64;
  LineMajor, LineMinor, LineRevision, LineBuild: Word;
begin
  Dependency_ListNetCoreRuntimes;

  for LineIndex := 0 to Length(Dependency_NetCoreRuntimes) - 1 do begin
    LineParts := StringSplit(Trim(Dependency_NetCoreRuntimes[LineIndex]), [' '], stExcludeEmpty);

    if (Length(LineParts) > 1) and SameText(LineParts[0], Runtime) and StrToVersion(LineParts[1], PackedVersion) then begin
      UnpackVersionComponents(PackedVersion, LineMajor, LineMinor, LineRevision, LineBuild);

      if (LineMajor = Major) and (LineMinor = Minor) and (LineRevision >= Revision) then begin
        Result := True;
        exit;
      end;
    end;
  end;
  Result := False;
end;

procedure Dependency_AddDotNet35;
begin
  // https://learn.microsoft.com/en-us/dotnet/framework/install/dotnet-35-windows
  Dependency_AddIfMissing(not IsDotNetInstalled(net35, 1),
    GetSysNativeDir + '\dism.exe',
    '/online /enable-feature /featurename:NetFx3 /all /quiet /norestart',
    '.NET Framework 3.5 Service Pack 1',
    '',
    '',
    False, False);
end;

procedure Dependency_AddDotNetFramework(const Version: TDotNetVersion; const Filename, Title, URL, Checksum: String);
begin
  // https://dotnet.microsoft.com/download/dotnet-framework
  Dependency_AddIfMissing(not IsDotNetInstalled(Version, 0),
    Filename,
    '/lcid ' + IntToStr(GetUILanguage) + ' ' + Dependency_PassiveOrQuiet('/passive', '/q') + ' /norestart',
    '.NET Framework ' + Title,
    URL,
    Checksum,
    False, False);
end;

procedure Dependency_AddDotNet40; begin Dependency_AddDotNetFramework(net4full, 'dotNetFx40_Full_setup.exe', '4.0', 'https://download.microsoft.com/download/1/B/E/1BE39E79-7E39-46A3-96FF-047F95396215/dotNetFx40_Full_setup.exe', 'fa1afff978325f8818ce3a559d67a58297d9154674de7fd8eb03656d93104425'); end;
procedure Dependency_AddDotNet45; begin Dependency_AddDotNetFramework(net452, 'dotnetfx45.exe', '4.5.2', 'https://download.microsoft.com/download/9/A/7/9A78F13F-FD62-4F6D-AB6B-1803508A9F56/51209.34209.03/web/NDP452-KB2901954-Web.exe', 'bd173d14a371e6786c4ae90be1f2c560458d672ba4cbeb3cf55bebfef2e2778a'); end;
procedure Dependency_AddDotNet46; begin Dependency_AddDotNetFramework(net462, 'dotnetfx46.exe', '4.6.2', 'https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/570f7c7e1975df353a4652ae70b3e0ac/ndp462-kb3151802-web.exe', '67242c8fe953d454edb4171023343f33740e3d16e8469a4b0c11bd42eb85f3fa'); end;
procedure Dependency_AddDotNet47; begin Dependency_AddDotNetFramework(net472, 'dotnetfx47.exe', '4.7.2', 'https://download.visualstudio.microsoft.com/download/pr/1f5af042-d0e4-4002-9c59-9ba66bcf15f6/124d2afe5c8f67dfa910da5f9e3db9c1/ndp472-kb4054531-web.exe', '151b1c11f625e7122d517b6a1778841df8ff168d931c41730f59b9e4b8bcbe36'); end;
procedure Dependency_AddDotNet48; begin Dependency_AddDotNetFramework(net48, 'dotnetfx48.exe', '4.8', 'https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/9b7b8746971ed51a1770ae4293618187/ndp48-web.exe', '0bba3094588c4bfec301939985222a20b340bf03431563dec8b2b4478b06fffa'); end;
procedure Dependency_AddDotNet481; begin Dependency_AddDotNetFramework(net481, 'dotnetfx481.exe', '4.8.1', 'https://download.microsoft.com/download/4/b/2/cd00d4ed-ebdd-49ee-8a33-eabc3d1030e3/NDP481-Web.exe', '05e9ada305fd0013a6844e7657f06ed330887093e3df59c11cb528b86efa3fbf'); end;

procedure Dependency_AddDotNetRuntime(const Runtime, Prefix, Title: String; Major, Minor, Revision: Word; const URL, Checksum, LatestURL: String);
begin
  // https://dotnet.microsoft.com/download/dotnet
  Dependency_AddLatestIfMissing(not Dependency_IsNetCoreInstalled(Runtime, Major, Minor, Revision),
    Prefix + Dependency_ArchSuffix + '.exe',
    '/lcid ' + IntToStr(GetUILanguage) + ' ' + Dependency_PassiveOrQuiet('/passive', '/quiet') + ' /norestart',
    Title + ' ' + IntToStr(Major) + '.' + IntToStr(Minor) + '.' + IntToStr(Revision) + Dependency_ArchTitle,
    URL,
    Checksum,
    LatestURL,
    False, False);
end;

procedure Dependency_AddNetCore31; begin Dependency_AddDotNetRuntime('Microsoft.NETCore.App', 'netcore31', '.NET Core Runtime', 3, 1, 32, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/Runtime/3.1.32/dotnet-runtime-3.1.32-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/3.1.32/dotnet-runtime-3.1.32-win-x64.exe', ''), Dependency_String('bc735b1a969cd03cbf1d0a70d5f16402e1030f309e5e58ca072307a30f0df164', '4393d2cdacecc096e964ea9761dfd5c336fb002b1b3ae0808e7d2d445e2dea89', ''), ''); end;
procedure Dependency_AddNetCore31Asp; begin Dependency_AddDotNetRuntime('Microsoft.AspNetCore.App', 'netcore31asp', 'ASP.NET Core Runtime', 3, 1, 32, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/3.1.32/aspnetcore-runtime-3.1.32-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/3.1.32/aspnetcore-runtime-3.1.32-win-x64.exe', ''), Dependency_String('d3ebd94c684eb1ddb410a649d0a3185da05a7b21ef1d378d2e4a7ee21bfd27d2', '03035faabb028399f3fbe41fe565aec4204deb9373fa65fe7efc769066ba0502', ''), ''); end;
procedure Dependency_AddNetCore31Desktop; begin Dependency_AddDotNetRuntime('Microsoft.WindowsDesktop.App', 'netcore31desktop', '.NET Desktop Runtime', 3, 1, 32, Dependency_String('https://download.visualstudio.microsoft.com/download/pr/3f353d2c-0431-48c5-bdf6-fbbe8f901bb5/542a4af07c1df5136a98a1c2df6f3d62/windowsdesktop-runtime-3.1.32-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/b92958c6-ae36-4efa-aafe-569fced953a5/1654639ef3b20eb576174c1cc200f33a/windowsdesktop-runtime-3.1.32-win-x64.exe', ''), Dependency_String('765436d4aa3de87af8b390d1cd16fce94c5f72dd04173adbb49c940b98b47704', '22f4050ae4b6cdfd109f229f7f7a56f3b3afde00f592babfe890177c76ad8e40', ''), ''); end;
procedure Dependency_AddDotNet50; begin Dependency_AddDotNetRuntime('Microsoft.NETCore.App', 'dotnet50', '.NET Runtime', 5, 0, 17, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/Runtime/5.0.17/dotnet-runtime-5.0.17-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/5.0.17/dotnet-runtime-5.0.17-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/5.0.17/dotnet-runtime-5.0.17-win-arm64.exe'), Dependency_String('40a978da46efa7e66de2c40d952778118b2207ba2344f6d59032d114cbdb40da', '8387e162223ac2adc4d0f24765a886052b8c514bb4eb3d7cc9333c747cd9a03b', '2d1a5d53717e92d6def6415c81acea3d1fbd729ec3d06f3b4312d57ee5906b65'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/5.0/dotnet-runtime-win-x86.exe', 'https://aka.ms/dotnet/5.0/dotnet-runtime-win-x64.exe', 'https://aka.ms/dotnet/5.0/dotnet-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet50Asp; begin Dependency_AddDotNetRuntime('Microsoft.AspNetCore.App', 'dotnet50asp', 'ASP.NET Core Runtime', 5, 0, 17, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/5.0.17/aspnetcore-runtime-5.0.17-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/5.0.17/aspnetcore-runtime-5.0.17-win-x64.exe', ''), Dependency_String('0d2d451bbe54f652905530a2c635be974b439cef7aefa7eced314780ae1a2a67', '5e4c82c13b406f0542793ea3cb2d510fd97fa186bfe5017c1c3ca1e942bb9ae8', ''), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/5.0/aspnetcore-runtime-win-x86.exe', 'https://aka.ms/dotnet/5.0/aspnetcore-runtime-win-x64.exe', ''))); end;
procedure Dependency_AddDotNet50Desktop; begin Dependency_AddDotNetRuntime('Microsoft.WindowsDesktop.App', 'dotnet50desktop', '.NET Desktop Runtime', 5, 0, 17, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/5.0.17/windowsdesktop-runtime-5.0.17-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/5.0.17/windowsdesktop-runtime-5.0.17-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/5.0.17/windowsdesktop-runtime-5.0.17-win-arm64.exe'), Dependency_String('63fef76824c51df09ed6fc5b031796fad64435db0e72f1735021b55760360c98', '925cc68a346cf5692fc1b52f498db32edd278ade3f4331539b7914e23f3af417', '2de98cf23ac87178e703d608697ec2697d09a0715dc89967e89ffb1de8dbb532'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/5.0/windowsdesktop-runtime-win-x86.exe', 'https://aka.ms/dotnet/5.0/windowsdesktop-runtime-win-x64.exe', 'https://aka.ms/dotnet/5.0/windowsdesktop-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet60; begin Dependency_AddDotNetRuntime('Microsoft.NETCore.App', 'dotnet60', '.NET Runtime', 6, 0, 36, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/Runtime/6.0.36/dotnet-runtime-6.0.36-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/6.0.36/dotnet-runtime-6.0.36-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/6.0.36/dotnet-runtime-6.0.36-win-arm64.exe'), Dependency_String('3b3cb4636251a582158f4b6b340f20b3861e6793eb9a3e64bda29cbf32da3604', '6bdad7bc4c41fe93d4ae7b0312b1d017cfe369d28e7e2e421f5b675f9feefe84', 'e34775ff8723bf4e6d397473e302e246a18692e6ea3b3906eff3cb5a6f8c8f3b'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/6.0/dotnet-runtime-win-x86.exe', 'https://aka.ms/dotnet/6.0/dotnet-runtime-win-x64.exe', 'https://aka.ms/dotnet/6.0/dotnet-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet60Asp; begin Dependency_AddDotNetRuntime('Microsoft.AspNetCore.App', 'dotnet60asp', 'ASP.NET Core Runtime', 6, 0, 36, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/6.0.36/aspnetcore-runtime-6.0.36-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/6.0.36/aspnetcore-runtime-6.0.36-win-x64.exe', ''), Dependency_String('af72a5b08fb14e95c1d05d2542d3de79d50e31e06cac181b2a1df3f87bc1f515', '06dbd26509079497c363b28060874d75d19c3797b83020f3c53f37faa755a61d', ''), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/6.0/aspnetcore-runtime-win-x86.exe', 'https://aka.ms/dotnet/6.0/aspnetcore-runtime-win-x64.exe', ''))); end;
procedure Dependency_AddDotNet60Desktop; begin Dependency_AddDotNetRuntime('Microsoft.WindowsDesktop.App', 'dotnet60desktop', '.NET Desktop Runtime', 6, 0, 36, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-arm64.exe'), Dependency_String('4e77bd970df0a06528ee88d33e4a8c9fb85beedbdd7219b017083acf0c3aa39e', '0d20debb26fc8b2bc84f25fbd9d4596a6364af8517ebf012e8b871127b798941', '8bb01362d7525a42cc4f27e1b863242d8136c3f491bdf00efca627658735a118'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x86.exe', 'https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe', 'https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet70; begin Dependency_AddDotNetRuntime('Microsoft.NETCore.App', 'dotnet70', '.NET Runtime', 7, 0, 20, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/Runtime/7.0.20/dotnet-runtime-7.0.20-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/7.0.20/dotnet-runtime-7.0.20-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/7.0.20/dotnet-runtime-7.0.20-win-arm64.exe'), Dependency_String('9bf79c94ab014b555167e61f3ce653fdf54c70bda6d6c74ab9f6f44652947a89', '10f48feee0f7fb4c2ed61ecef5e58699743afc9531f8a293680a99fc2d0a78a5', '04b97503bc1ca8b1fc0277e406a4875b003137b814ca20b5cb1778ccbc095cc6'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/7.0/dotnet-runtime-win-x86.exe', 'https://aka.ms/dotnet/7.0/dotnet-runtime-win-x64.exe', 'https://aka.ms/dotnet/7.0/dotnet-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet70Asp; begin Dependency_AddDotNetRuntime('Microsoft.AspNetCore.App', 'dotnet70asp', 'ASP.NET Core Runtime', 7, 0, 20, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/7.0.20/aspnetcore-runtime-7.0.20-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/7.0.20/aspnetcore-runtime-7.0.20-win-x64.exe', ''), Dependency_String('c4fa407e4e8324edd900b6a39ab7964a45b77bd5a22d4cdba945f1a17c595ab8', 'ab9a6bfed06369dbe22328f54c69ce0660629ea6fc31bc554ed8b585edb16a67', ''), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/7.0/aspnetcore-runtime-win-x86.exe', 'https://aka.ms/dotnet/7.0/aspnetcore-runtime-win-x64.exe', 'https://aka.ms/dotnet/7.0/aspnetcore-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet70Desktop; begin Dependency_AddDotNetRuntime('Microsoft.WindowsDesktop.App', 'dotnet70desktop', '.NET Desktop Runtime', 7, 0, 20, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/7.0.20/windowsdesktop-runtime-7.0.20-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/7.0.20/windowsdesktop-runtime-7.0.20-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/7.0.20/windowsdesktop-runtime-7.0.20-win-arm64.exe'), Dependency_String('58d32d9857bda5da99afc217669aedacdffb20aed61f15315718eeb3a455b273', '57e7c16e7226c9a29dbc3faedd9e5876cec494c7660528052f52160521e7b714', '93df5c5d93d3dec06b49b555909a751122edbb3f121d52577578cb9b24ffe4f2'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/7.0/windowsdesktop-runtime-win-x86.exe', 'https://aka.ms/dotnet/7.0/windowsdesktop-runtime-win-x64.exe', 'https://aka.ms/dotnet/7.0/windowsdesktop-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet80; begin Dependency_AddDotNetRuntime('Microsoft.NETCore.App', 'dotnet80', '.NET Runtime', 8, 0, 34, Dependency_String('https://download.microsoft.com/download/d8dc2fbb-a1c3-4e7b-9af8-ecc8c7c71e3d/829e7071-044d-4e2e-8eed-d157b56643e7/dotnet-runtime-8.0.34-win-x86.exe', 'https://download.microsoft.com/download/d8dc2fbb-a1c3-4e7b-9af8-ecc8c7c71e3d/9696d119-c8d0-49ae-a7a0-1b12c118cb5e/dotnet-runtime-8.0.34-win-x64.exe', 'https://download.microsoft.com/download/d8dc2fbb-a1c3-4e7b-9af8-ecc8c7c71e3d/a6e1eb12-1b80-4a0b-a29f-6841d9a65089/dotnet-runtime-8.0.34-win-arm64.exe'), Dependency_String('7309f41a395eacced0520801fbf0ec832bee108bba334f5a019cb3fc0efc0e7c', 'cd57fd46bed9134f61b735ebc94592fa3872c6ba2c3562326a8eb47cf139ca75', '5569a82cba262fa2b51b300c6e512d73b03958e5711758d063ef96a743ee707b'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/8.0/dotnet-runtime-win-x86.exe', 'https://aka.ms/dotnet/8.0/dotnet-runtime-win-x64.exe', 'https://aka.ms/dotnet/8.0/dotnet-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet80Asp; begin Dependency_AddDotNetRuntime('Microsoft.AspNetCore.App', 'dotnet80asp', 'ASP.NET Core Runtime', 8, 0, 34, Dependency_String('https://download.microsoft.com/download/0d362f9c-391c-40c3-93e7-664fc58f5510/b7a88407-ab8a-4dc0-af87-2185cf802766/aspnetcore-runtime-8.0.34-win-x86.exe', 'https://download.microsoft.com/download/0d362f9c-391c-40c3-93e7-664fc58f5510/f0ba20f2-9841-4f16-9ac7-fb18b053f15f/aspnetcore-runtime-8.0.34-win-x64.exe', 'https://download.microsoft.com/download/0d362f9c-391c-40c3-93e7-664fc58f5510/7fc00706-d141-493b-a7e6-57fefc19f788/aspnetcore-runtime-8.0.34-win-arm64.exe'), Dependency_String('cfd87fff8e744ad90138136e8123748d454c819aac537c1e32f5438dd2aeafd4', 'bca9f91d9acd40fe7d3f47f3371253d628fb2a9ebecfe33aac444e3225456704', 'a31412ff1d663fb737fadee2589e6289d8b3e683f063dd1a09d7c8664742912a'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/8.0/aspnetcore-runtime-win-x86.exe', 'https://aka.ms/dotnet/8.0/aspnetcore-runtime-win-x64.exe', 'https://aka.ms/dotnet/8.0/aspnetcore-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet80Desktop; begin Dependency_AddDotNetRuntime('Microsoft.WindowsDesktop.App', 'dotnet80desktop', '.NET Desktop Runtime', 8, 0, 34, Dependency_String('https://download.microsoft.com/download/f5126c7f-c450-4883-a6ac-db5a8625bd16/46384efe-3075-4e8b-a593-32d224605bd5/windowsdesktop-runtime-8.0.34-win-x86.exe', 'https://download.microsoft.com/download/f5126c7f-c450-4883-a6ac-db5a8625bd16/3a6bc153-80ae-4859-80d1-3f251d2485e0/windowsdesktop-runtime-8.0.34-win-x64.exe', 'https://download.microsoft.com/download/f5126c7f-c450-4883-a6ac-db5a8625bd16/6002b91f-5647-4e8e-a004-400bbca00cf0/windowsdesktop-runtime-8.0.34-win-arm64.exe'), Dependency_String('5c3b9172c69593b28b42df5e9def6d4e1e35085f7bc9b38fb3ac085ed790bcae', '37aa8a02acc1973ddd7e3de993a02007ccef26b48fa35b09d087fa8ab4602795', 'fc59c425739a31842d06df633d11c40721bea71ef3bcba7f6f838813e1818756'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x86.exe', 'https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe', 'https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet90; begin Dependency_AddDotNetRuntime('Microsoft.NETCore.App', 'dotnet90', '.NET Runtime', 9, 0, 23, Dependency_String('https://download.microsoft.com/download/e724b818-d50e-43ba-ba6e-0219dac3b858/a31b93f2-897e-44ad-b4a4-bed64627c574/dotnet-runtime-9.0.23-win-x86.exe', 'https://download.microsoft.com/download/e724b818-d50e-43ba-ba6e-0219dac3b858/15b7263a-d531-404b-8361-f2ef02426f9f/dotnet-runtime-9.0.23-win-x64.exe', 'https://download.microsoft.com/download/e724b818-d50e-43ba-ba6e-0219dac3b858/855c79cc-6542-462c-90a1-f30d1405c21c/dotnet-runtime-9.0.23-win-arm64.exe'), Dependency_String('5eddbb8ede5f3839048304d1c927ee9f5c89a92377ac236b7bf0ec28554ab2f4', '4b808b4c5e35ad8d2d3f5462fb6015a865c8123a265c642c25be3500d8cc79d9', '2086b4b3d655cf79c892bf0f781a336b45ca952bb4a578b07ab655998f64ef70'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/9.0/dotnet-runtime-win-x86.exe', 'https://aka.ms/dotnet/9.0/dotnet-runtime-win-x64.exe', 'https://aka.ms/dotnet/9.0/dotnet-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet90Asp; begin Dependency_AddDotNetRuntime('Microsoft.AspNetCore.App', 'dotnet90asp', 'ASP.NET Core Runtime', 9, 0, 23, Dependency_String('https://download.microsoft.com/download/f6219c18-2410-4e44-ab4d-c6a3abd5c39f/c90e9ee5-f0c2-4341-9773-98b712b98be6/aspnetcore-runtime-9.0.23-win-x86.exe', 'https://download.microsoft.com/download/f6219c18-2410-4e44-ab4d-c6a3abd5c39f/71230f88-da3e-43a8-aa85-01dd8acb486b/aspnetcore-runtime-9.0.23-win-x64.exe', 'https://download.microsoft.com/download/f6219c18-2410-4e44-ab4d-c6a3abd5c39f/3e6d017d-9d2d-48ae-85d9-defeae456624/aspnetcore-runtime-9.0.23-win-arm64.exe'), Dependency_String('2a88118330402bd040caacf9bf49f74762f5a23a38563ca433d73edd2f5b7900', 'e9cb80b8543f36cdfb8802fa1a4f4873dd23a55bd236ddb25c0002c3b55128ef', '19d48b48a52a1f7014029aba215b53597c2d8da656f25b0e62339bf33a2d52c5'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/9.0/aspnetcore-runtime-win-x86.exe', 'https://aka.ms/dotnet/9.0/aspnetcore-runtime-win-x64.exe', 'https://aka.ms/dotnet/9.0/aspnetcore-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet90Desktop; begin Dependency_AddDotNetRuntime('Microsoft.WindowsDesktop.App', 'dotnet90desktop', '.NET Desktop Runtime', 9, 0, 23, Dependency_String('https://download.microsoft.com/download/257e5b34-a28e-4b26-90a7-b20332ca8015/9da81bcc-739d-411c-8f6b-0fb98f12bf08/windowsdesktop-runtime-9.0.23-win-x86.exe', 'https://download.microsoft.com/download/257e5b34-a28e-4b26-90a7-b20332ca8015/caddd012-8bc6-4f3e-b17c-3b6d3c4c895a/windowsdesktop-runtime-9.0.23-win-x64.exe', 'https://download.microsoft.com/download/257e5b34-a28e-4b26-90a7-b20332ca8015/8979597a-5893-49d0-abfd-93f7a32fe8df/windowsdesktop-runtime-9.0.23-win-arm64.exe'), Dependency_String('8ec9c835bd1da748e18e100201f5a9551521b94c0165f19546749b72cbccd487', 'eefb60bd0f3fb33c0787074cebc0467ffba32bcb01088613121649fc3bdb4a27', '18ab370ec8fddb4bc16c9edcd3742d804058998dc9a28b4bdb91d276bb486aaf'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x86.exe', 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-x64.exe', 'https://aka.ms/dotnet/9.0/windowsdesktop-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet100; begin Dependency_AddDotNetRuntime('Microsoft.NETCore.App', 'dotnet100', '.NET Runtime', 10, 0, 15, Dependency_String('https://download.microsoft.com/download/ffd45c1d-8bfb-4336-b17b-9b4d099046f1/bb62b9e4-3216-47a6-94d3-b62d680f53b2/dotnet-runtime-10.0.15-win-x86.exe', 'https://download.microsoft.com/download/ffd45c1d-8bfb-4336-b17b-9b4d099046f1/820034e4-4b5b-422a-80a6-8b3ffafbf58d/dotnet-runtime-10.0.15-win-x64.exe', 'https://download.microsoft.com/download/ffd45c1d-8bfb-4336-b17b-9b4d099046f1/d5ce6fd1-95d5-4acd-adbb-406812706e50/dotnet-runtime-10.0.15-win-arm64.exe'), Dependency_String('781e1d683d205f9016720bed788be8df2ea6c6dbeabcfe744713ae3421f98b17', '59b0da003d18b76e8dcc0dc05bf7e54a0e6e83e7c569d57e1ee5c270664bb128', '07398de5cc8ea84791b71c4ee80114e1f8a79b9a19ae1e63d60b2950ff8c4009'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/10.0/dotnet-runtime-win-x86.exe', 'https://aka.ms/dotnet/10.0/dotnet-runtime-win-x64.exe', 'https://aka.ms/dotnet/10.0/dotnet-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet100Asp; begin Dependency_AddDotNetRuntime('Microsoft.AspNetCore.App', 'dotnet100asp', 'ASP.NET Core Runtime', 10, 0, 15, Dependency_String('https://download.microsoft.com/download/85025cd0-4bfb-466d-af9d-3b3b3d00f3e7/77f14f6d-7b52-48c9-8635-66ec760f6650/aspnetcore-runtime-10.0.15-win-x86.exe', 'https://download.microsoft.com/download/85025cd0-4bfb-466d-af9d-3b3b3d00f3e7/8f22aec2-efcc-438c-8f4d-ce2949796c89/aspnetcore-runtime-10.0.15-win-x64.exe', 'https://download.microsoft.com/download/85025cd0-4bfb-466d-af9d-3b3b3d00f3e7/412a9b9c-8093-48c2-8c6d-8f92419bc84f/aspnetcore-runtime-10.0.15-win-arm64.exe'), Dependency_String('c706da3297df8a3892507360207f4fd1fdfdcdfc8dd816c28eb8afcba7f43a70', 'd15a124f8a221f9da1337333b713a5bd209fc1d712864d920946401a8fda3f07', '7395054fc7de20faf059e463132ed3a450789ef0b8349304b0a78a1cf2275dea'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/10.0/aspnetcore-runtime-win-x86.exe', 'https://aka.ms/dotnet/10.0/aspnetcore-runtime-win-x64.exe', 'https://aka.ms/dotnet/10.0/aspnetcore-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet100Desktop; begin Dependency_AddDotNetRuntime('Microsoft.WindowsDesktop.App', 'dotnet100desktop', '.NET Desktop Runtime', 10, 0, 15, Dependency_String('https://download.microsoft.com/download/b477fae7-19d5-41a2-ba11-105d9bab54f8/1c3d996c-0b02-4fee-9fac-2a2ddd84adad/windowsdesktop-runtime-10.0.15-win-x86.exe', 'https://download.microsoft.com/download/b477fae7-19d5-41a2-ba11-105d9bab54f8/276d0de6-d558-4859-a3fe-65103e17a1ec/windowsdesktop-runtime-10.0.15-win-x64.exe', 'https://download.microsoft.com/download/b477fae7-19d5-41a2-ba11-105d9bab54f8/e81498af-3470-4ea6-89b8-6ef532e7680f/windowsdesktop-runtime-10.0.15-win-arm64.exe'), Dependency_String('0f55fc79174ea8daa11c339fba629b286ba6cadbb920a77de366b408b15315a5', 'e61b030c1673edfa3c0844502eff83198c46af9e7df70dfc6e2efc5b11ea513a', 'ab46299e102bde89c8b8c19f5e53eb47064513f33bfd2d5fc84bf623fbf00b50'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/10.0/windowsdesktop-runtime-win-x86.exe', 'https://aka.ms/dotnet/10.0/windowsdesktop-runtime-win-x64.exe', 'https://aka.ms/dotnet/10.0/windowsdesktop-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet110; begin Dependency_AddDotNetRuntime('Microsoft.NETCore.App', 'dotnet110', '.NET Runtime', 11, 0, 0, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/Runtime/11.0.0/dotnet-runtime-11.0.0-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/11.0.0/dotnet-runtime-11.0.0-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/11.0.0/dotnet-runtime-11.0.0-win-arm64.exe'), Dependency_String('cc3210fc62eba61e1b601883ee87f01508c48dc289bb9659912c4325b455102d', '7338c0bf3895ebfc03c03a37f99b13b6cf558c85709534439f76d61a2ca1289f', 'ba7f8d7878c0860a5fd69636c93b58c382b0fc37cdafe67e933dd1c0fa43de9f'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/11.0/dotnet-runtime-win-x86.exe', 'https://aka.ms/dotnet/11.0/dotnet-runtime-win-x64.exe', 'https://aka.ms/dotnet/11.0/dotnet-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet110Asp; begin Dependency_AddDotNetRuntime('Microsoft.AspNetCore.App', 'dotnet110asp', 'ASP.NET Core Runtime', 11, 0, 0, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/11.0.0/aspnetcore-runtime-11.0.0-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/11.0.0/aspnetcore-runtime-11.0.0-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/11.0.0/aspnetcore-runtime-11.0.0-win-arm64.exe'), Dependency_String('c86c6a220abbbc9eae14030c1af21fbd83ac1f70a95f122ddef04415281da488', '9b3f46f10d2b5bd4c6bd503772d047e0c6d8da69f69cfe7c13afc603abc1bc9c', 'da425a474bd4540f60ae8aa30df68858fb933796f94667d2352ea7d62306d779'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/11.0/aspnetcore-runtime-win-x86.exe', 'https://aka.ms/dotnet/11.0/aspnetcore-runtime-win-x64.exe', 'https://aka.ms/dotnet/11.0/aspnetcore-runtime-win-arm64.exe'))); end;
procedure Dependency_AddDotNet110Desktop; begin Dependency_AddDotNetRuntime('Microsoft.WindowsDesktop.App', 'dotnet110desktop', '.NET Desktop Runtime', 11, 0, 0, Dependency_String('https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/11.0.0/windowsdesktop-runtime-11.0.0-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/11.0.0/windowsdesktop-runtime-11.0.0-win-x64.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/11.0.0/windowsdesktop-runtime-11.0.0-win-arm64.exe'), Dependency_String('ddae4213e840526ed58ef5a59288ffdbea1eb5f703de5f68e295ba528780b0fe', '8c0eafd5eb480e4603aa63619aeffe378157e07b2f0f8dd3db9b5226ac890d4a', '9537033d2522cca54110d4d1c0285eec240b95d308942b09ff650a820e42338e'), Dependency_Latest(Dependency_String('https://aka.ms/dotnet/11.0/windowsdesktop-runtime-win-x86.exe', 'https://aka.ms/dotnet/11.0/windowsdesktop-runtime-win-x64.exe', 'https://aka.ms/dotnet/11.0/windowsdesktop-runtime-win-arm64.exe'))); end;

procedure Dependency_AddDotNetHosting(const Major, Patch: Integer; const URL, Checksum, LatestURL: String);
begin
  // https://dotnet.microsoft.com/download/dotnet
  Dependency_AddLatestIfMissing(not Dependency_IsNetCoreInstalled('Microsoft.AspNetCore.App', Major, 0, Patch) or not FileExists(ExpandConstant(Dependency_StringX64('{commonpf32}', '{commonpf64}')) + '\IIS\Asp.Net Core Module\V2\aspnetcorev2.dll'),
    'dotnet' + IntToStr(Major) + '0hosting.exe',
    '/lcid ' + IntToStr(GetUILanguage) + ' ' + Dependency_PassiveOrQuiet('/passive', '/quiet') + ' /norestart',
    'ASP.NET Core ' + IntToStr(Major) + '.0 Hosting Bundle',
    URL,
    Checksum,
    LatestURL,
    False, False);
end;

procedure Dependency_AddDotNet80Hosting; begin Dependency_AddDotNetHosting(8, 34, 'https://download.microsoft.com/download/001db58d-5a20-4c81-a5e7-b97c33d7af97/a04c10bb-881f-466e-b6b3-28ba611ff805/dotnet-hosting-8.0.34-win.exe', 'bf78032f14ed77f880573f536cb3e94c80a420f6a025b62c8c44bb6bf5799281', Dependency_Latest('https://aka.ms/dotnet/8.0/dotnet-hosting-win.exe')); end;
procedure Dependency_AddDotNet90Hosting; begin Dependency_AddDotNetHosting(9, 23, 'https://download.microsoft.com/download/e6966483-6faf-4afb-b3f8-c99573f43ff5/e8db473e-9ac4-4f5f-9d3c-fe77d9aca10c/dotnet-hosting-9.0.23-win.exe', '4279370e891fc01c00507a0c27b2c9a4c2f24a1d6df424d7d6522da942a3781c', Dependency_Latest('https://aka.ms/dotnet/9.0/dotnet-hosting-win.exe')); end;
procedure Dependency_AddDotNet100Hosting; begin Dependency_AddDotNetHosting(10, 15, 'https://download.microsoft.com/download/445001a5-c37d-4837-9fb6-5a0446f9c327/e16d0c14-a6fa-444c-be70-1715de328ba3/dotnet-hosting-10.0.15-win.exe', '9a901e4d1d4373d28e6ac173bed8f3a723c3c4cba169a6c560525518bf981753', Dependency_Latest('https://aka.ms/dotnet/10.0/dotnet-hosting-win.exe')); end;
procedure Dependency_AddDotNet110Hosting; begin Dependency_AddDotNetHosting(11, 0, 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/11.0.0/dotnet-hosting-11.0.0-win.exe', '533980ab99ca9fa7a825d7b1f7640b95b35ac2511532d52174fe0d15ee70742c', Dependency_Latest('https://aka.ms/dotnet/11.0/dotnet-hosting-win.exe')); end;

procedure Dependency_AddVCMsi(const Year, Title, UpgradeCode: String; Major, Minor, Build, Revision: Word; const Parameters, URL, Checksum: String);
begin
  Dependency_AddIfMissing(not Dependency_IsMsiProductInstalled(UpgradeCode, PackVersionComponents(Major, Minor, Build, Revision)), 'vcredist' + Year + Dependency_StringX64('', '_x64') + '.exe', Parameters, Title + Dependency_StringX64(' (x86)', ' (x64)'), URL, Checksum, False, False);
end;

procedure Dependency_AddVC2005; begin Dependency_AddVCMsi('2005', 'Visual C++ 2005 Service Pack 1 Redistributable', Dependency_StringX64('{86C9D5AA-F00C-4921-B3F2-C60AF92E2844}', '{A8D19029-8E5C-4E22-8011-48070F9E796E}'), 8, 0, 61000, 0, '/q', Dependency_StringX64('https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE', 'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE'), Dependency_StringX64('8648c5fc29c44b9112fe52f9a33f80e7fc42d10f3b5b42b2121542a13e44adfd', '4487570bd86e2e1aac29db2a1d0a91eb63361fcaac570808eb327cd4e0e2240d')); end;
procedure Dependency_AddVC2008; begin Dependency_AddVCMsi('2008', 'Visual C++ 2008 Service Pack 1 Redistributable', Dependency_StringX64('{DE2C306F-A067-38EF-B86C-03DE4B0312F9}', '{FDA45DDF-8E17-336F-A3ED-356B7B7C688A}'), 9, 0, 30729, 6161, '/q', Dependency_StringX64('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe', 'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe'), Dependency_StringX64('8742bcbf24ef328a72d2a27b693cc7071e38d3bb4b9b44dec42aa3d2c8d61d92', 'c5e273a4a16ab4d5471e91c7477719a2f45ddadb76c7f98a38fa5074a6838654')); end;
procedure Dependency_AddVC2010; begin Dependency_AddVCMsi('2010', 'Visual C++ 2010 Service Pack 1 Redistributable', Dependency_StringX64('{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}', '{5B75F761-BAC8-33BC-A381-464DDDD813A3}'), 10, 0, 40219, 0, Dependency_PassiveOrQuiet('/passive', '/q') + ' /norestart', Dependency_StringX64('https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe'), Dependency_StringX64('99dce3c841cc6028560830f7866c9ce2928c98cf3256892ef8e6cf755147b0d8', 'f3b7a76d84d23f91957aa18456a14b4e90609e4ce8194c5653384ed38dada6f3')); end;
procedure Dependency_AddVC2012; begin Dependency_AddVCMsi('2012', 'Visual C++ 2012 Update 4 Redistributable', Dependency_StringX64('{4121ED58-4BD9-3E7B-A8B5-9F8BAAE045B7}', '{EFA6AFA1-738E-3E00-8101-FD03B86B29D1}'), 11, 0, 61030, 0, Dependency_PassiveOrQuiet('/passive', '/quiet') + ' /norestart', Dependency_StringX64('https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe'), Dependency_StringX64('b924ad8062eaf4e70437c8be50fa612162795ff0839479546ce907ffa8d6e386', '681be3e5ba9fd3da02c09d7e565adfa078640ed66a0d58583efad2c1e3cc4064')); end;
procedure Dependency_AddVC2013; begin Dependency_AddVCMsi('2013', 'Visual C++ 2013 Update 5 Redistributable', Dependency_StringX64('{B59F5BF1-67C8-3802-8E59-2CE551A39FC5}', '{20400CF0-DE7C-327E-9AE4-F0F38D9085F8}'), 12, 0, 40664, 0, Dependency_PassiveOrQuiet('/passive', '/quiet') + ' /norestart', Dependency_StringX64('https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe'), Dependency_StringX64('53b605d1100ab0a88b867447bbf9274b5938125024ba01f5105a9e178a3dcdbd', 'a4bba7701e355ae29c403431f871a537897c363e215cafe706615e270984f17c')); end;

procedure Dependency_AddVC14;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist
  if RegQueryStringValue(Dependency_ArchHKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\' + Dependency_String('x86', 'x64', 'arm64'), 'Version', Version) and (Copy(Version, 1, 1) = 'v') then begin
    Delete(Version, 1, 1);
  end;
  Dependency_AddLatestIfMissing(not StrToVersion(Version, PackedVersion) or (ComparePackedVersion(PackedVersion, PackVersionComponents(14, 52, 37029, 0)) < 0),
    'vcredist14' + Dependency_ArchSuffix + '.exe',
    Dependency_PassiveOrQuiet('/passive', '/quiet') + ' /norestart',
    'Visual C++ v14 Redistributable' + Dependency_ArchTitle,
    Dependency_String('https://download.visualstudio.microsoft.com/download/pr/78d061c5-9ef3-42ab-98ed-3309d1095dc4/7B0117E6E20E9E349029C000A8A2715A52CF37C15B6BB697B2908E8BC7066CDF/VC_redist.x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/78d061c5-9ef3-42ab-98ed-3309d1095dc4/9C02C9ED120F671B900E6B9471D890E3B2414117A7E53F4AE2E855466FA2B7C9/VC_redist.x64.exe', 'https://download.visualstudio.microsoft.com/download/pr/78d061c5-9ef3-42ab-98ed-3309d1095dc4/3C81BCF5B06156858362400D7066F65ECE38E8ACCB5E687FC65BEF5735F31FFC/VC_redist.arm64.exe'),
    Dependency_String('7b0117e6e20e9e349029c000a8a2715a52cf37c15b6bb697b2908e8bc7066cdf', '9c02c9ed120f671b900e6b9471d890e3b2414117a7e53f4ae2e855466fa2b7c9', '3c81bcf5b06156858362400d7066f65ece38e8accb5e687fc65bef5735f31ffc'),
    Dependency_Latest(Dependency_String('https://aka.ms/vc14/vc_redist.x86.exe', 'https://aka.ms/vc14/vc_redist.x64.exe', 'https://aka.ms/vc14/vc_redist.arm64.exe')),
    False, False);
end;

procedure Dependency_AddVC2015To2019; begin Dependency_AddVC14; end;
procedure Dependency_AddVC2015To2022; begin Dependency_AddVC14; end;

// always added: the web setup itself only installs what is missing
procedure Dependency_AddDirectX;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=35 - 9.29.1974.0
  Dependency_Add('dxwebsetup.exe',
    '/q',
    'DirectX Runtime',
    'https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe',
    '2cf71d098c608c56e07f4655855a886c3102553f648df88458df616b26fd612f',
    True, False);
end;

function Dependency_IsSqlInstalled(const RootKey: Integer; const InstanceId: String; const PackedMinVersion: Int64): Boolean;
var
  NameIndex: Integer;
  Names: TArrayOfString;
  Id, Version: String;
  PackedVersion: Int64;
begin
  Result := False;
  if RegGetValueNames(RootKey, 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL', Names) then begin
    for NameIndex := 0 to GetArrayLength(Names) - 1 do begin
      if RegQueryStringValue(RootKey, 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL', Names[NameIndex], Id) and (Pos(InstanceId, Id) = 1)
        and RegQueryStringValue(RootKey, 'SOFTWARE\Microsoft\Microsoft SQL Server\' + Id + '\MSSQLServer\CurrentVersion', 'CurrentVersion', Version)
        and StrToVersion(Version, PackedVersion) and (ComparePackedVersion(PackedVersion, PackedMinVersion) >= 0) then begin
        Result := True;
      end;
    end;
  end;
end;

procedure Dependency_AddSqlExpress(const Year, InstanceId, Title: String; Major, Minor, Build, Revision: Word; const URL, Checksum: String);
var
  Parameters: String;
  PackedMinVersion: Int64;
begin
  // the web installer of SQL Server 2016 and newer names the instance itself
  if Major < 13 then begin
    Parameters := Dependency_PassiveOrQuiet('/QS', '/Q') + ' /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER';
  end else begin
    Parameters := '/QUIET /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL';
  end;

  // also finds a 32-bit instance
  PackedMinVersion := PackVersionComponents(Major, Minor, Build, Revision);
  Dependency_AddIfMissing(not Dependency_IsSqlInstalled(HKLM32, InstanceId, PackedMinVersion) and not (IsWin64 and Dependency_IsSqlInstalled(HKLM64, InstanceId, PackedMinVersion)), 'sql' + Year + 'express.exe', Parameters, Title, URL, Checksum, False, False);
end;

procedure Dependency_AddSql2008Express; begin Dependency_AddSqlExpress('2008', 'MSSQL10_50.MSSQLSERVER', 'SQL Server 2008 R2 Service Pack 2 Express', 10, 50, 4000, 0, Dependency_StringWin('https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR_x64_ENU.exe', ''), Dependency_StringWin('8096bea8ed1559cb39a2b42c0c680d1251e8ddbab6d09be1e0a4263623183086', '4372dec5a5f4b2e48c60da7b09b5368214fddbc8cd0c4a0be5af2d74522b67f8', '')); end;
procedure Dependency_AddSql2012Express; begin Dependency_AddSqlExpress('2012', 'MSSQL11.MSSQLSERVER', 'SQL Server 2012 Service Pack 4 Express', 11, 0, 7001, 0, Dependency_StringWin('https://download.microsoft.com/download/B/D/E/BDE8FAD6-33E5-44F6-B714-348F73E602B6/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/B/D/E/BDE8FAD6-33E5-44F6-B714-348F73E602B6/SQLEXPR_x64_ENU.exe', ''), Dependency_StringWin('c380d4f4aa61a150885dda6f39ce135c0960c5ce4f04d5c96a5357e9417bc474', 'bae6000b3ecef827fb4371a7aaccf0278de8cb84da1a510d56e3588b20230582', '')); end;
procedure Dependency_AddSql2014Express; begin Dependency_AddSqlExpress('2014', 'MSSQL12.MSSQLSERVER', 'SQL Server 2014 Service Pack 3 Express', 12, 0, 6024, 0, Dependency_StringWin('https://download.microsoft.com/download/3/9/F/39F968FA-DEBB-4960-8F9E-0E7BB3035959/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/3/9/F/39F968FA-DEBB-4960-8F9E-0E7BB3035959/SQLEXPR_x64_ENU.exe', ''), Dependency_StringWin('5771644bc02221268c5e14fdea7068c6311e8bff4182b2d359b4d8d4b22bec3d', 'e8d8330e3e7d6f9242e658315b99aace4aabb71ed14f3ec465e4450d66d255b6', '')); end;
procedure Dependency_AddSql2016Express; begin Dependency_AddSqlExpress('2016', 'MSSQL13.', 'SQL Server 2016 Service Pack 3 Express', 13, 0, 6404, 1, Dependency_StringWin('', 'https://download.microsoft.com/download/f7e95fb9-9a5a-4039-be84-631043b6a310/SQLServer2016-SSEI-Expr.exe', ''), Dependency_StringWin('', 'a9f71d85bfbba0d2090c4afbc85df5931339e5cced19c8f9ba4c7a9a63b95892', '')); end;
procedure Dependency_AddSql2017Express; begin Dependency_AddSqlExpress('2017', 'MSSQL14.', 'SQL Server 2017 Express', 14, 0, 1000, 169, Dependency_StringWin('', 'https://download.microsoft.com/download/6c9ea8c2-2512-4368-a9a3-3c6901a6e78c/SQLServer2017-SSEI-Expr.exe', ''), Dependency_StringWin('', 'b92b45f0113062e1045cadcc6f739ef51d61d887903ef9dc290bc37b300df7b1', '')); end;
procedure Dependency_AddSql2019Express; begin Dependency_AddSqlExpress('2019', 'MSSQL15.', 'SQL Server 2019 Express', 15, 0, 2000, 5, Dependency_StringWin('', 'https://download.microsoft.com/download/926a8db2-3ad9-444c-8b37-8376e9256e9d/SQL2019-SSEI-Expr.exe', ''), Dependency_StringWin('', '37cc32717aba3b6633071ec176c6728e05570cfa5cf4c67f54421a0a2b4493c2', '')); end;
procedure Dependency_AddSql2022Express; begin Dependency_AddSqlExpress('2022', 'MSSQL16.', 'SQL Server 2022 Express', 16, 0, 1000, 6, Dependency_StringWin('', 'https://download.microsoft.com/download/29654887-7cde-4397-bba3-d7f087970845/SQL2022-SSEI-Expr.exe', ''), Dependency_StringWin('', 'e2b8e8aad30d8b1a1922c6c0976c806f0a2e08d04b2de100a9d70b9f94750bb1', '')); end;
procedure Dependency_AddSql2025Express; begin Dependency_AddSqlExpress('2025', 'MSSQL17.', 'SQL Server 2025 Express', 17, 0, 1000, 7, Dependency_StringWin('', 'https://download.microsoft.com/download/ffd82b4c-9955-47c0-8efe-6290f7795cf6/SQL2025-SSEI-Expr.exe', ''), Dependency_StringWin('', 'fa7e1fabc9a2e9c9cdab0d1512bcb30d2949133147db057ac530f510e5270680', '')); end;

const
  // not on WinGet, updated by hand
  Dependency_SqlOleDb19X86URL = 'https://download.microsoft.com/download/0a09a9e0-e364-4d01-b102-04ddfcf38a7e/x86/1033/msoledbsql.msi';
  Dependency_SqlOleDb19X86Checksum = 'b86f1ee532e6ea543721747eb03b32e5eff6c292458de3d90391b97908c8e13c';

procedure Dependency_AddSqlOleDb19;
begin
  // https://learn.microsoft.com/en-us/sql/connect/oledb/download-oledb-driver-for-sql-server - 19.4.3.0
  Dependency_AddIfMissing(not RegValueExists(Dependency_ArchHKLM, 'SOFTWARE\Microsoft\MSOLEDBSQL19', 'InstalledVersion'),
    'msoledbsql.msi',
    '/qn /norestart IACCEPTMSOLEDBSQLLICENSETERMS=YES',
    'Microsoft OLE DB Driver 19 for SQL Server',
    Dependency_StringWin(Dependency_SqlOleDb19X86URL, 'https://download.microsoft.com/download/bbb0d870-7a04-44d9-af17-af28575a0ed8/amd64/1033/msoledbsql.msi', ''),
    Dependency_StringWin(Dependency_SqlOleDb19X86Checksum, 'c1d5bd79c316588fb08c852acf76628ab662426e763b68aef4cfa25fa1dd7beb', ''),
    False, False);
end;

procedure Dependency_AddSqlOdbc18;
begin
  // https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server - 18.7.1.1
  Dependency_AddIfMissing(not RegKeyExists(Dependency_ArchHKLM, 'SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server'),
    'msodbcsql.msi',
    '/qn /norestart IACCEPTMSODBCSQLLICENSETERMS=YES',
    'Microsoft ODBC Driver 18 for SQL Server',
    Dependency_StringWin('https://download.microsoft.com/download/ca8ce451-a4b4-42c0-ba73-f66642c4bfae/x86/1033/msodbcsql.msi', 'https://download.microsoft.com/download/d624e1c6-293b-4d6f-91b8-6e515a5d6a77/amd64/1033/msodbcsql.msi', 'https://download.microsoft.com/download/92f6c111-1489-4538-8d7e-b35218b0675b/arm64/1033/msodbcsql.msi'),
    Dependency_StringWin('b2cc946db432ac6d84064b8c55024e7157495a5d1f14f7402b291c2efb567ced', '21ef69e4b942f18aced55fa7c3a8d7263004e113a96690bac7509645e1b1a310', 'fc61b5a9c52b4bb62e0c735f275e7579ede0a62e0e4b60811ef4a63ea55ac52b'),
    False, False);
end;

// an uninstall can leave 0.0.0.0 behind
function Dependency_IsWebView2Installed(const RootKey: Integer): Boolean;
var
  Version: String;
begin
  Result := RegQueryStringValue(RootKey, 'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) and (Version <> '') and (Version <> '0.0.0.0');
end;

procedure Dependency_AddWebView2;
begin
  // https://developer.microsoft.com/en-us/microsoft-edge/webview2 - 157.0.4341.42
  Dependency_AddLatestIfMissing(not Dependency_IsWebView2Installed(HKLM32) and not Dependency_IsWebView2Installed(HKCU),
    'MicrosoftEdgeWebView2RuntimeInstaller.exe',
    '/silent /install',
    'WebView2 Runtime',
    Dependency_StringWin('https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/a4d69ace-3ef5-401e-94b5-e85b1dd8de18/MicrosoftEdgeWebView2RuntimeInstallerX86.exe', 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/0126536e-e048-416f-923b-202f7f6fa64b/MicrosoftEdgeWebView2RuntimeInstallerX64.exe', 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/3c3e2a37-c863-4dd0-b614-c3e00e45d598/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe'),
    Dependency_StringWin('e3ad662552e7b0b5ac9bef473f9009c0278c3929b911f0c523a58e12264c355e', '2688308af55753c62fda4e8140024e230c1ffc16b7c091b25889572f38dff6e8', '950b81de7b4e54d8a2cbc1a4e7f76177547789d89ad144d119021daa96bd5b39'),
    Dependency_Latest('https://go.microsoft.com/fwlink/p/?LinkId=2124703'),
    False, False);
end;

procedure Dependency_AddAccessDatabaseEngine2016;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=54920 - 16.0.5044.1000
  Dependency_AddIfMissing(not RegKeyExists(Dependency_ArchHKLM, 'SOFTWARE\Microsoft\Office\16.0\Access Connectivity Engine\Engines\ACE'),
    'AccessDatabaseEngine2016' + Dependency_StringX64('', '_x64') + '.exe',
    '/quiet',
    'Microsoft Access Database Engine 2016' + Dependency_StringX64(' (x86)', ' (x64)'),
    Dependency_StringX64('https://download.microsoft.com/download/3/5/C/35C84C36-661A-44E6-9324-8786B8DBE231/accessdatabaseengine.exe', 'https://download.microsoft.com/download/3/5/C/35C84C36-661A-44E6-9324-8786B8DBE231/accessdatabaseengine_X64.exe'),
    Dependency_StringX64('adc0504656f390d225530ac09f1fc2113295c4f9baeffea1e983fecf4ac960f0', '04e96c9f1a1f7d251a88aececf1dc10ff65950392787427c00814a43308003de'),
    False, False);
end;

procedure Dependency_AddVSTORuntime;
begin
  // https://learn.microsoft.com/en-us/visualstudio/vsto/how-to-install-the-visual-studio-tools-for-office-runtime-redistributable - 10.0.60917
  Dependency_AddIfMissing(not RegKeyExists(HKLM32, 'SOFTWARE\Microsoft\VSTO Runtime Setup\v4R'),
    'vstor_redist.exe',
    '/q /norestart',
    'Visual Studio 2010 Tools for Office Runtime',
    'https://download.microsoft.com/download/5/d/2/5d24f8f8-efbb-4b63-aa33-3785e3104713/vstor_redist.exe',
    'cfe1a40bbe4a50022db2164abdb0154984e2cecb761a23cdc81cb5754f6e0a18',
    False, False);
end;

// delayload because the API needs Windows 8
function Dependency_GetPackagesByPackageFamily(PackageFamilyName: String; var Count: Cardinal; PackageFullNames: String; var BufferLength: Cardinal; Buffer: String): Integer;
external 'GetPackagesByPackageFamily@kernel32.dll stdcall delayload';

// the packages of a family that are registered for the current user
function Dependency_GetPackageFullNames(const PackageName: String): TArrayOfString;
var
  Count, BufferLength: Cardinal;
  PackageFamilyName, Pointers, Buffer: String;
begin
  SetArrayLength(Result, 0);
  PackageFamilyName := PackageName + '_8wekyb3d8bbwe';
  try
    Count := 0;
    BufferLength := 0;
    if Dependency_GetPackagesByPackageFamily(PackageFamilyName, Count, '', BufferLength, '') = 122 then begin // ERROR_INSUFFICIENT_BUFFER
      // the API requires an array of pointers into the buffer, 4 characters fit a pointer
      SetLength(Pointers, Count * 4);
      SetLength(Buffer, BufferLength);
      if Dependency_GetPackagesByPackageFamily(PackageFamilyName, Count, Pointers, BufferLength, Buffer) = 0 then begin
        Result := StringSplit(Buffer, [#0], stExcludeEmpty);
      end;
    end;
  except
    Log('Failed to query package ' + PackageName + ': ' + GetExceptionMessage);
  end;
end;

function Dependency_HasWinAppRuntimePackage(const PackageName, Architecture: String): Boolean;
var
  PackageIndex: Integer;
  PackageFullNames: TArrayOfString;
begin
  PackageFullNames := Dependency_GetPackageFullNames(PackageName);
  for PackageIndex := 0 to GetArrayLength(PackageFullNames) - 1 do begin
    if Pos('_' + Architecture + '_', PackageFullNames[PackageIndex]) > 0 then begin
      Result := True;
      exit;
    end;
  end;
  Result := False;
end;

// a DDLM package is named after its framework version, so it only counts next to that framework
function Dependency_HasWinAppRuntimeFramework(const Channel: String; const NeedsLifetimeManager: Boolean): Boolean;
var
  PackageIndex: Integer;
  Architecture: String;
  PackageFullNames, PackageFields: TArrayOfString;
begin
  Architecture := Dependency_String('x86', 'x64', 'arm64');
  PackageFullNames := Dependency_GetPackageFullNames('Microsoft.WindowsAppRuntime.' + Channel);
  for PackageIndex := 0 to GetArrayLength(PackageFullNames) - 1 do begin
    PackageFields := StringSplit(PackageFullNames[PackageIndex], ['_'], stExcludeEmpty); // name, version, architecture, publisher id
    if (GetArrayLength(PackageFields) > 2) and (PackageFields[2] = Architecture)
      and (not NeedsLifetimeManager or Dependency_HasWinAppRuntimePackage('Microsoft.WinAppRuntime.DDLM.' + PackageFields[1] + '-' + Dependency_String('x8', 'x6', 'a6'), Architecture)) then begin
      Result := True;
      exit;
    end;
  end;
  Result := False;
end;

// a usable runtime needs the framework, main and singleton packages registered for the current user
// the bootstrapper of unpackaged apps also needs the DDLM package for 1.6, and for any channel below Windows 11 24H2 (build 26100)
function Dependency_IsWinAppRuntimeInstalled(const Channel: String): Boolean;
var
  SystemArchitecture: String;
begin
  SystemArchitecture := Dependency_StringWin('x86', 'x64', 'arm64');
  Result :=
    Dependency_HasWinAppRuntimeFramework(Channel, (Channel = '1.6') or (GetWindowsVersion < $0A0065F4))
    and Dependency_HasWinAppRuntimePackage('MicrosoftCorporationII.WinAppRuntime.Main.' + Channel, SystemArchitecture)
    and Dependency_HasWinAppRuntimePackage('MicrosoftCorporationII.WinAppRuntime.Singleton', SystemArchitecture);
end;

procedure Dependency_AddWinAppRuntime16;
begin
  // https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads - 1.6.9
  Dependency_AddIfMissing(not Dependency_IsWinAppRuntimeInstalled('1.6'),
    'windowsappruntime16' + Dependency_ArchSuffix + '.exe',
    '--quiet',
    'Windows App Runtime 1.6' + Dependency_ArchTitle,
    Dependency_String('https://aka.ms/windowsappsdk/1.6/1.6.250602001/windowsappruntimeinstall-x86.exe', 'https://aka.ms/windowsappsdk/1.6/1.6.250602001/windowsappruntimeinstall-x64.exe', 'https://aka.ms/windowsappsdk/1.6/1.6.250602001/windowsappruntimeinstall-arm64.exe'),
    Dependency_String('6219474e62cdc52509df78c31943e61cb896e10517602dd7d55b9b8a9a0b79c7', 'c7cd988425b76ea087e2e1d7b096b585f853e20bb826b8f38d45a5175410a877', '69b8ab5fcff480cc8324c36f9e38140907a6aaa02a4065716c7a2ba74ff177ae'),
    False, False);
end;

procedure Dependency_AddWinAppRuntime17;
begin
  // https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads - 1.7.9
  Dependency_AddIfMissing(not Dependency_IsWinAppRuntimeInstalled('1.7'),
    'windowsappruntime17' + Dependency_ArchSuffix + '.exe',
    '--quiet',
    'Windows App Runtime 1.7' + Dependency_ArchTitle,
    Dependency_String('https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-x86.exe', 'https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-x64.exe', 'https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-arm64.exe'),
    Dependency_String('470b6fe2db339b90b845c90c3368f39b38b15e1a4d3dc7aebea5fa12f1483169', '8de73b13a010c6aeb84040e5587a46d21b36decce0ccd582c346536cad63ae73', '993f54077e747d3f9026745ec860cbe57ec545bcc9054c76746a3acbe99bf8ab'),
    False, False);
end;

procedure Dependency_AddWinAppRuntime18;
begin
  // https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads - 1.8.10
  Dependency_AddIfMissing(not Dependency_IsWinAppRuntimeInstalled('1.8'),
    'windowsappruntime18' + Dependency_ArchSuffix + '.exe',
    '--quiet',
    'Windows App Runtime 1.8' + Dependency_ArchTitle,
    Dependency_String('https://aka.ms/windowsappsdk/1.8/1.8.260710003/windowsappruntimeinstall-x86.exe', 'https://aka.ms/windowsappsdk/1.8/1.8.260710003/windowsappruntimeinstall-x64.exe', 'https://aka.ms/windowsappsdk/1.8/1.8.260710003/windowsappruntimeinstall-arm64.exe'),
    Dependency_String('1d478178455f1da703d5f100489507c8e2853bfb6157635dcebb8d2de5acc8ab', 'b8cda840267ab72797f654f801f9a064ab6d9e508cedee3df79f772f104db6d6', '4c019a3f903dbd3b0cbb02201f852c3142d4c22415d7ef8c74cce76fef789657'),
    False, False);
end;

procedure Dependency_AddWinAppRuntime2;
begin
  // https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads - 2.5.1
  Dependency_AddIfMissing(not Dependency_IsWinAppRuntimeInstalled('2'),
    'windowsappruntime2' + Dependency_ArchSuffix + '.exe',
    '--quiet',
    'Windows App Runtime 2' + Dependency_ArchTitle,
    Dependency_String('https://aka.ms/windowsappsdk/2.5/2.5.1/windowsappruntimeinstall-x86.exe', 'https://aka.ms/windowsappsdk/2.5/2.5.1/windowsappruntimeinstall-x64.exe', 'https://aka.ms/windowsappsdk/2.5/2.5.1/windowsappruntimeinstall-arm64.exe'),
    Dependency_String('76dbd7c272cee0bf18f0b7228255b353d669cd55dc530209c45646f47acb89d4', '931a421e8dc3e6e67724806cb67fecdbb88dfe323f0170842eb4a4b4b149f1e2', 'd5e4d34547eb4e31c64bf1532415b3019c0d92b750e72eb18d3d95bd00feacbb'),
    False, False);
end;

var
  Dependency_JavaMajor: Integer;
  Dependency_JavaMajorDetected: Boolean;

function Dependency_GetJavaMajor: Integer;
var
  JavaExe, Line: String;
  ResultCode, LineIndex, QuotePos: Integer;
  Output: TExecOutput;
  Parts: TArrayOfString;
begin
  if not Dependency_JavaMajorDetected then begin
    Dependency_JavaMajorDetected := True;
    Dependency_JavaMajor := 0;

    // detect whichever java.exe an app would actually use: JAVA_HOME, else PATH
    JavaExe := RemoveQuotes(GetEnv('JAVA_HOME'));
    if (JavaExe <> '') and PathIsRooted(JavaExe) and FileExists(AddBackslash(JavaExe) + 'bin\java.exe') then begin
      JavaExe := AddBackslash(JavaExe) + 'bin\java.exe';
    end else begin
      JavaExe := FileSearch('java.exe', GetEnv('PATH'));
    end;

    // `java -version` prints to stderr
    if PathIsRooted(JavaExe) and ExecAndCaptureOutput(JavaExe, '-version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode, Output) and (ResultCode = 0) then begin
      for LineIndex := 0 to Length(Output.StdErr) - 1 do begin
        Line := Output.StdErr[LineIndex];
        QuotePos := Pos('version "', Line);
        if QuotePos > 0 then begin
          Parts := StringSplit(Copy(Line, QuotePos + 9, Length(Line)), ['.'], stExcludeEmpty);
          if Length(Parts) > 0 then begin
            Dependency_JavaMajor := StrToIntDef(Parts[0], 0);
            if (Dependency_JavaMajor = 1) and (Length(Parts) > 1) then begin
              Dependency_JavaMajor := StrToIntDef(Parts[1], 0); // legacy "1.8.0_x" -> 8
            end;
          end;
          break;
        end;
      end;
    end;
  end;

  Result := Dependency_JavaMajor;
end;

procedure Dependency_AddJava(const Major: Integer; const Vendor, URL, Checksum, LatestURL: String);
var
  FindRec: TFindRec;
  Installed: Boolean;
begin
  // https://learn.microsoft.com/en-us/java/openjdk/download
  // only the JDK installed last is on JAVA_HOME
  Installed := FindFirst(ExpandConstant(Dependency_StringWin('{commonpf32}', '{commonpf64}', '')) + '\' + Vendor + '\jdk-' + IntToStr(Major) + '.*', FindRec);
  if Installed then begin
    FindClose(FindRec);
  end;

  Dependency_AddLatestIfMissing(not Installed and (Dependency_GetJavaMajor <> Major),
    'openjdk-' + IntToStr(Major) + '.msi',
    '/quiet /norestart ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJavaHome',
    'OpenJDK ' + IntToStr(Major),
    URL,
    Checksum,
    LatestURL,
    False, False);
end;

const
  // last 32-bit build
  Dependency_Java8X86URL = 'https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u472-b08/OpenJDK8U-jdk_x86-32_windows_hotspot_8u472b08.msi';
  Dependency_Java8X86Checksum = 'daff0b3a7892ec99635f54554070ede99c175c157f683bc99c6d9008e81dfe4f';

// Java 8 has no Microsoft build, so it comes from Eclipse Temurin
procedure Dependency_AddJava8; begin Dependency_AddJava(8, 'Eclipse Adoptium', Dependency_StringWin(Dependency_Java8X86URL, 'https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u512-b09/OpenJDK8U-jdk_x64_windows_hotspot_8u512b09.msi', ''), Dependency_StringWin(Dependency_Java8X86Checksum, '77a730e65149c4cc426209672c7bd1b996ba6423e04c563c381ba083278cf165', ''), Dependency_Latest(Dependency_StringWin('https://api.adoptium.net/v3/installer/latest/8/ga/windows/x86/jdk/hotspot/normal/eclipse', 'https://api.adoptium.net/v3/installer/latest/8/ga/windows/x64/jdk/hotspot/normal/eclipse', ''))); end;
procedure Dependency_AddJava11; begin Dependency_AddJava(11, 'Microsoft', Dependency_StringWin('', 'https://aka.ms/download-jdk/microsoft-jdk-11.0.33-windows-x64.msi', 'https://aka.ms/download-jdk/microsoft-jdk-11.0.33-windows-aarch64.msi'), Dependency_StringWin('', '2b1d0f95ad0fd44d38e50079b58b6e1da3969ae105042489e26900d212a95281', '37a0e7f2eddf1f4e504ccb52be3075a7ed317bdfb5c249508b1edfac6fb268fc'), Dependency_Latest(Dependency_StringWin('', 'https://aka.ms/download-jdk/microsoft-jdk-11-windows-x64.msi', 'https://aka.ms/download-jdk/microsoft-jdk-11-windows-aarch64.msi'))); end;
procedure Dependency_AddJava17; begin Dependency_AddJava(17, 'Microsoft', Dependency_StringWin('', 'https://aka.ms/download-jdk/microsoft-jdk-17.0.21.0.2-windows-x64.msi', 'https://aka.ms/download-jdk/microsoft-jdk-17.0.21.0.2-windows-aarch64.msi'), Dependency_StringWin('', '303ff40a72a88fab605b8e846968b369c52de6f17ab262afe50f4afcf1c6d3d4', '71643fba8211ef4106176bdd68cc2614843f0b6d0eb294533058bd91a3002ac6'), Dependency_Latest(Dependency_StringWin('', 'https://aka.ms/download-jdk/microsoft-jdk-17-windows-x64.msi', 'https://aka.ms/download-jdk/microsoft-jdk-17-windows-aarch64.msi'))); end;
procedure Dependency_AddJava21; begin Dependency_AddJava(21, 'Microsoft', Dependency_StringWin('', 'https://aka.ms/download-jdk/microsoft-jdk-21.0.13.0.2-windows-x64.msi', 'https://aka.ms/download-jdk/microsoft-jdk-21.0.13.0.2-windows-aarch64.msi'), Dependency_StringWin('', '7a6700302e6079708a4596f8f84ff9d73516cda6ae6da91024063ac7c2a196e8', 'ef0ba3a0e10a0abf2e8f072e9c741b4c9331067f351f27a1360df0b77ead11ec'), Dependency_Latest(Dependency_StringWin('', 'https://aka.ms/download-jdk/microsoft-jdk-21-windows-x64.msi', 'https://aka.ms/download-jdk/microsoft-jdk-21-windows-aarch64.msi'))); end;
procedure Dependency_AddJava25; begin Dependency_AddJava(25, 'Microsoft', Dependency_StringWin('', 'https://aka.ms/download-jdk/microsoft-jdk-25.0.5.0.2-windows-x64.msi', 'https://aka.ms/download-jdk/microsoft-jdk-25.0.5.0.2-windows-aarch64.msi'), Dependency_StringWin('', 'cdff1a90c299b74af813ea7353aa36399936dbf75738495c80fcc5e06b764ca8', '5a452ad59c8141e336e8b4a6214a97e6ae523457fbab03e04cfb934ba2006b9d'), Dependency_Latest(Dependency_StringWin('', 'https://aka.ms/download-jdk/microsoft-jdk-25-windows-x64.msi', 'https://aka.ms/download-jdk/microsoft-jdk-25-windows-aarch64.msi'))); end;

function Dependency_IsPythonInstalled(const Tag: String): Boolean;
begin
  Result := RegKeyExists(Dependency_ArchHKLM, 'Software\Python\PythonCore\' + Tag + '\InstallPath') or RegKeyExists(HKCU, 'Software\Python\PythonCore\' + Tag + '\InstallPath');
end;

procedure Dependency_AddPython(const Minor, URL, Checksum: String);
begin
  // https://www.python.org/downloads/windows/
  Dependency_AddIfMissing(not Dependency_IsPythonInstalled(Minor + Dependency_String('-32', '', '-arm64')),
    'python' + Minor + Dependency_ArchSuffix + '.exe',
    Dependency_PassiveOrQuiet('/passive', '/quiet') + ' InstallAllUsers=1 PrependPath=1',
    'Python ' + Minor + Dependency_ArchTitle,
    URL,
    Checksum,
    False, False);
end;

procedure Dependency_AddPython313; begin Dependency_AddPython('3.13', Dependency_String('https://www.python.org/ftp/python/3.13.17/python-3.13.17.exe', 'https://www.python.org/ftp/python/3.13.17/python-3.13.17-amd64.exe', 'https://www.python.org/ftp/python/3.13.17/python-3.13.17-arm64.exe'), Dependency_String('91cd5b0293162e11c5599f80dc5bd14658cf086c8234a3117b58cfcb93c4eff3', '5da012101ba2e17113a9a1cd901e9ce1441086f2b7ecb5de06ec94163899a190', '3089a1977c32b26f5078e5a7d0285b7a861b8c96250c5dac3b6af59fbe9e9a75')); end;
procedure Dependency_AddPython314; begin Dependency_AddPython('3.14', Dependency_String('https://www.python.org/ftp/python/3.14.10/python-3.14.10.exe', 'https://www.python.org/ftp/python/3.14.10/python-3.14.10-amd64.exe', 'https://www.python.org/ftp/python/3.14.10/python-3.14.10-arm64.exe'), Dependency_String('c8f1a16db9afd76ca74b5f8e28eeaad408bca10894c9d080443bde83def3ed09', '92480239264744fe0386a1bd8275786fefa126e3129e56a68e22b52c73329965', '5b9547e4edae2f6fb2fbfec5e26cf91b4ea191e3b07f7727d5a2c5c2cca93ed3')); end;
procedure Dependency_AddPython315; begin Dependency_AddPython('3.15', Dependency_String('https://www.python.org/ftp/python/3.15.2/python-3.15.2.exe', 'https://www.python.org/ftp/python/3.15.2/python-3.15.2-amd64.exe', 'https://www.python.org/ftp/python/3.15.2/python-3.15.2-arm64.exe'), Dependency_String('a1040151c8af7a31dcfa3d4da2648040806dfe86050622166cbebc7747f23027', '06e225a228191b0f4d1dcf6905fbb21bf9f6970d13a2ec63137ab9bee76f15aa', 'a3957667a6305f0fa4c5ce6c73def927ddcad36190b9e27eb4a04e1a9a153c93')); end;

procedure Dependency_AddPowerShell7;
begin
  // https://github.com/PowerShell/PowerShell/releases
  Dependency_AddIfMissing(not FileExists(ExpandConstant(Dependency_StringWin('{commonpf32}', '{commonpf64}', '')) + '\PowerShell\7\pwsh.exe'),
    'powershell7.msi',
    Dependency_PassiveOrQuiet('/passive', '/quiet') + ' /norestart',
    'PowerShell 7',
    Dependency_StringWin('https://github.com/PowerShell/PowerShell/releases/download/v7.6.9/PowerShell-7.6.9-win-x86.msi', 'https://github.com/PowerShell/PowerShell/releases/download/v7.6.9/PowerShell-7.6.9-win-x64.msi', 'https://github.com/PowerShell/PowerShell/releases/download/v7.6.9/PowerShell-7.6.9-win-arm64.msi'),
    Dependency_StringWin('067659d573a953ff93d1bdd87d7cdd3c34bf1b9c8b9226c5c2164215f3c37608', '50d33c7494aaf82b987cfd4de3f232d04f91fdd4c0deeca8a669cced3e7cf8f9', 'f29d127a798da0d3fec9224171ae4d85453ecb466ce53a957237bca4008c1d2b'),
    False, False);
end;
