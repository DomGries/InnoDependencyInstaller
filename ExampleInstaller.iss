#define UseDotNet35
#define UseDotNet40
#define UseDotNet45
#define UseDotNet46
#define UseDotNet47
#define UseDotNet48
#define UseDotNet481
;#define UseNetCore31
;#define UseNetCore31Asp
#define UseNetCore31Desktop
;#define UseDotNet50
;#define UseDotNet50Asp
#define UseDotNet50Desktop
;#define UseDotNet60
;#define UseDotNet60Asp
#define UseDotNet60Desktop
;#define UseDotNet70
;#define UseDotNet70Asp
#define UseDotNet70Desktop

#define UseVC2005
#define UseVC2008
#define UseVC2010
#define UseVC2012
#define UseVC2013
#define UseVC2015To2022

#define UseDirectX

;#define UseSql2008Express
;#define UseSql2012Express
;#define UseSql2014Express
;#define UseSql2016Express
;#define UseSql2017Express
;#define UseSql2019Express
;#define UseSql2022Express

#define UseWebView2

#define UseAccessDatabaseEngine2010
#define UseAccessDatabaseEngine2016

#include "CodeDependencies.iss"
;+-----+----------------------------------------+
;| END | Modular InnoSetup Dependency Installer |
;+-----+----------------------------------------+
[Setup]
#define MyAppSetupName 'MyProgram'
#define MyAppVersion '1.0'
#define MyAppPublisher 'Inno Setup'
#define MyAppCopyright 'Copyright (c) Inno Setup'
#define MyAppURL 'https://jrsoftware.org/isinfo.php'
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
OutputDir={#SourcePath}\bin
Compression=lzma/ultra
SolidCompression=yes
InternalCompressLevel=normal
AllowNoIcons=yes
PrivilegesRequired=admin
; remove next line if you only deploy 32-bit binaries and dependencies
ArchitecturesInstallIn64BitMode=x64
WizardStyle=modern

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"
Name: nl; MessagesFile: "compiler:Languages\Dutch.isl"
Name: de; MessagesFile: "compiler:Languages\German.isl"
Name: it; MessagesFile: "compiler:Languages\Italian.isl"
Name: fr; MessagesFile: "compiler:Languages\French.isl"
Name: es; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
Source: "example\MyProg-x64.exe"; DestDir: "{app}"; DestName: "MyProg.exe"; Check: Dependency_IsX64; Flags: ignoreversion
Source: "example\MyProg.exe"; DestDir: "{app}"; Check: not Dependency_IsX64; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppSetupName}"; Filename: "{app}\MyProg.exe"
Name: "{group}\{cm:UninstallProgram,{#MyAppSetupName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppSetupName}"; Filename: "{app}\MyProg.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"

[Run]
Filename: "{app}\MyProg.exe"; Description: "{cm:LaunchProgram,{#MyAppSetupName}}"; Flags: nowait postinstall skipifsilent