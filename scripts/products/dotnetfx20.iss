// requires Windows 2000 Service Pack 3, Windows 98, Windows 98 Second Edition, Windows ME, Windows Server 2003, Windows XP Service Pack 2
// requires internet explorer 5.0.1 or higher
// requires windows installer 2.0 on windows 98, ME
// requires windows installer 3.1 on windows 2000 or higher
// http://www.microsoft.com/downloads/details.aspx?FamilyID=0856eacb-4362-4b0d-8edd-aab15c5e04f5

[CustomMessages]
dotnetfx20_title=.NET Framework 2.0

en.dotnetfx20_size=23 MB
de.dotnetfx20_size=23 MB


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,dotnetfx20}"; Description: "{cm:dotnetfx20_title}"; StatusMsg: "{cm:depinstall_status,{cm:dotnetfx20_title}}"; Parameters: "/q:a /t:{tmp}{\}dotnetfx20 /c:""install /qb /l"""; Flags: skipifdoesntexist

[Code]	
const
	dotnetfx20_url = 'http://download.microsoft.com/download/5/6/7/567758a3-759e-473e-bf8f-52154438565a/dotnetfx.exe';

procedure dotnetfx20();
var
	version: cardinal;
begin
	RegQueryDWordValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\NET Framework Setup\NDP\v2.0.50727', 'Install', version)
	if IntToStr(version) <> '1' then
		AddProduct('dotnetfx20', 'dotnetfx20.exe', CustomMessage('dotnetfx20_title'), CustomMessage('dotnetfx20_size'), dotnetfx20_url);
end;
