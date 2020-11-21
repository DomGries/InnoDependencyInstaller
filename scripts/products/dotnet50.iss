// https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50_title=.NET Runtime 5.0 (x86)
dotnet50_title_x64=.NET Runtime 5.0 (x64)

dotnet50_size=23 MB
dotnet50_size_x64=25 MB

[Code]
const
	dotnet50_url = 'https://download.visualstudio.microsoft.com/download/pr/a7e15da3-7a15-43c2-a481-cf50bf305214/c69b951e8b47101e90b1289c387bb01a/dotnet-runtime-5.0.0-win-x86.exe';
	dotnet50_url_x64 = 'https://download.visualstudio.microsoft.com/download/pr/36a9dc4e-1745-4f17-8a9c-f547a12e3764/ae25e38f20a4854d5e015a88659a22f9/dotnet-runtime-5.0.0-win-x64.exe';

procedure dotnet50();
begin
	if not IsIA64() and not netcoreinstalled(Core, '5.0.0') then begin
		AddProduct('dotnet50' + GetArchitectureString() + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			CustomMessage('dotnet50_title' + GetArchitectureString()),
			CustomMessage('dotnet50_size' + GetArchitectureString()),
			GetString(dotnet50_url, dotnet50_url_x64, ''),
			'', False, False, False);
	end;
end;
