; https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50_title=.NET Runtime 5.0 Preview 6 (x86)
dotnet50_title_x64=.NET Runtime 5.0 Preview 6 (x64)

dotnet50_size=24 MB
dotnet50_size_x64=27 MB

[Code]
const
	dotnet50_url = 'http://go.microsoft.com/fwlink/?linkid=2137843';
	dotnet50_url_x64 = 'http://go.microsoft.com/fwlink/?linkid=2137842';

procedure dotnet50();
begin
	if (not IsIA64()) then begin
		if not netcoreinstalled(Core, '5.0.0-preview.6.20305.6') then
			AddProduct('dotnet50' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('dotnet50_title' + GetArchitectureString()),
				CustomMessage('dotnet50_size' + GetArchitectureString()),
				GetString(dotnet50_url, dotnet50_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
