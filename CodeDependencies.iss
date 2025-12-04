[Code]
// https://github.com/DomGries/InnoDependencyInstaller

// types and variables
type
  TDependency_Entry = record
    Filename: String;
    Parameters: String;
    Title: String;
    URL: String;
    Checksum: String;
    ForceSuccess: Boolean;
    RestartAfter: Boolean;
  end;

var
  Dependency_Memo: String;
  Dependency_List: array of TDependency_Entry;
  Dependency_NeedToRestart, Dependency_ForceX86: Boolean;
  Dependency_DownloadPage: TDownloadWizardPage;

procedure Dependency_Add(const Filename, Parameters, Title, URL, Checksum: String; const ForceSuccess, RestartAfter: Boolean);
var
  Dependency: TDependency_Entry;
  DependencyCount: Integer;
begin
  Dependency_Memo := Dependency_Memo + #13#10 + '%1' + Title;

  Dependency.Filename := Filename;
  Dependency.Parameters := Parameters;
  Dependency.Title := Title;

  if FileExists(ExpandConstant('{tmp}{\}') + Filename) then begin
    Dependency.URL := '';
  end else begin
    Dependency.URL := URL;
  end;

  Dependency.Checksum := Checksum;
  Dependency.ForceSuccess := ForceSuccess;
  Dependency.RestartAfter := RestartAfter;

  DependencyCount := GetArrayLength(Dependency_List);
  SetArrayLength(Dependency_List, DependencyCount + 1);
  Dependency_List[DependencyCount] := Dependency;
end;

<event('InitializeWizard')>
procedure Dependency_InitializeWizard;
begin
  Dependency_DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

<event('PrepareToInstall')>
function Dependency_PrepareToInstall(var NeedsRestart: Boolean): String;
var
  DependencyCount, DependencyIndex, ResultCode: Integer;
  Retry: Boolean;
  TempValue: String;
begin
  DependencyCount := GetArrayLength(Dependency_List);

  if DependencyCount > 0 then begin
    Dependency_DownloadPage.Show;

    for DependencyIndex := 0 to DependencyCount - 1 do begin
      if Dependency_List[DependencyIndex].URL <> '' then begin
        Dependency_DownloadPage.Clear;
        Dependency_DownloadPage.Add(Dependency_List[DependencyIndex].URL, Dependency_List[DependencyIndex].Filename, Dependency_List[DependencyIndex].Checksum);

        Retry := True;
        while Retry do begin
          Retry := False;

          try
            Dependency_DownloadPage.Download;
          except
            if Dependency_DownloadPage.AbortedByUser then begin
              Result := Dependency_List[DependencyIndex].Title;
              DependencyIndex := DependencyCount;
            end else begin
              case SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
                IDABORT: begin
                  Result := Dependency_List[DependencyIndex].Title;
                  DependencyIndex := DependencyCount;
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

    if Result = '' then begin
      for DependencyIndex := 0 to DependencyCount - 1 do begin
        Dependency_DownloadPage.SetText(Dependency_List[DependencyIndex].Title, '');
        Dependency_DownloadPage.SetProgress(DependencyIndex + 1, DependencyCount + 1);

        while True do begin
          ResultCode := 0;
