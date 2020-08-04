; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2
; https://dotnet.microsoft.com/download/dotnet-core/3.1

[CustomMessages]
netcore31desktop_title=Desktop Runtime 3.1.6 (x86)
netcore31desktop_title_x64=Desktop Runtime 3.1.6 (x64)

netcore31desktop_size=1 MB - 23 MB
netcore31desktop_size_x64=1 MB - 26 MB

[Files]
; includes netcorecheck.exe in setup executable so that we don't need to download it
Source: "src\netcorecheck_x86.exe"; Flags: dontcopy
Source: "src\netcorecheck_x64.exe"; Flags: dontcopy

[Code]
const
	netcore31desktop_url = 'http://go.microsoft.com/fwlink/?linkid=2137844';
	netcore31desktop_url_x64 = 'http://go.microsoft.com/fwlink/?linkid=2137941';

procedure netcore31desktop();
begin
	if (not IsIA64()) then begin
		ExtractTemporaryFile('netcorecheck' + GetArchitectureString() + '.exe');

		if not netcoreversioninstalled(Desktop, NetC31, 6) then
			AddProduct('netcore31desktop' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('netcore31desktop_title' + GetArchitectureString()),
				CustomMessage('netcore31desktop_size' + GetArchitectureString()),
				GetString(netcore31desktop_url, netcore31desktop_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
