// requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2
// https://dotnet.microsoft.com/download/dotnet-core/3.1

[CustomMessages]
netcore31desktop_title=.NET Desktop Runtime 3.1.10 (x86)
netcore31desktop_title_x64=.NET Desktop Runtime 3.1.10 (x64)

netcore31desktop_size=46 MB
netcore31desktop_size_x64=52 MB

[Code]
const
	netcore31desktop_url = 'https://download.visualstudio.microsoft.com/download/pr/865d0be5-16e2-4b3d-a990-f4c45acd280c/ec867d0a4793c0b180bae85bc3a4f329/windowsdesktop-runtime-3.1.10-win-x86.exe';
	netcore31desktop_url_x64 = 'https://download.visualstudio.microsoft.com/download/pr/513acf37-8da2-497d-bdaa-84d6e33c1fee/eb7b010350df712c752f4ec4b615f89d/windowsdesktop-runtime-3.1.10-win-x64.exe';

procedure netcore31desktop();
begin
	if not netcoreinstalled(Desktop, '3.1.10') then begin
		AddProduct('netcore31desktop' + GetArchitectureString() + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			CustomMessage('netcore31desktop_title' + GetArchitectureString()),
			CustomMessage('netcore31desktop_size' + GetArchitectureString()),
			GetString(netcore31desktop_url, netcore31desktop_url_x64),
			'', False, False, False);
	end;
end;
