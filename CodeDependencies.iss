; -- CodeDependencies.iss --
;
; This script shows how to download and install any dependency such as .NET,
; Visual C++ or SQL Server during your application's installation process.
;
; contribute: https://github.com/DomGries/InnoDependencyInstaller


; -----------
; SHARED CODE
; -----------

[Code]
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
  Dependency_NeedRestart, Dependency_ForceX86: Boolean;
  Dependency_DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, Filename: string; const Progress, ProgressMax: Int64): Boolean;
begin
  // if ProgressMax <> 0 then
  //  Log(Format('  %d of %d bytes done.', [Progress, ProgressMax]))
  //else
  //  Log(Format('  %d bytes done.', [Progress]));
  Result := True;
end;
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
procedure Dependency_Internal1;
begin
  Dependency_DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

<event('PrepareToInstall')>
function Dependency_Internal2(var NeedsRestart: Boolean): String;
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
          if ShellExec('', ExpandConstant('{tmp}{\}') + Dependency_List[DependencyIndex].Filename, Dependency_List[DependencyIndex].Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then begin
            if Dependency_List[DependencyIndex].RestartAfter then begin
              if DependencyIndex = DependencyCount - 1 then begin
                Dependency_NeedRestart := True;
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
              Dependency_NeedRestart := True;
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

<event('UpdateReadyMemo')>
function Dependency_Internal3(const Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
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
function Dependency_Internal4: Boolean;
begin
  Result := Dependency_NeedRestart;
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

function ArchTitle(Param: String): String;
begin
  Result := Dependency_String('x86', 'x64');
end;

function Dependency_IsNetCoreInstalled(const Version: String): Boolean;
var
  ResultCode: Integer;
begin
  // source code: https://github.com/dotnet/deployment-tools/tree/master/src/clickonce/native/projects/NetCoreCheck
  if not FileExists(ExpandConstant('{tmp}{\}') + 'netcorecheck' + Dependency_ArchSuffix + '.exe') then begin
    //DownloadTemporaryFile(Dependency_string('https://go.microsoft.com/fwlink/?linkid=2135256', 'https://go.microsoft.com/fwlink/?linkid=2135504'),
    //                    'netcorecheck' + Dependency_ArchSuffix + '.exe', '', @OnDownloadProgress);
    ExtractTemporaryFile('netcorecheck' + Dependency_ArchSuffix + '.exe');
  end;
  Result := ShellExec('', ExpandConstant('{tmp}{\}') + 'netcorecheck' + Dependency_ArchSuffix + '.exe', Version, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
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
var
  Net45OrLaterRelease: Cardinal;
  IsInstalled: Boolean;
begin
  // https://dotnet.microsoft.com/en-us/download/dotnet-framework/net481
  // Determine installed version ref: https://learn.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed#detect-net-framework-45-and-later-versions
  if RegQueryDWordValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release', Net45OrLaterRelease) then
    IsInstalled := (Net45OrLaterRelease >= 533320) //On Windows 11 2022 Update: 533320, all other Windows operating systems: 533325
  else
    IsInstalled := False;
  if not IsInstalled then
  begin
    Dependency_Add('dotnetfx481.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.8.1',
      'https://go.microsoft.com/fwlink/?LinkId=2203304',
      '', False, False);
  end;
end;


procedure Dependency_AddNetCore31;
begin
  // https://dotnet.microsoft.com/download/dotnet-core/3.1
  if not Dependency_IsNetCoreInstalled('Microsoft.NETCore.App 3.1.32') then begin
    Dependency_Add('netcore31' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Core Runtime 3.1.32' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/de4b3438-24a2-4d1d-a845-97355cf97b71/515abb880478b49f7c1bced8fbf07b16/dotnet-runtime-3.1.32-win-x86.exe',
                        'https://download.visualstudio.microsoft.com/download/pr/476eba79-f17f-49c8-a213-0f24a22cd026/37c02de81ff5b76ac57a5427462395f1/dotnet-runtime-3.1.32-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddNetCore31Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet-core/3.1
  if not Dependency_IsNetCoreInstalled('Microsoft.AspNetCore.App 3.1.32') then begin
    Dependency_Add('netcore31asp' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 3.1.32' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/63b482d2-04b2-4dd4-baaf-d1e78de80738/40321091c872f4e77337b68fc61a5a07/aspnetcore-runtime-3.1.32-win-x86.exe',
                        'https://download.visualstudio.microsoft.com/download/pr/98910750-2644-472c-ab2b-17f315ccb953/c2a4c223ee11e2eec7d13744e7a45547/aspnetcore-runtime-3.1.32-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddNetCore31Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet-core/3.1
  if not Dependency_IsNetCoreInstalled('Microsoft.WindowsDesktop.App 3.1.32') then begin
    Dependency_Add('netcore31desktop' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 3.1.32' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/3f353d2c-0431-48c5-bdf6-fbbe8f901bb5/542a4af07c1df5136a98a1c2df6f3d62/windowsdesktop-runtime-3.1.32-win-x86.exe',
                        'https://download.visualstudio.microsoft.com/download/pr/b92958c6-ae36-4efa-aafe-569fced953a5/1654639ef3b20eb576174c1cc200f33a/windowsdesktop-runtime-3.1.32-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet50;
begin
  // https://dotnet.microsoft.com/download/dotnet/5.0
  if not Dependency_IsNetCoreInstalled('Microsoft.NETCore.App 5.0.17') then begin
    Dependency_Add('dotnet50' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Runtime 5.0.17' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/54683c13-6b04-4d7d-b4d4-1f055b50ea43/e99048e2840d57040e8312058853a5b9/dotnet-runtime-5.0.17-win-x86.exe', 
                        'https://download.visualstudio.microsoft.com/download/pr/a0832b5a-6900-442b-af79-6ffddddd6ba4/e2df0b25dd851ee0b38a86947dd0e42e/dotnet-runtime-5.0.17-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet50Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet/5.0
  if not Dependency_IsNetCoreInstalled('Microsoft.AspNetCore.App 5.0.17') then begin
    Dependency_Add('dotnet50asp' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 5.0.17' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/4bfa247d-321d-4b29-a34b-62320849059b/8df7a17d9aad4044efe9b5b1c423e82c/aspnetcore-runtime-5.0.17-win-x86.exe', 
                        'https://download.visualstudio.microsoft.com/download/pr/3789ec90-2717-424f-8b9c-3adbbcea6c16/2085cc5ff077b8789ff938015392e406/aspnetcore-runtime-5.0.17-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet50Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet/5.0
  if not Dependency_IsNetCoreInstalled('Microsoft.WindowsDesktop.App 5.0.17') then begin
    Dependency_Add('dotnet50desktop' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 5.0.17' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/b6fe5f2a-95f4-46f1-9824-f5994f10bc69/db5ec9b47ec877b5276f83a185fdb6a0/windowsdesktop-runtime-5.0.17-win-x86.exe',
                        'https://download.visualstudio.microsoft.com/download/pr/3aa4e942-42cd-4bf5-afe7-fc23bd9c69c5/64da54c8864e473c19a7d3de15790418/windowsdesktop-runtime-5.0.17-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet60;
begin
  // https://dotnet.microsoft.com/download/dotnet/6.0
  if not Dependency_IsNetCoreInstalled('Microsoft.NETCore.App 6.0.20') then begin
    Dependency_Add('dotnet60' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Runtime 6.0.20' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/3be5ee3a-c171-4cd2-ab98-00ca5c11eb8c/6fd31294b0c6c670ab5c060592935203/dotnet-runtime-6.0.20-win-x86.exe', 
                        'https://download.visualstudio.microsoft.com/download/pr/3cfb6d2a-afbe-4ae7-8e5b-776f350654cc/6e8d858a60fe15381f3c84d8ca66c4a7/dotnet-runtime-6.0.20-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet60Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet/6.0
  if not Dependency_IsNetCoreInstalled('Microsoft.AspNetCore.App 6.0.20') then begin
    Dependency_Add('dotnet60asp' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 6.0.20' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/0e37c76c-53b4-4eea-8f5c-6ad2f8d5fe3c/88a8620329ced1aee271992a5b56d236/aspnetcore-runtime-6.0.20-win-x86.exe', 
                        'https://download.visualstudio.microsoft.com/download/pr/be9f67fd-60af-45b1-9bca-a7bcc0e86e7e/6a750f7d7432937b3999bb4c5325062a/aspnetcore-runtime-6.0.20-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet60Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet/6.0
  if not Dependency_IsNetCoreInstalled('Microsoft.WindowsDesktop.App 6.0.14') then begin
    Dependency_Add('dotnet60desktop' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 6.0.14' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/0413b619-3eb2-4178-a78e-8d1aafab1a01/5247f08ea3c13849b68074a2142fbf31/windowsdesktop-runtime-6.0.20-win-x86.exe', 
                        'https://download.visualstudio.microsoft.com/download/pr/1146f414-17c7-4184-8b10-1addfa5315e4/39db5573efb029130add485566320d74/windowsdesktop-runtime-6.0.20-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet70;
begin
  // https://dotnet.microsoft.com/download/dotnet/7.0
  if not Dependency_IsNetCoreInstalled('Microsoft.NETCore.App 7.0.9') then begin
    Dependency_Add('dotnet70' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Runtime 7.0.9' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/305a85f5-2b0d-459b-b2ea-caf71b98d25d/805edc610efa49432e5e268bbba4eacb/dotnet-runtime-7.0.9-win-x86.exe', 
                        'https://download.visualstudio.microsoft.com/download/pr/73058888-02a4-4f6d-b3cd-845531c2d7d0/a785e54b7f12046c00714b2ba759e173/dotnet-runtime-7.0.9-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet70Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet/7.0
  if not Dependency_IsNetCoreInstalled('Microsoft.AspNetCore.App 7.0.9') then begin
    Dependency_Add('dotnet70asp' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 7.0.9' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/6ec3b357-31df-4b18-948f-4979a5b4b99f/fdeec71fc7f0f34ecfa0cb8b2b897da0/aspnetcore-runtime-7.0.9-win-x86.exe', 
                        'https://download.visualstudio.microsoft.com/download/pr/edd9c9b1-0c49-4297-9197-9392b2462318/d06fedaefb256d801ce94ade76af3ad9/aspnetcore-runtime-7.0.9-win-x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDotNet70Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet/7.0
  if not Dependency_IsNetCoreInstalled('Microsoft.WindowsDesktop.App 7.0.9') then begin
    Dependency_Add('dotnet70desktop' + Dependency_ArchSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 7.0.9' + Dependency_ArchTitle,
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/139b19d0-2d39-48ce-b59a-aec437509c20/ea6a2711eec53660c3b14d78b9fb2963/windowsdesktop-runtime-7.0.9-win-x86.exe', 
                        'https://download.visualstudio.microsoft.com/download/pr/7727acb3-25ca-473b-a392-75afeb33cab7/f11f0477fd2fcfbb3111881377d0c9bb/windowsdesktop-runtime-7.0.9-win-x64.exe'),
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
      Dependency_String('https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE', 
                        'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE'),
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
      Dependency_String('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe',
                        'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe'),
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
      Dependency_String('https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe',
                        'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe'),
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
      Dependency_String('https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe',
                        'https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe'),
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
      Dependency_String('https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe',
                        'https://download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddVC2015To2022;
begin
  // https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist
  if not IsMsiProductInstalled(Dependency_String('{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}'), PackVersionComponents(14, 30, 30704, 0)) then begin
    Dependency_Add('vcredist2022' + Dependency_ArchSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2015-2022 Redistributable' + Dependency_ArchTitle,
      Dependency_String('https://aka.ms/vs/17/release/vc_redist.x86.exe',
                        'https://aka.ms/vs/17/release/vc_redist.x64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddDirectX;
begin
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
      Dependency_String('https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR32_x86_ENU.exe',
                        'https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR_x64_ENU.exe'),
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
      Dependency_String('https://download.microsoft.com/download/B/D/E/BDE8FAD6-33E5-44F6-B714-348F73E602B6/SQLEXPR32_x86_ENU.exe',
                        'https://download.microsoft.com/download/B/D/E/BDE8FAD6-33E5-44F6-B714-348F73E602B6/SQLEXPR_x64_ENU.exe'),
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
      Dependency_String('https://download.microsoft.com/download/3/9/F/39F968FA-DEBB-4960-8F9E-0E7BB3035959/SQLEXPR32_x86_ENU.exe',
                        'https://download.microsoft.com/download/3/9/F/39F968FA-DEBB-4960-8F9E-0E7BB3035959/SQLEXPR_x64_ENU.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddSql2016Express;
var
  Version: String;
  PackedVersion: Int64;
begin
  // https://www.microsoft.com/en-us/download/details.aspx?id=56840
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
  // https://www.microsoft.com/it-it/sql-server/sql-server-downloads
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
  if not RegValueExists(HKLM, Dependency_String('SOFTWARE', 'SOFTWARE\WOW6432Node') + '\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv') then begin
    Dependency_Add('MicrosoftEdgeWebview2Setup.exe',
      '/silent /install',
      'WebView2 Runtime',
      'https://go.microsoft.com/fwlink/p/?LinkId=2124703',
      '', False, False);
  end;
end;

procedure Dependency_AddAccessDatabaseEngine2010;
var
  Url: String;
begin
  // It could be done with CustomMessages for each language but in this way you don't have to define all those language for your installation!
  case ('{language}') of
    'de': Url := Dependency_String('https://download.microsoft.com/download/0/6/A/06AD225D-42E3-4A58-A35C-71CCF694C9C6/AccessDatabaseEngine.exe',
                                   'https://download.microsoft.com/download/0/6/A/06AD225D-42E3-4A58-A35C-71CCF694C9C6/AccessDatabaseEngine_X64.exe');
    'it': Url := Dependency_String('https://download.microsoft.com/download/6/5/4/654253A4-3067-474D-A6D2-43EFE4943E3B/AccessDatabaseEngine.exe',
                                   'https://download.microsoft.com/download/6/5/4/654253A4-3067-474D-A6D2-43EFE4943E3B/AccessDatabaseEngine_X64.exe');
    'fr': Url := Dependency_String('https://download.microsoft.com/download/2/3/F/23F451FD-B61B-4DE4-82EB-ED79AA80DFF1/AccessDatabaseEngine.exe',
                                   'https://download.microsoft.com/download/2/3/F/23F451FD-B61B-4DE4-82EB-ED79AA80DFF1/AccessDatabaseEngine_X64.exe');
    'es': Url := Dependency_String('https://download.microsoft.com/download/0/B/8/0B8EFDD9-8CE5-405C-A28D-A108A63AE2FC/AccessDatabaseEngine.exe',
                                   'https://download.microsoft.com/download/0/B/8/0B8EFDD9-8CE5-405C-A28D-A108A63AE2FC/AccessDatabaseEngine_X64.exe');
  else
    Url := Dependency_String('https://download.microsoft.com/download/2/4/3/24375141-E08D-4803-AB0E-10F2E3A07AAA/AccessDatabaseEngine.exe',
                             'https://download.microsoft.com/download/2/4/3/24375141-E08D-4803-AB0E-10F2E3A07AAA/AccessDatabaseEngine_X64.exe');
  end;

  if not RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Office\14.0\Access Connectivity Engine\Engines\ACE') then begin
    Dependency_Add('AccessDatabaseEngine' + Dependency_ArchSuffix + '.exe',
      '/quiet',
      'Microsoft Access Database Engine 2010 ' + Dependency_ArchTitle,
      Url,
      '', False, False);
  end;
end;
procedure Dependency_AddAccessDatabaseEngine2016;
begin
  if not RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Office\16.0\Access Connectivity Engine\Engines\ACE') then begin
    Dependency_Add('AccessDatabaseEngine' + Dependency_ArchSuffix + '.exe',
      '/quiet',
      'Microsoft Access Database Engine 2016 ' + Dependency_ArchTitle,
      Dependency_String('https://download.microsoft.com/download/3/5/C/35C84C36-661A-44E6-9324-8786B8DBE231/accessdatabaseengine.exe',
                        'https://download.microsoft.com/download/3/5/C/35C84C36-661A-44E6-9324-8786B8DBE231/accessdatabaseengine_X64.exe'),
      '', False, False);
  end;
end;

procedure Dependency_AddCrystalReports13ForVS;
var
  Build: String;
  MinBuild: LongInt;
  Params: String;
  MustInstall: Boolean;
  Title_Operation: String;
begin
  // https://wiki.scn.sap.com/wiki/display/BOBJ/Crystal+Reports%2C+Developer+for+Visual+Studio+Downloads

  MinBuild := 4634; //Ver 13.0.34 - SP34
  if not RegQueryStringValue(HKLM, 'SOFTWARE\SAP BusinessObjects\Crystal Reports for .NET Framework 4.0\Crystal Reports', 'BuildNum', Build) then
  begin
    //New install
    MustInstall := True;
    Params := '/qb';
    Title_Operation := 'INSTALL';
  end
  else if StrToIntDef(Build, 0) < MinBuild then
  begin
    //Upgrade
    MustInstall := True;
    Params := '/qb UPGRADE=1';
    Title_Operation := 'UPGRADE';
  end
  else
  begin
    MustInstall := False;
  end;

  if MustInstall then
    Dependency_Add(Dependency_String('CR13SP34-32bit.MSI','CR13SP34-64bit.MSI'),
      Params,
      'Crystal Reports 13 for Visual Studio SP34 ' + Dependency_ArchTitle + ' ' + Title_Operation,
      Dependency_String('https://origin-az.softwaredownloads.sap.com/public/file/0020000000674342023',
                        'https://origin-az.softwaredownloads.sap.com/public/file/0020000000674412023'),
      '', False, False);
end;

[Code]
function InitializeSetup: Boolean;
begin
#ifdef UseAccessDatabaseEngine2016
  // VC2015 is a requirement of Access Database Engine 2016 so we include it so it will be installed first, if needed.
  #define UseVC2015To2022
#endif
#ifdef UseDotNet35
  Dependency_AddDotNet35;
#endif
#ifdef UseDotNet40
  Dependency_AddDotNet40;
#endif
#ifdef UseDotNet45
  Dependency_AddDotNet45;
#endif
#ifdef UseDotNet46
  Dependency_AddDotNet46;
#endif
#ifdef UseDotNet47
  Dependency_AddDotNet47;
#endif
#ifdef UseDotNet48
  Dependency_AddDotNet48;
#endif
#ifdef UseDotNet481
  Dependency_AddDotNet481;
#endif

#ifdef UseNetCore31
  #define UseNetCoreCheck
  Dependency_AddNetCore31;
#endif
#ifdef UseNetCore31Asp
  #define UseNetCoreCheck
  Dependency_AddNetCore31Asp;
#endif
#ifdef UseNetCore31Desktop
  #define UseNetCoreCheck
  Dependency_AddNetCore31Desktop;
#endif
#ifdef UseDotNet50
  #define UseNetCoreCheck
  Dependency_AddDotNet50;
#endif
#ifdef UseDotNet50Asp
  #define UseNetCoreCheck
  Dependency_AddDotNet50Asp;
#endif
#ifdef UseDotNet50Desktop
  #define UseNetCoreCheck
  Dependency_AddDotNet50Desktop;
#endif
#ifdef UseDotNet60
  #define UseNetCoreCheck
  Dependency_AddDotNet60;
#endif
#ifdef UseDotNet60Asp
  #define UseNetCoreCheck
  Dependency_AddDotNet60Asp;
#endif
#ifdef UseDotNet60Desktop
  #define UseNetCoreCheck
  Dependency_AddDotNet60Desktop;
#endif
#ifdef UseDotNet70
  #define UseNetCoreCheck
  Dependency_AddDotNet70;
#endif
#ifdef UseDotNet70Asp
  #define UseNetCoreCheck
  Dependency_AddDotNet70Asp;
#endif
#ifdef UseDotNet70Desktop
  #define UseNetCoreCheck
  Dependency_AddDotNet70Desktop;
#endif

#ifdef UseVC2005
  Dependency_AddVC2005;
#endif
#ifdef UseVC2008
  Dependency_AddVC2008;
#endif
#ifdef UseVC2010
  Dependency_AddVC2010;
#endif
#ifdef UseVC2012
  Dependency_AddVC2012;
#endif
#ifdef UseVC2013
  //Dependency_ForceX86 := True; // force 32-bit install of next dependencies
  Dependency_AddVC2013;
  //Dependency_ForceX86 := False; // disable forced 32-bit install again
#endif
#ifdef UseVC2015To2022
  Dependency_AddVC2015To2022;
#endif

#ifdef UseDirectX
  //ExtractTemporaryFile('dxwebsetup.exe');
  Dependency_AddDirectX;
#endif

#ifdef UseSql2008Express
  Dependency_AddSql2008Express;
#endif
#ifdef UseSql2012Express
  Dependency_AddSql2012Express;
#endif
#ifdef UseSql2014Express
  Dependency_AddSql2014Express;
#endif
#ifdef UseSql2016Express
  Dependency_AddSql2016Express;
#endif
#ifdef UseSql2017Express
  Dependency_AddSql2017Express;
#endif
#ifdef UseSql2019Express
  Dependency_AddSql2019Express;
#endif
#ifdef UseSql2022Express
  Dependency_AddSql2022Express;
#endif

#ifdef UseWebView2
  Dependency_AddWebView2;
#endif

#ifdef UseAccessDatabaseEngine2010
  Dependency_AddAccessDatabaseEngine2010;
#endif
#ifdef UseAccessDatabaseEngine2016
  Dependency_AddAccessDatabaseEngine2016;
#endif

#ifdef UseCrystalReports13ForVS
  Dependency_AddCrystalReports13ForVS;
#endif
  Result := True;
end;

[Files]
#ifdef UseNetCoreCheck
  ; download netcorecheck.exe: https://go.microsoft.com/fwlink/?linkid=2135256
  ; download netcorecheck_x64.exe: https://go.microsoft.com/fwlink/?linkid=2135504
  Source: "dependencies\netcorecheck.exe"; Flags: dontcopy noencryption
  Source: "dependencies\netcorecheck_x64.exe"; Flags: dontcopy noencryption
#endif
