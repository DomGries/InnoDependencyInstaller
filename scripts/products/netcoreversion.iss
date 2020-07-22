[Code]
type
	NetCoreRuntimeType = (Asp, Core, Desktop);
	NetCoreVersionType = (NetC31, Net50);

const
	netcorecheck_url = 'http://go.microsoft.com/fwlink/?linkid=2135256';
	netcorecheck_url_x64 = 'http://go.microsoft.com/fwlink/?linkid=2135504';

function downloadnetcorecheck(): Boolean;
var
	filename, path: string;
begin
	Result := true;
	filename := 'netcorecheck.exe';
	path := ExpandConstant('{src}{\}') + CustomMessage('DependenciesDir') + '\' + filename;
	if not FileExists(path) then begin
		path := ExpandConstant('{tmp}{\}') + filename;

		if not FileExists(path) then begin
			isxdl_AddFile(GetString(netcorecheck_url, netcorecheck_url_x64, ''), path);
			if isxdl_DownloadFiles(StrToInt(ExpandConstant('{wizardhwnd}'))) = 0 then begin
				Result := false;
			end;
		end;
	end;
end;

function netcorecheck(runtime: string; version: string): Boolean;
var
	exePath: string;
	execStdout: ansistring;
	resultCode: integer;
begin
	Result := false;
	if downloadnetcorecheck() then begin
		exePath := ExpandConstant('{tmp}') + '\netcorecheck.exe';
		Exec(exePath, runtime + ' ' + version, '', SW_HIDE, ewWaitUntilTerminated, resultCode);
		if IntToStr(resultCode) = '0' then
			Result := true;
	end;
end;

function netcoreversioninstalled(runtime: NetCoreRuntimeType; version: NetCoreVersionType): Boolean;
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
			netcoreVersion := '3.1.0';
		Net50:
			netcoreVersion := '5.0.0-preview.7.20364.11';
	end;

	if netcorecheck(netcoreRuntime, netcoreVersion) then
		Result := true;
end;

[Setup]
