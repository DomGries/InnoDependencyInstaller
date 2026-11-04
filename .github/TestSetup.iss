; Minimal setup used by .github/workflows/install-test.yml to verify that
; dependencies actually install and are detected as installed afterwards.

#include "..\CodeDependencies.iss"

[Setup]
AppName=DependencyInstallTest
AppVersion=1.0
CreateAppDir=no
Uninstallable=no
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible or arm64
OutputBaseFilename=TestSetup

[Code]
function InitializeSetup: Boolean;
begin
  // fast dependencies with native arm64 installers
  Dependency_AddVC14;
  Dependency_AddDotNet80Desktop;
  Dependency_AddWebView2;
  Dependency_AddSqlOdbc18;

  // x64-only installers
  if not Dependency_IsArm64 then begin
    Dependency_AddVC2013;
    Dependency_AddAccessDatabaseEngine2016;
    Dependency_AddVSTORuntime;
  end;

  Dependency_AddWinAppRuntime16;
  Dependency_AddWinAppRuntime2;

  Result := True;
end;
