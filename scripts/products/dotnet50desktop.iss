; .NET 5.0 is currently in preview. This product and netcoreversion.iss will be updated upon it's release.
; https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50desktop_title=Desktop Runtime 5.0
dotnet50desktop_title_x64=Desktop Runtime 5.0 64-Bit

dotnet50desktop_size=1 MB - 49 MB
dotnet50desktop_size_x64=1 MB - 53 MB

[Code]
const
	dotnet50desktop_url = 'http://download.visualstudio.microsoft.com/download/pr/d12f1c16-2d25-4a7f-a3cb-cf839b07526a/b9ac0cb450e8563a2272510a379511fc/windowsdesktop-runtime-5.0.0-preview.7.20366.1-win-x86.exe';
	dotnet50desktop_url_x64 = 'http://download.visualstudio.microsoft.com/download/pr/b1ad0793-f281-4574-b672-09ac4bd6ff9c/303e98093e01e9b10a425d58b26bb601/windowsdesktop-runtime-5.0.0-preview.7.20366.1-win-x64.exe';

procedure dotnet50desktop();
begin
	if (not IsIA64()) then begin
		if not netcoreversioninstalled(Desktop, Net50) then
			AddProduct('dotnet50desktop' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('dotnet50desktop_title' + GetArchitectureString()),
				CustomMessage('dotnet50desktop_size' + GetArchitectureString()),
				GetString(dotnet50desktop_url, dotnet50desktop_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
