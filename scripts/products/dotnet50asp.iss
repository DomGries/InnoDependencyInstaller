// https://dotnet.microsoft.com/download/dotnet/5.0

[CustomMessages]
dotnet50asp_title=ASP.NET Core Runtime 5.0 (x86)
dotnet50asp_title_x64=ASP.NET Core Runtime 5.0 (x64)

dotnet50asp_size=7 MB
dotnet50asp_size_x64=8 MB

[Code]
const
	dotnet50asp_url = 'https://download.visualstudio.microsoft.com/download/pr/115edeeb-c883-45be-90f7-8db7b6b3fa2f/6bf92152b2b9fa9c0d0b08a13b60e525/aspnetcore-runtime-5.0.0-win-x86.exe';
	dotnet50asp_url_x64 = 'https://download.visualstudio.microsoft.com/download/pr/92866d29-a298-4cab-b501-a65e43820f97/88d287b9fb4a12cfcdf4a6be85f4a638/aspnetcore-runtime-5.0.0-win-x64.exe';

procedure dotnet50asp();
begin
	if (not IsIA64()) then begin
		if not netcoreinstalled(Asp, '5.0.0') then
			AddProduct('dotnet50asp' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('dotnet50asp_title' + GetArchitectureString()),
				CustomMessage('dotnet50asp_size' + GetArchitectureString()),
				GetString(dotnet50asp_url, dotnet50asp_url_x64, ''),
				false, false, false);
	end;
end;
