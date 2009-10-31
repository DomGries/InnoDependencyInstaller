#include "scripts\products.iss"

#include "scripts\products\winversion.iss"
#include "scripts\products\fileversion.iss"

//#include "scripts\products\iis.iss"

//#include "scripts\products\kb835732.iss"
//#include "scripts\products\kb886903.iss"
//#include "scripts\products\kb928366.iss"

//#include "scripts\products\msi20.iss"
#include "scripts\products\msi31.iss"
//#include "scripts\products\ie6.iss"

#include "scripts\products\dotnetfx11.iss"
#include "scripts\products\dotnetfx11lp.iss"
#include "scripts\products\dotnetfx11sp1.iss"

#include "scripts\products\dotnetfx20.iss"
#include "scripts\products\dotnetfx20lp.iss"
#include "scripts\products\dotnetfx20sp1.iss"
#include "scripts\products\dotnetfx20sp1lp.iss"
#include "scripts\products\dotnetfx20sp2.iss"
#include "scripts\products\dotnetfx20sp2lp.iss"

#include "scripts\products\dotnetfx35.iss"
#include "scripts\products\dotnetfx35lp.iss"
#include "scripts\products\dotnetfx35sp1.iss"
#include "scripts\products\dotnetfx35sp1lp.iss"

//#include "scripts\products\mdac28.iss"
//#include "scripts\products\jet4sp8.iss"
//#include "scripts\products\sql2005express.iss"

[CustomMessages]
win2000sp3_title=Windows 2000 Service Pack 3
winxpsp2_title=Windows XP Service Pack 2


[Setup]
AppName=MyProgram
AppVersion=3.0
AppVerName=MyProgram 3.0
AppCopyright=Copyright © stfx 2007-2009
VersionInfoVersion=3.0
VersionInfoCompany=stfx
AppPublisher=stfx
;AppPublisherURL=http://...
;AppSupportURL=http://...
;AppUpdatesURL=http://...
OutputBaseFilename=MyProgram-3.0
DefaultGroupName=MyProgram
DefaultDirName={pf}\MyProgram
UninstallDisplayIcon={app}\MyProgram.exe
UninstallDisplayName=MyProgram
Uninstallable=yes
CreateUninstallRegKey=yes
UpdateUninstallLogAppName=yes
CreateAppDir=yes
OutputDir=bin
SourceDir=.
AllowNoIcons=yes
;SetupIconFile=MyProgramIcon
LanguageDetectionMethod=uilanguage
InternalCompressLevel=fast
SolidCompression=yes
Compression=lzma/fast

MinVersion=4.1,5.0
PrivilegesRequired=admin
ArchitecturesAllowed=x86 x64 ia64
ArchitecturesInstallIn64BitMode=x64 ia64

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "src\MyProgram-x64.exe"; DestDir: "{app}"; DestName: "MyProg.exe"; Check: IsX64
Source: "src\MyProgram-IA64.exe"; DestDir: "{app}"; DestName: "MyProg.exe"; Check: IsIA64
Source: "src\MyProgram.exe"; DestDir: "{app}"; Check: not Is64BitInstallMode

[Icons]
Name: "{group}\MyProgram"; Filename: "{app}\MyProgram"
Name: "{group}\{cm:UninstallProgram,MyProgram}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\MyProgram"; Filename: "{app}\MyProgram.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\MyProgram"; Filename: "{app}\MyProgram.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\MyProgram.exe"; Description: "{cm:LaunchProgram,MyProgram}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
	//init windows version
	initwinversion();
	
	//check if dotnetfx20 can be installed on this OS
	//if not minwinspversion(5, 0, 3) then begin
	//	MsgBox(FmtMessage(CustomMessage('depinstall_missing'), [CustomMessage('win2000sp3_title')]), mbError, MB_OK);
	//	exit;
	//end;
	//if not minwinspversion(5, 1, 2) then begin
	//	MsgBox(FmtMessage(CustomMessage('depinstall_missing'), [CustomMessage('winxpsp2_title')]), mbError, MB_OK);
	//	exit;
	//end;
	
	//if (not iis()) then exit;
	
	//msi20('2.0');
	msi31('3.1');
	//ie6('5.0.2919');
	
	dotnetfx11();
	dotnetfx11lp();
	dotnetfx11sp1();
	//kb886903(); //better use windows update
	//kb928366(); //better use windows update
	
	//install .netfx 2.0 sp2 if possible; if not sp1 if possible; if not .netfx 2.0
	//if minwinversion(5, 1) then begin
		dotnetfx20sp2();
		dotnetfx20sp2lp();
	//end else begin
	//	if minwinversion(5, 0) and minwinspversion(5, 0, 4) then begin
	//		kb835732();
			dotnetfx20sp1();
			dotnetfx20sp1lp();
	//	end else begin
			dotnetfx20();
			dotnetfx20lp();
	//	end;
	//end;
	
	dotnetfx35();
	dotnetfx35lp();
	dotnetfx35sp1();
  dotnetfx35sp1lp();
	
	//mdac28('2.7');
	//jet4sp8('4.0.8015');
	//sql2005express();
	
	Result := true;
end;


