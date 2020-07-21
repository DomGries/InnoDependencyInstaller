; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2
; https://dotnet.microsoft.com/download/dotnet-core/3.1

[CustomMessages]
netcore31desktop_title=Desktop Runtime 3.1
netcore31desktop_title_x64=Desktop Runtime 3.1 64-Bit

netcore31desktop_size=1 MB - 48 MB
netcore31desktop_size_x64=1 MB - 54 MB

[Code]
const
	netcore31desktop_url = 'http://download.visualstudio.microsoft.com/download/pr/d5fc4fb5-7374-4886-8815-68b7bf788b5b/3aeb172d4a3c5e01078738440442f4c7/windowsdesktop-runtime-3.1.6-win-x86.exe';
	netcore31desktop_url_x64 = 'http://download.visualstudio.microsoft.com/download/pr/3eb7efa1-96c6-4e97-bb9f-563ecf595f8a/7efd9c1cdd74df8fb0a34c288138a84f/windowsdesktop-runtime-3.1.6-win-x64.exe';

procedure netcore31desktop();
begin
	if (not IsIA64()) then begin
		if not netcoreversioninstalled(Desktop, NetC31) then
			AddProduct('netcore31desktop' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('netcore31desktop_title' + GetArchitectureString()),
				CustomMessage('netcore31desktop_size' + GetArchitectureString()),
				GetString(netcore31desktop_url, netcore31desktop_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
