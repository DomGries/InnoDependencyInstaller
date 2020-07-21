; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2
; https://dotnet.microsoft.com/download/dotnet-core/3.1

[CustomMessages]
netcore31asp_title=ASP.NET Core 3.1
netcore31asp_title_x64=ASP.NET Core 3.1 64-Bit

netcore31asp_size=1 MB - 7 MB
netcore31asp_size_x64=1 MB - 8 MB

[Code]
const
	netcore31asp_url = 'http://download.visualstudio.microsoft.com/download/pr/ac814d0a-67b7-4ef2-86c7-27afbdbf68a0/655424a5eb8f37b330b46130cb9e795b/aspnetcore-runtime-3.1.6-win-x86.exe';
	netcore31asp_url_x64 = 'http://download.visualstudio.microsoft.com/download/pr/08874f02-fa49-4601-8234-a4adaf7be8ac/ad7e7cda61502321c08b99e297de334f/aspnetcore-runtime-3.1.6-win-x64.exe';

procedure netcore31asp();
begin
	if (not IsIA64()) then begin
		if not netcoreversioninstalled(Asp, NetC31) then
			AddProduct('netcore31asp' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('netcore31asp_title' + GetArchitectureString()),
				CustomMessage('netcore31asp_size' + GetArchitectureString()),
				GetString(netcore31asp_url, netcore31asp_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
