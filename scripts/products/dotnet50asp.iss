; .NET 5.0 is currently in preview. This product and netcoreversion.iss will be updated upon it's release.
; https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50asp_title=ASP.NET Core Runtime 5.0
dotnet50asp_title_x64=ASP.NET Core Runtime 5.0 64-Bit

dotnet50asp_size=1 MB - 8 MB
dotnet50asp_size_x64=1 MB - 8 MB

[Code]
const
	dotnet50asp_url = 'http://download.visualstudio.microsoft.com/download/pr/e0f0dd65-4db3-4ea9-8ddc-0296e290b93f/23faf5910857010dd62dc0233c59fc79/aspnetcore-runtime-5.0.0-preview.7.20365.19-win-x86.exe';
	dotnet50asp_url_x64 = 'http://download.visualstudio.microsoft.com/download/pr/9d2b759f-1bbb-4b00-a1b9-4b191c074254/cf51d83f10a4dd9327edd7a238cde6ec/aspnetcore-runtime-5.0.0-preview.7.20365.19-win-x64.exe';

procedure dotnet50asp();
begin
	if (not IsIA64()) then begin
		if not netcoreversioninstalled(Asp, Net50) then
			AddProduct('dotnet50asp' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('dotnet50asp_title' + GetArchitectureString()),
				CustomMessage('dotnet50asp_size' + GetArchitectureString()),
				GetString(dotnet50asp_url, dotnet50asp_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
