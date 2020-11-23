// https://github.com/dotnet/deployment-tools/tree/master/src/clickonce/native/projects/NetCoreCheck
// download netcorecheck.exe: https://go.microsoft.com/fwlink/?linkid=2135256
// download netcorecheck_x64.exe: https://go.microsoft.com/fwlink/?linkid=2135504

[Files]
Source: "src\netcorecheck.exe"; Flags: dontcopy noencryption
Source: "src\netcorecheck_x64.exe"; Flags: dontcopy noencryption

[Code]
function netcoreinstalled(Version: String): Boolean;
var
	ResultCode: Integer;
begin
	if not FileExists(ExpandConstant('{tmp}{\}') + 'netcorecheck' + GetArchitectureSuffix + '.exe') then begin
		ExtractTemporaryFile('netcorecheck' + GetArchitectureSuffix + '.exe');
	end;
	Result := Exec(ExpandConstant('{tmp}{\}') + 'netcorecheck' + GetArchitectureSuffix + '.exe', Version, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;
