// requires Windows 2000 Service Pack 3, Windows 98, Windows 98 Second Edition, Windows ME, Windows Server 2003, Windows XP Service Pack 2
// requires internet explorer 5.0.1 or higher
// requires windows installer 2.0 on windows 98, ME
// requires Windows Installer 3.1 on windows 2000 or higher
// https://www.microsoft.com/downloads/details.aspx?FamilyID=0856eacb-4362-4b0d-8edd-aab15c5e04f5

[CustomMessages]
dotnetfx20_title=.NET Framework 2.0

[Code]
const
	dotnetfx20_url = 'https://download.microsoft.com/download/5/6/7/567758a3-759e-473e-bf8f-52154438565a/dotnetfx.exe';
	dotnetfx20_url_x64 = 'https://download.microsoft.com/download/a/3/f/a3f1bf98-18f3-4036-9b68-8e6de530ce0a/NetFx64.exe';

procedure dotnetfx20();
begin
	if not dotnetfxinstalled(NetFx20, 0) then begin
		AddProduct('dotnetfx20' + GetArchitectureString() + '.exe',
			'/passive /norestart /lang:ENU',
			CustomMessage('dotnetfx20_title'),
			GetString(dotnetfx20_url, dotnetfx20_url_x64),
			'', False, False, False);
	end;
end;
