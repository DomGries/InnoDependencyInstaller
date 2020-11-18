// NetCoreCheck tool is necessary for detecting if a specific version of .NET Core/.NET 5.0 is installed: https://github.com/dotnet/runtime/issues/36479
// source code: https://github.com/dotnet/deployment-tools/tree/master/src/clickonce/native/projects/NetCoreCheck
// download netcorecheck.exe: https://go.microsoft.com/fwlink/?linkid=2135256
// download netcorecheck_x64.exe: https://go.microsoft.com/fwlink/?linkid=2135504

[Files]
Source: "src\netcorecheck.exe"; Flags: dontcopy noencryption
Source: "src\netcorecheck_x64.exe"; Flags: dontcopy noencryption

[Code]
type
	NetCoreRuntimeType = (Asp, Core, Desktop);

function netcoreinstalled(runtime: NetCoreRuntimeType; version: String): Boolean;
var
	netcoreRuntime: String;
	resultCode: Integer;
begin
	case runtime of
		Asp: begin
			netcoreRuntime := 'Microsoft.AspNetCore.App';
		end;
		Core: begin
			netcoreRuntime := 'Microsoft.NETCore.App';
		end;
		Desktop: begin
			netcoreRuntime := 'Microsoft.WindowsDesktop.App';
		end;
	end;

	if not FileExists(ExpandConstant('{tmp}{\}') + 'netcorecheck' + GetArchitectureString() + '.exe') then begin
		ExtractTemporaryFile('netcorecheck' + GetArchitectureString() + '.exe');
	end;

	Result := Exec(ExpandConstant('{tmp}{\}') + 'netcorecheck' + GetArchitectureString() + '.exe', netcoreRuntime + ' ' + version, '', SW_HIDE, ewWaitUntilTerminated, resultCode) and (resultCode = 0);
end;
