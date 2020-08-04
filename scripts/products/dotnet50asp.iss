; .NET 5.0 is currently in preview. This product and netcoreversion.iss will be updated upon it's release.
; https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50asp_title=ASP.NET Core Runtime 5.0 (x86) Preview 6
dotnet50asp_title_x64=ASP.NET Core Runtime 5.0 (x64) Preview 6

dotnet50asp_size=1 MB - 8 MB
dotnet50asp_size_x64=1 MB - 8 MB

[Code]
const
	dotnet50asp_url = 'http://go.microsoft.com/fwlink/?linkid=2137840';
	dotnet50asp_url_x64 = 'http://go.microsoft.com/fwlink/?linkid=2137639';

procedure dotnet50asp();
begin
	if (not IsIA64()) then begin
		if not netcoreinstalled(Asp, '5.0.0-preview.6.20312.15') then
			AddProduct('dotnet50asp' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('dotnet50asp_title' + GetArchitectureString()),
				CustomMessage('dotnet50asp_size' + GetArchitectureString()),
				GetString(dotnet50asp_url, dotnet50asp_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
