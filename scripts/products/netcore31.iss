; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2
; https://dotnet.microsoft.com/download/dotnet-core/3.1

[CustomMessages]
netcore31_title=.NET Core Runtime 3.1.6 (x86)
netcore31_title_x64=.NET Core Runtime 3.1.6 (x64)

netcore31_size=1 MB - 23 MB
netcore31_size_x64=1 MB - 26 MB

[Files]
; includes netcorecheck.exe in setup executable so that we don't need to download it
Source: "src\netcorecheck.exe"; Flags: dontcopy
Source: "src\netcorecheck_x64.exe"; Flags: dontcopy

[Code]
const
	netcore31_url = 'http://go.microsoft.com/fwlink/?linkid=2137641';
	netcore31_url_x64 = 'http://go.microsoft.com/fwlink/?linkid=2137640';

procedure netcore31();
begin
	if (not IsIA64()) then begin
		ExtractTemporaryFile('netcorecheck' + GetArchitectureString() + '.exe');

		if not netcoreversioninstalled(Core, NetC31, 6) then
			AddProduct('netcore31' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('netcore31_title' + GetArchitectureString()),
				CustomMessage('netcore31_size' + GetArchitectureString()),
				GetString(netcore31_url, netcore31_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
