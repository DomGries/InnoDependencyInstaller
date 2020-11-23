// https://dotnet.microsoft.com/download/dotnet-core/3.1

[Code]
procedure netcore31desktop;
begin
	if not netcoreinstalled('Microsoft.WindowsDesktop.App 3.1.0') then begin
		AddProduct('netcore31desktop' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Desktop Runtime 3.1.10' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/865d0be5-16e2-4b3d-a990-f4c45acd280c/ec867d0a4793c0b180bae85bc3a4f329/windowsdesktop-runtime-3.1.10-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/513acf37-8da2-497d-bdaa-84d6e33c1fee/eb7b010350df712c752f4ec4b615f89d/windowsdesktop-runtime-3.1.10-win-x64.exe'),
			'', False, False, False);
	end;
end;
