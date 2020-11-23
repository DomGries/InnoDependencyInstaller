// https://www.microsoft.com/downloads/details.aspx?FamilyID=0856eacb-4362-4b0d-8edd-aab15c5e04f5

[Code]
const
	dotnetfx20_url = 'https://download.microsoft.com/download/5/6/7/567758a3-759e-473e-bf8f-52154438565a/dotnetfx.exe';
	dotnetfx20_url_x64 = 'https://download.microsoft.com/download/a/3/f/a3f1bf98-18f3-4036-9b68-8e6de530ce0a/NetFx64.exe';

procedure dotnetfx20;
begin
	if not dotnetfxinstalled(NetFx20, 0) then begin
		AddProduct('dotnetfx20' + GetArchitectureSuffix + '.exe',
			'/passive /norestart /lang:ENU',
			'.NET Framework 2.0',
			GetString(dotnetfx20_url, dotnetfx20_url_x64),
			'', False, False, False);
	end;
end;