#ifdef Dependency_CustomExecute
          if {#Dependency_CustomExecute}(ExpandConstant('{tmp}{\}') + Dependency_List[DependencyIndex].Filename, Dependency_List[DependencyIndex].Parameters, ResultCode) then begin
#else
          if ShellExec('', ExpandConstant('{tmp}{\}') + Dependency_List[DependencyIndex].Filename, Dependency_List[DependencyIndex].Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then begin
#endif
            if Dependency_List[DependencyIndex].RestartAfter then begin
              if DependencyIndex = DependencyCount - 1 then begin
                Dependency_NeedToRestart := True;
              end else begin
                NeedsRestart := True;
                Result := Dependency_List[DependencyIndex].Title;
              end;
              break;
            end else if (ResultCode = 0) or Dependency_List[DependencyIndex].ForceSuccess then begin // ERROR_SUCCESS (0)
              break;
            end else if ResultCode = 1641 then begin // ERROR_SUCCESS_REBOOT_INITIATED (1641)
              NeedsRestart := True;
              Result := Dependency_List[DependencyIndex].Title;
              break;
            end else if ResultCode = 3010 then begin // ERROR_SUCCESS_REBOOT_REQUIRED (3010)
              Dependency_NeedToRestart := True;
              break;
            end;
          end;

          case SuppressibleMsgBox(FmtMessage(SetupMessage(msgErrorFunctionFailed), [Dependency_List[DependencyIndex].Title, IntToStr(ResultCode)]), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
            IDABORT: begin
              Result := Dependency_List[DependencyIndex].Title;
              break;
            end;
            IDIGNORE: begin
              break;
            end;
          end;
        end;

        if Result <> '' then begin
          break;
        end;
      end;

      if NeedsRestart then begin
        TempValue := '"' + ExpandConstant('{srcexe}') + '" /restart=1 /LANG="' + ExpandConstant('{language}') + '" /DIR="' + WizardDirValue + '" /GROUP="' + WizardGroupValue + '" /TYPE="' + WizardSetupType(False) + '" /COMPONENTS="' + WizardSelectedComponents(False) + '" /TASKS="' + WizardSelectedTasks(False) + '"';
        if WizardNoIcons then begin
          TempValue := TempValue + ' /NOICONS';
        end;
        RegWriteStringValue(HKA, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', '{#SetupSetting("AppName")}', TempValue);
      end;
    end;

    Dependency_DownloadPage.Hide;
  end;
end;

#ifndef Dependency_NoUpdateReadyMemo
<event('UpdateReadyMemo')>
#endif
function Dependency_UpdateReadyMemo(const Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
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

  if Dependency_Memo <> '' then begin
    if MemoTasksInfo = '' then begin
      Result := Result + SetupMessage(msgReadyMemoTasks);
    end;
    Result := Result + FmtMessage(Dependency_Memo, [Space]);
  end;
end;

<event('NeedRestart')>
function Dependency_NeedRestart: Boolean;
begin
  Result := Dependency_NeedToRestart;
end;

function Dependency_IsX64: Boolean;
begin
  Result := not Dependency_ForceX86 and Is64BitInstallMode;
end;

function Dependency_String(const x86, x64: String): String;
begin
  if Dependency_IsX64 then begin
    Result := x64;
  end else begin
    Result := x86;
  end;
end;

function Dependency_ArchSuffix: String;
begin
  Result := Dependency_String('', '_x64');
end;

function Dependency_ArchTitle: String;
begin
  Result := Dependency_String(' (x86)', ' (x64)');
end;

function Dependency_IsNetCoreInstalled(Runtime: String; Major, Minor, Revision: Word): Boolean;
var
  Path: String;
  ResultCode: Integer;
  Output: TExecOutput;
  LineIndex: Integer;
  LineParts: TArrayOfString;
  PackedVersion: Int64;
  LineMajor, LineMinor, LineRevision, LineBuild: Word;
begin
  if not RegQueryStringValue(HKLM32, 'SOFTWARE\dotnet\Setup\InstalledVersions\x' + Dependency_String('86', '64'), 'InstallLocation', Path) or not FileExists(Path + 'dotnet.exe') then begin
    Path := ExpandConstant(Dependency_String('{commonpf32}', '{commonpf64}')) + '\dotnet\';
  end;
  if ExecAndCaptureOutput(Path + 'dotnet.exe', '--list-runtimes', '', SW_HIDE, ewWaitUntilTerminated, ResultCode, Output) and (ResultCode = 0) then begin
    for LineIndex := 0 to Length(Output.StdOut) - 1 do begin
      LineParts := StringSplit(Trim(Output.StdOut[LineIndex]), [' '], stExcludeEmpty);

      if (Length(LineParts) > 1) and (Lowercase(LineParts[0]) = Lowercase(Runtime)) and StrToVersion(LineParts[1], PackedVersion) then begin
        UnpackVersionComponents(PackedVersion, LineMajor, LineMinor, LineRevision, LineBuild);

        if (LineMajor = Major) and (LineMinor = Minor) and (LineRevision >= Revision) then begin
          Result := True;
          exit;
        end;
      end;
    end;
  end;
  Result := False;
end;

procedure Dependency_AddDotNet35;
begin
  // https://dotnet.microsoft.com/download/dotnet-framework/net35-sp1
  if not IsDotNetInstalled(net35, 1) then begin
    Dependency_Add('dotnetfx35.exe',
      '/lang:enu /passive /norestart',
      '.NET Framework 3.5 Service Pack 1',
      'https://download.microsoft.com/download/2/0/E/20E90413-712F-438C-988E-FDAA79A8AC3D/dotnetfx35.exe',
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet40;
begin
  // https://dotnet.microsoft.com/download/dotnet-framework/net40
  if not IsDotNetInstalled(net4full, 0) then begin
    Dependency_Add('dotNetFx40_Full_setup.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.0',
      'https://download.microsoft.com/download/1/B/E/1BE39E79-7E39-46A3-96FF-047F95396215/dotNetFx40_Full_setup.exe',
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet45;
begin
  // https://dotnet.microsoft.com/download/dotnet-framework/net452
  if not IsDotNetInstalled(net452, 0) then begin
    Dependency_Add('dotnetfx45.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.5.2',
      'https://go.microsoft.com/fwlink/?LinkId=397707',
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet46;
begin
  // https://dotnet.microsoft.com/download/dotnet-framework/net462
  if not IsDotNetInstalled(net462, 0) then begin
    Dependency_Add('dotnetfx46.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.6.2',
      'https://go.microsoft.com/fwlink/?linkid=780596',
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet47;
begin
  // https://dotnet.microsoft.com/download/dotnet-framework/net472
  if not IsDotNetInstalled(net472, 0) then begin
    Dependency_Add('dotnetfx47.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.7.2',
      'https://go.microsoft.com/fwlink/?LinkId=863262',
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet48;
begin
    // https://dotnet.microsoft.com/download/dotnet-framework/net48
    if not IsDotNetInstalled(net48, 0) then begin
      Dependency_Add('dotnetfx48.exe',
        '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
        '.NET Framework 4.8',
        'https://go.microsoft.com/fwlink/?LinkId=2085155',
        '', False, False);
    end;
end;

procedure Dependency_AddDotNet481;
begin
  // https://dotnet.microsoft.com/download/dotnet-framework/net481
  if not IsDotNetInstalled(net481, 0) then begin
    Dependency_Add('dotnetfx481.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.8.1',
      'https://go.microsoft.com/fwlink/?LinkId=2203304',
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet80;
begin
  // https://dotnet.microsoft.com/download/dotnet/8.0
  if not Dependency_IsNetCoreInstalled('Microsoft.NETCore.App', 8, 0, 22) then begin
    Dependency_Add('dotnet80' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Runtime 8.0.22' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.22/dotnet-runtime-8.0.22-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.22/dotnet-runtime-8.0.22-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet80Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet/8.0
  if not Dependency_IsNetCoreInstalled('Microsoft.AspNetCore.App', 8, 0, 22) then begin
    Dependency_Add('dotnet80asp' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 8.0.22' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.22/aspnetcore-runtime-8.0.22-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.22/aspnetcore-runtime-8.0.22-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet80Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet/8.0
  if not Dependency_IsNetCoreInstalled('Microsoft.WindowsDesktop.App', 8, 0, 22) then begin
    Dependency_Add('dotnet80desktop' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 8.0.22' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.22/windowsdesktop-runtime-8.0.22-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.22/windowsdesktop-runtime-8.0.22-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet90;
begin
  // https://dotnet.microsoft.com/download/dotnet/9.0
  if not Dependency_IsNetCoreInstalled('Microsoft.NETCore.App', 9, 0, 11) then begin
    Dependency_Add('dotnet90' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Runtime 9.0.11' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.11/dotnet-runtime-9.0.11-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.11/dotnet-runtime-9.0.11-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet90Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet/9.0
  if not Dependency_IsNetCoreInstalled('Microsoft.AspNetCore.App', 9, 0, 11) then begin
    Dependency_Add('dotnet90asp' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 9.0.11' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.11/aspnetcore-runtime-9.0.11-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.11/aspnetcore-runtime-9.0.11-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet90Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet/9.0
  if not Dependency_IsNetCoreInstalled('Microsoft.WindowsDesktop.App', 9, 0, 11) then begin
    Dependency_Add('dotnet90desktop' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 9.0.11' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.11/windowsdesktop-runtime-9.0.11-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.11/windowsdesktop-runtime-9.0.11-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet100;
begin
  // https://dotnet.microsoft.com/download/dotnet/10.0
  if not Dependency_IsNetCoreInstalled('Microsoft.NETCore.App', 10, 0, 0) then begin
    Dependency_Add('dotnet100' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Runtime 10.0.0' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.0/dotnet-runtime-10.0.0-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.0/dotnet-runtime-10.0.0-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet100Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet/10.0
  if not Dependency_IsNetCoreInstalled('Microsoft.AspNetCore.App', 10, 0, 0) then begin
    Dependency_Add('dotnet100asp' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 10.0.0' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.0/aspnetcore-runtime-10.0.0-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.0/aspnetcore-runtime-10.0.0-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet100Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet/10.0
  if not Dependency_IsNetCoreInstalled('Microsoft.WindowsDesktop.App', 10, 0, 0) then begin
    Dependency_Add('dotnet100desktop' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 10.0.0' + Dependency_ArchTitle,
      Dependency_String('https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.0/windowsdesktop-runtime-10.0.0-win-x86.exe', 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.0/windowsdesktop-runtime-10.0.0-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddVC2005;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=26347
  if not IsMsiProductInstalled(Dependency_String('{86C9D5AA-F00C-4921-B3F2-C60AF92E2844}', '{A8D19029-8E5C-4E22-8011-48070F9E796E}'), PackVersionComponents(8, 0, 61000, 0)) then begin
    Dependency_Add('vcredist2005' + Dependency_ArchSuffix + '.exe',
      '/q',
      'Visual C++ 2005 Service Pack 1 Redistributable' + Dependency_ArchTitle,
      Dependency_String('https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE', 'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE'),
      '', False, False);
  end;
end;

procedure Dependency_AddVC2008;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=26368
  if not IsMsiProductInstalled(Dependency_String('{DE2C306F-A067-38EF-B86C-03DE4B0312F9}', '{FDA45DDF-8E17-336F-A3ED-356B7B7C688A}'), PackVersionComponents(9, 0, 30729, 6161)) then begin
    Dependency_Add('vcredist2008' + Dependency_ArchSuffix + '.exe',
      '/q',
      'Visual C++ 2008 Service Pack 1 Redistributable' + Dependency_ArchTitle,
      Dependency_String('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe', 'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddVC2010;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=26999
  if not IsMsiProductInstalled(Dependency_String('{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}', '{5B75F761-BAC8-33BC-A381-464DDDD813A3}'), PackVersionComponents(10, 0, 40219, 0)) then begin
    Dependency_Add('vcredist2010' + Dependency_ArchSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2010 Service Pack 1 Redistributable' + Dependency_ArchTitle,
      Dependency_String('https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddVC2012;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=30679
  if not IsMsiProductInstalled(Dependency_String('{4121ED58-4BD9-3E7B-A8B5-9F8BAAE045B7}', '{EFA6AFA1-738E-3E00-8101-FD03B86B29D1}'), PackVersionComponents(11, 0, 61030, 0)) then begin
    Dependency_Add('vcredist2012' + Dependency_ArchSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2012 Update 4 Redistributable' + Dependency_ArchTitle,
      Dependency_String('https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddVC2013;
begin
  // https://support.microsoft.com/en-us/help/4032938
  if not IsMsiProductInstalled(Dependency_String('{B59F5BF1-67C8-3802-8E59-2CE551A39FC5}', '{20400CF0-DE7C-327E-9AE4-F0F38D9085F8}'), PackVersionComponents(12, 0, 40664, 0)) then begin
    Dependency_Add('vcredist2013' + Dependency_ArchSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2013 Update 5 Redistributable' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddVC2015To2022;
begin
  // https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist
  if not IsMsiProductInstalled(Dependency_String('{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}'), PackVersionComponents(14, 42, 34433, 0)) then begin
    Dependency_Add('vcredist2022' + Dependency_ArchSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2015-2022 Redistributable' + Dependency_ArchTitle,
      Dependency_String('https://aka.ms/vs/17/release/vc_redist.x86.exe', 'https://aka.ms/vs/17/release/vc_redist.x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDirectX;
begin
#ifdef Dependency_Files_DirectX
  ExtractTemporaryFile('dxwebsetup.exe');
#endif
  // https://www.microsoft.com/en-us/download/details.aspx?id=35
  Dependency_Add('dxwebsetup.exe',
    '/q',
    'DirectX Runtime',
    'https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe',
    '', True, False);
end;

procedure Dependency_AddSql2008Express;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=30438
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or not StrToVersion(Version, PackedVersion) or (ComparePackedVersion(PackedVersion, PackVersionComponents(10, 50, 4000, 0)) < 0) then begin
    Dependency_Add('sql2008express' + Dependency_ArchSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2008 R2 Service Pack 2 Express',
      Dependency_String('https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR_x64_ENU.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddSql2012Express;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=56042
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or not StrToVersion(Version, PackedVersion) or (ComparePackedVersion(PackedVersion, PackVersionComponents(11, 0, 7001, 0)) < 0) then begin
    Dependency_Add('sql2012express' + Dependency_ArchSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2012 Service Pack 4 Express',
      Dependency_String('https://download.microsoft.com/download/B/D/E/BDE8FAD6-33E5-44F6-B714-348F73E602B6/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/B/D/E/BDE8FAD6-33E5-44F6-B714-348F73E602B6/SQLEXPR_x64_ENU.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddSql2014Express;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=57473
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or not StrToVersion(Version, PackedVersion) or (ComparePackedVersion(PackedVersion, PackVersionComponents(12, 0, 6024, 0)) < 0) then begin
    Dependency_Add('sql2014express' + Dependency_ArchSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2014 Service Pack 3 Express',
      Dependency_String('https://download.microsoft.com/download/3/9/F/39F968FA-DEBB-4960-8F9E-0E7BB3035959/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/3/9/F/39F968FA-DEBB-4960-8F9E-0E7BB3035959/SQLEXPR_x64_ENU.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddSql2016Express;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=103447
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or not StrToVersion(Version, PackedVersion) or (ComparePackedVersion(PackedVersion, PackVersionComponents(13, 0, 6404, 1)) < 0) then begin
    Dependency_Add('sql2016express' + Dependency_ArchSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2016 Service Pack 3 Express',
      'https://download.microsoft.com/download/f/a/8/fa83d147-63d1-449c-b22d-5fef9bd5bb46/SQLServer2016-SSEI-Expr.exe',
      '', False, False);
  end;
end;

procedure Dependency_AddSql2017Express;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=55994
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or not StrToVersion(Version, PackedVersion) or (ComparePackedVersion(PackedVersion, PackVersionComponents(14, 0, 0, 0)) < 0) then begin
    Dependency_Add('sql2017express' + Dependency_ArchSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2017 Express',
      'https://download.microsoft.com/download/5/E/9/5E9B18CC-8FD5-467E-B5BF-BADE39C51F73/SQLServer2017-SSEI-Expr.exe',
      '', False, False);
  end;
end;

procedure Dependency_AddSql2019Express;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=101064
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or not StrToVersion(Version, PackedVersion) or (ComparePackedVersion(PackedVersion, PackVersionComponents(15, 0, 0, 0)) < 0) then begin
    Dependency_Add('sql2019express' + Dependency_ArchSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2019 Express',
      'https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe',
      '', False, False);
  end;
end;

procedure Dependency_AddSql2022Express;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=104781
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or not StrToVersion(Version, PackedVersion) or (ComparePackedVersion(PackedVersion, PackVersionComponents(16, 0, 1000, 6)) < 0) then begin
    Dependency_Add('sql2022express' + Dependency_ArchSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2022 Express',
      'https://go.microsoft.com/fwlink/p/?linkid=2216019',
      '', False, False);
  end;
end;

procedure Dependency_AddWebView2;
begin
  // https://developer.microsoft.com/en-us/microsoft-edge/webview2
  if not RegValueExists(HKLM, Dependency_String('SOFTWARE', 'SOFTWARE\WOW6432Node') + '\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv') then begin
    Dependency_Add('MicrosoftEdgeWebview2Setup.exe',
      '/silent /install',
      'WebView2 Runtime',
      'https://go.microsoft.com/fwlink/p/?LinkId=2124703',
      '', False, False);
  end;
end;

procedure Dependency_AddAccessDatabaseEngine2010;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=13255
  if not RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Office\14.0\Access Connectivity Engine\Engines\ACE') then begin
    Dependency_Add('AccessDatabaseEngine2010' + Dependency_ArchSuffix + '.exe',
      '/quiet',
      'Microsoft Access Database Engine 2010' + Dependency_ArchTitle,
      Dependency_String('https://download.microsoft.com/download/2/4/3/24375141-E08D-4803-AB0E-10F2E3A07AAA/AccessDatabaseEngine.exe', 'https://download.microsoft.com/download/2/4/3/24375141-E08D-4803-AB0E-10F2E3A07AAA/AccessDatabaseEngine_X64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddAccessDatabaseEngine2016;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=54920
  if not RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Office\16.0\Access Connectivity Engine\Engines\ACE') then begin
    Dependency_Add('AccessDatabaseEngine2016' + Dependency_ArchSuffix + '.exe',
      '/quiet',
      'Microsoft Access Database Engine 2016' + Dependency_ArchTitle,
      Dependency_String('https://download.microsoft.com/download/3/5/C/35C84C36-661A-44E6-9324-8786B8DBE231/accessdatabaseengine.exe', 'https://download.microsoft.com/download/3/5/C/35C84C36-661A-44E6-9324-8786B8DBE231/accessdatabaseengine_X64.exe'),
      '', False, False);
  end;
end;

[Files]
#ifdef Dependency_Path_DirectX
Source: "{#Dependency_Path_DirectX}dxwebsetup.exe"; Flags: dontcopy noencryption
#endif
