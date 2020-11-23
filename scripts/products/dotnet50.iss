// https://dotnet.microsoft.com/download/dotnet/5.0

[Code]
procedure dotnet50;
begin
	if not netcoreinstalled(Core, '5.0.0') then begin
		AddProduct('dotnet50' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Runtime 5.0' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/a7e15da3-7a15-43c2-a481-cf50bf305214/c69b951e8b47101e90b1289c387bb01a/dotnet-runtime-5.0.0-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/36a9dc4e-1745-4f17-8a9c-f547a12e3764/ae25e38f20a4854d5e015a88659a22f9/dotnet-runtime-5.0.0-win-x64.exe'),
			'', False, False, False);
	end;
end;
