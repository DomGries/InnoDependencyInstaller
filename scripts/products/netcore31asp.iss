// https://dotnet.microsoft.com/download/dotnet-core/3.1

[Code]
procedure netcore31asp;
begin
	if not netcoreinstalled(Asp, '3.1.10') then begin
		AddProduct('netcore31asp' + GetArchitectureSuffix + '.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'ASP.NET Core Runtime 3.1.10' + GetArchitectureTitle,
			GetString('https://download.visualstudio.microsoft.com/download/pr/c0a1f953-81d3-4a1a-a584-a627b518c434/16e1af0d3ebe6edacde1eab155dd4d90/aspnetcore-runtime-3.1.10-win-x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/c1ea0601-abe4-4c6d-96ed-131764bf5129/a1823d8ff605c30af412776e2e617a36/aspnetcore-runtime-3.1.10-win-x64.exe'),
			'', False, False, False);
	end;
end;
