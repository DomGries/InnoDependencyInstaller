; .NET 5.0 is currently in preview. This product and netcoreversion.iss will be updated upon it's release.
; https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50desktop_title=.NET Desktop Runtime 5.0 Preview 6 (x86)
dotnet50desktop_title_x64=.NET Desktop Runtime 5.0 Preview 6 (x64)

dotnet50desktop_size=49 MB
dotnet50desktop_size_x64=53 MB

[Code]
const
	dotnet50desktop_url = 'http://go.microsoft.com/fwlink/?linkid=2137841';
	dotnet50desktop_url_x64 = 'http://go.microsoft.com/fwlink/?linkid=2137938';

procedure dotnet50desktop();
begin
	if (not IsIA64()) then begin
		if not netcoreinstalled(Desktop, '5.0.0-preview.6.20308.1') then
			AddProduct('dotnet50desktop' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('dotnet50desktop_title' + GetArchitectureString()),
				CustomMessage('dotnet50desktop_size' + GetArchitectureString()),
				GetString(dotnet50desktop_url, dotnet50desktop_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
