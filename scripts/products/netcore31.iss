// https://dotnet.microsoft.com/download/dotnet-core/3.1

[Code]
procedure netcore31;
begin
	if not netcoreinstalled(Core, '3.1.10') then begin
		AddProduct('netcore31' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Core Runtime 3.1.10' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/abb3fb5d-4e82-4ca8-bc03-ac13e988e608/b34036773a72b30c5dc5520ee6a2768f/dotnet-runtime-3.1.10-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/9845b4b0-fb52-48b6-83cf-4c431558c29b/41025de7a76639eeff102410e7015214/dotnet-runtime-3.1.10-win-x64.exe'),
			'', False, False, False);
	end;
end;
