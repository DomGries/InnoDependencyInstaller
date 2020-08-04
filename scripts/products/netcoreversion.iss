; NetCoreCheck tool is necessary for detecting if a specific version of .NET Core/.NET 5.0 is installed: https://github.com/dotnet/runtime/issues/36479
; source code: https://github.com/dotnet/deployment-tools/tree/master/src/clickonce/native/projects/NetCoreCheck
; download netcorecheck.exe: https://go.microsoft.com/fwlink/?linkid=2135256
; download netcorecheck_x64.exe: https://go.microsoft.com/fwlink/?linkid=2135504

[Code]
type
	NetCoreRuntimeType = (Asp, Core, Desktop);
	NetCoreVersionType = (NetC31, Net50);

function netcorecheckincluded(): Boolean;
var
	filename, path: string;
begin
	Result := false;
	filename := 'netcorecheck' + GetArchitectureString() + '.exe';
	path := ExpandConstant('{tmp}{\}') + filename;
	if FileExists(path) then
		Result := true;
end;

function netcorecheck(runtime: string; version: string): Boolean;
var
	exePath: string;
	resultCode: integer;
begin
	Result := false;
	if netcorecheckincluded() then begin
		exePath := ExpandConstant('{tmp}') + '\netcorecheck' + GetArchitectureString() + '.exe';
		Exec(exePath, runtime + ' ' + version, '', SW_HIDE, ewWaitUntilTerminated, resultCode);
		if IntToStr(resultCode) = '0' then
			Result := true;
	end;
end;

function netcoreversioninstalled(runtime: NetCoreRuntimeType; version: NetCoreVersionType; patch: integer): Boolean;
var
	netcoreRuntime: string;
	netcoreVersion: string;
begin
	Result := false;
	case runtime of
		Asp:
			netcoreRuntime := 'Microsoft.AspNetCore.App';
		Core:
			netcoreRuntime := 'Microsoft.NETCore.App';
		Desktop:
			netcoreRuntime := 'Microsoft.WindowsDesktop.App';
	end;

	case version of
		NetC31:
			netcoreVersion := '3.1.' + IntToStr(patch);
		Net50:
			case runtime of
				Asp:
					netcoreVersion := '5.0.0-preview.6.20312.15';
				Core:
					netcoreVersion := '5.0.0-preview.6.20305.6';
				Desktop:
					netcoreVersion := '5.0.0-preview.6.20308.1';
			end;
	end;

	if netcorecheck(netcoreRuntime, netcoreVersion) then
		Result := true;
end;

[Setup]
