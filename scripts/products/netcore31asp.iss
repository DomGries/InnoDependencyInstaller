// requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2
// https://dotnet.microsoft.com/download/dotnet-core/3.1

[CustomMessages]
netcore31asp_title=ASP.NET Core Runtime 3.1.6 (x86)
netcore31asp_title_x64=ASP.NET Core Runtime 3.1.6 (x64)

netcore31asp_size=7 MB
netcore31asp_size_x64=8 MB

[Code]
const
	netcore31asp_url = 'https://go.microsoft.com/fwlink/?linkid=2137940';
	netcore31asp_url_x64 = 'https://go.microsoft.com/fwlink/?linkid=2137939';

procedure netcore31asp();
begin
	if (not IsIA64()) then begin
		if not netcoreinstalled(Asp, '3.1.6') then
			AddProduct('netcore31asp' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('netcore31asp_title' + GetArchitectureString()),
				CustomMessage('netcore31asp_size' + GetArchitectureString()),
				GetString(netcore31asp_url, netcore31asp_url_x64, ''),
				false, false, false);
	end;
end;
