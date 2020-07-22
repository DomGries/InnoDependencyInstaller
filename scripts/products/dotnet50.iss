; .NET 5.0 is currently in preview. This product and netcoreversion.iss will be updated upon it's release.
; https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50_title=.NET Runtime 5.0
dotnet50_title_x64=.NET Runtime 5.0 64-Bit

dotnet50_size=1 MB - 24 MB
dotnet50_size_x64=1 MB - 27 MB

[Code]
const
	dotnet50_url = 'http://download.visualstudio.microsoft.com/download/pr/2db260ef-40ba-4cce-8666-7de8b879e9a9/a4f4a0671b4e8899c217354e9d8371a8/dotnet-runtime-5.0.0-preview.7.20364.11-win-x86.exe';
	dotnet50_url_x64 = 'http://download.visualstudio.microsoft.com/download/pr/203aff04-57b2-4183-9d24-daf502fb9599/cf85a20cc0de18dd31f199c8f8528601/dotnet-runtime-5.0.0-preview.7.20364.11-win-x64.exe';

procedure dotnet50();
begin
	if (not IsIA64()) then begin
		if not netcoreversioninstalled(Core, Net50) then
			AddProduct('dotnet50' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('dotnet50_title' + GetArchitectureString()),
				CustomMessage('dotnet50_size' + GetArchitectureString()),
				GetString(dotnet50_url, dotnet50_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
