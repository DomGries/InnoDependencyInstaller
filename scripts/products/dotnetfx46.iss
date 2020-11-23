// requires Windows 7 Service Pack 1, Windows 8.1, Windows Server 2008 R2 SP1, Windows Server 2012, Windows Server 2012 R2
// express setup (downloads and installs the components depending on your OS) if you want to deploy it locally download the full installer on website below
// https://www.microsoft.com/en-US/download/details.aspx?id=53345

[CustomMessages]
dotnetfx46_title=.NET Framework 4.6.2

[Code]
const
	dotnetfx46_url = 'https://download.microsoft.com/download/D/5/C/D5C98AB0-35CC-45D9-9BA5-B18256BA2AE6/NDP462-KB3151802-Web.exe';

procedure dotnetfx46(minVersion: Integer);
begin
	if dotnetfxspversion(NetFx4x, 0) < minVersion then begin
		AddProduct('dotnetfx46.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			CustomMessage('dotnetfx46_title'),
			dotnetfx46_url,
			'', False, False, False);
	end;
end;
