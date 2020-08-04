; .NET 5.0 is currently in preview. This product and netcoreversion.iss will be updated upon it's release.
; https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50desktop_title=Desktop Runtime 5.0 (x86) Preview 6
dotnet50desktop_title_x64=Desktop Runtime 5.0 (x64) Preview 6

dotnet50desktop_size=1 MB - 49 MB
dotnet50desktop_size_x64=1 MB - 53 MB

[Files]
; includes netcorecheck.exe in setup executable so that we don't need to download it
Source: "src\netcorecheck_x86.exe"; Flags: dontcopy
Source: "src\netcorecheck_x64.exe"; Flags: dontcopy

[Code]
const
	dotnet50desktop_url = 'http://go.microsoft.com/fwlink/?linkid=2137841';
	dotnet50desktop_url_x64 = 'http://go.microsoft.com/fwlink/?linkid=2137938';

procedure dotnet50desktop();
begin
	if (not IsIA64()) then begin
		ExtractTemporaryFile('netcorecheck' + GetArchitectureString() + '.exe');

		if not netcoreversioninstalled(Desktop, Net50, 7) then
			AddProduct('dotnet50desktop' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('dotnet50desktop_title' + GetArchitectureString()),
				CustomMessage('dotnet50desktop_size' + GetArchitectureString()),
				GetString(dotnet50desktop_url, dotnet50desktop_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
