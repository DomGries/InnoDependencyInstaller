// https://www.microsoft.com/downloads/details.aspx?FamilyID=0856eacb-4362-4b0d-8edd-aab15c5e04f5

[Code]
procedure dotnetfx20;
begin
	if not dotnetfxinstalled(NetFx20, 0) then begin
		AddProduct('dotnetfx20' + GetArchitectureSuffix + '.exe',
			'/passive /norestart /lang:ENU',
			'.NET Framework 2.0',
			GetString('https://download.microsoft.com/download/5/6/7/567758a3-759e-473e-bf8f-52154438565a/dotnetfx.exe', 'https://download.microsoft.com/download/a/3/f/a3f1bf98-18f3-4036-9b68-8e6de530ce0a/NetFx64.exe'),
			'', False, False, False);
	end;
end;
