// contribute: https://github.com/DomGries/InnoDependencyInstaller
// official article: https://codeproject.com/Articles/20868/Inno-Setup-Dependency-Installer

#include "products.iss"

// comment out dependency defines to disable installing them
#define UseMsi45

//#define UseDotNet11
#define UseDotNet20
#define UseDotNet35
#define UseDotNet40Client
#define UseDotNet40Full
#define UseDotNet45
#define UseDotNet46
#define UseDotNet47
#define UseDotNet48

// requires netcorecheck.exe and netcorecheck_x64.exe (see download link below)
#define UseNetCoreCheck
#ifdef UseNetCoreCheck
  #define UseNetCore31
  #define UseNetCore31Asp
  #define UseNetCore31Desktop
  #define UseDotNet50
  #define UseDotNet50Asp
  #define UseDotNet50Desktop
#endif

#define UseMsiProductCheck
#ifdef UseMsiProductCheck
  #define UseVC2005
  #define UseVC2008
  #define UseVC2010
  #define UseVC2012
  #define UseVC2013
  #define UseVC2015To2019
#endif

// requires dxwebsetup.exe (see download link below)
//#define UseDirectX

#define UseSql2008Express
#define UseSql2012Express
#define UseSql2014Express
#define UseSql2016Express
#define UseSql2017Express
#define UseSql2019Express


// custom setup info
#define MyAppSetupName 'MyProgram'
#define MyAppVersion '1.0'
#define MyAppPublisher 'Dom Gries'
#define MyAppCopyright 'Copyright © Dom Gries'
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
SourceDir=src
OutputDir={#SourcePath}\bin
AllowNoIcons=yes

MinVersion=6.0
PrivilegesRequired=admin

// remove next line if you only deploy 32-bit binaries and dependencies
ArchitecturesInstallIn64BitMode=x64

// dependency installation requires ready page and ready memo to be enabled (default behaviour)
DisableReadyPage=no
DisableReadyMemo=no

// custom setup content
[Languages]
Name: en; MessagesFile: "compiler:Default.isl"
Name: nl; MessagesFile: "compiler:Languages\Dutch.isl"
Name: de; MessagesFile: "compiler:Languages\German.isl"

[Files]
#ifdef UseNetCoreCheck
// download netcorecheck.exe: https://go.microsoft.com/fwlink/?linkid=2135256
// download netcorecheck_x64.exe: https://go.microsoft.com/fwlink/?linkid=2135504
Source: "netcorecheck.exe"; Flags: dontcopy noencryption
Source: "netcorecheck_x64.exe"; Flags: dontcopy noencryption
#endif

#ifdef UseDirectX
Source: "dxwebsetup.exe"; Flags: dontcopy noencryption
#endif

Source: "MyProg-x64.exe"; DestDir: "{app}"; DestName: "MyProg.exe"; Check: IDI_IsX64; Flags: ignoreversion
Source: "MyProg.exe"; DestDir: "{app}"; Check: not IDI_IsX64; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppSetupName}"; Filename: "{app}\MyProg.exe"
Name: "{group}\{cm:UninstallProgram,{#MyAppSetupName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppSetupName}"; Filename: "{app}\MyProg.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"

[Run]
Filename: "{app}\MyProg.exe"; Description: "{cm:LaunchProgram,{#MyAppSetupName}}"; Flags: nowait postinstall skipifsilent

[Code]
function NeedRestart: Boolean;
begin
  Result := IDI_NeedRestart;
end;

function UpdateReadyMemo(const Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := IDI_UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo);
end;

function NextButtonClick(const CurPageID: Integer): Boolean;
begin
  Result := IDI_NextButtonClick(CurPageID);
end;

function InitializeSetup: Boolean;
begin
#ifdef UseMsi45
  IDI_UseMsi45;
#endif

#ifdef UseDotNet11
  IDI_UseDotNet11;
#endif

#ifdef UseDotNet20
  IDI_UseDotNet20;
#endif

#ifdef UseDotNet35
  IDI_UseDotNet35;
#endif

#ifdef UseDotNet40Client
  IDI_UseDotNet40Client;
#endif

#ifdef UseDotNet40Full
  IDI_UseDotNet40Full;
#endif

#ifdef UseDotNet45
  IDI_UseDotNet45;
#endif

#ifdef UseDotNet46
  IDI_UseDotNet46;
#endif

#ifdef UseDotNet47
  IDI_UseDotNet47;
#endif

#ifdef UseDotNet48
  IDI_UseDotNet48;
#endif

#ifdef UseNetCore31
  IDI_UseNetCore31;
#endif

#ifdef UseNetCore31Asp
  IDI_UseNetCore31Asp;
#endif

#ifdef UseNetCore31Desktop
  IDI_UseNetCore31Desktop;
#endif

#ifdef UseDotNet50
  IDI_UseDotNet50;
#endif

#ifdef UseDotNet50Asp
  IDI_UseDotNet50Asp;
#endif

#ifdef UseDotNet50Desktop
  IDI_UseDotNet50Desktop;
#endif

#ifdef UseVC2005
  IDI_UseVC2005;
#endif

#ifdef UseVC2008
  IDI_UseVC2008;
#endif

#ifdef UseVC2010
  IDI_UseVC2010;
#endif

#ifdef UseVC2012
  IDI_UseVC2012;
#endif

#ifdef UseVC2013
  IDI_UseVC2013;
#endif

#ifdef UseVC2015To2019
  IDI_UseVC2015To2019;
#endif

#ifdef UseDirectX
  IDI_UseDirectX;
#endif

#ifdef UseSql2008Express
  IDI_UseSql2008Express;
#endif

#ifdef UseSql2012Express
  IDI_UseSql2012Express;
#endif

#ifdef UseSql2014Express
  IDI_UseSql2014Express;
#endif

#ifdef UseSql2016Express
  IDI_UseSql2016Express;
#endif

#ifdef UseSql2017Express
  IDI_UseSql2017Express;
#endif

#ifdef UseSql2019Express
  IDI_UseSql2019Express;
#endif

  Result := True;
end;

procedure InitializeWizard;
begin
  IDI_InitializeWizard;
end;
