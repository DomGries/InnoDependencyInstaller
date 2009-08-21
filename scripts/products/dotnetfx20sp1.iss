// requires Windows 2000 Service Pack 4, Windows Server 2003, Windows XP Service Pack 2
// requires KB 835732 on Windows 2000 Service Pack 4
// http://www.microsoft.com/downloads/details.aspx?FamilyID=79bc3b77-e02c-4ad3-aacf-a7633f706ba5

[CustomMessages]
dotnetfx20sp1_title=.NET Framework 2.0 Service Pack 1

en.dotnetfx20sp1_size=23.6 MB
de.dotnetfx20sp1_size=23,6 MB


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,dotnetfx20sp1}"; Description: "{cm:dotnetfx20sp1_title}"; StatusMsg: "{cm:depinstall_status,{cm:dotnetfx20sp1_title}}"; Parameters: "/q:a /t:{tmp}{\}dotnetfx20sp1 /c:""install /qb /l /msipassthru MSI_PROP_BEGIN"" REBOOT=Suppress ""MSI_PROP_END"""; Flags: skipifdoesntexist

[Code]	
const
	dotnetfx20sp1_url = 'http://download.microsoft.com/download/0/8/c/08c19fa4-4c4f-4ffb-9d6c-150906578c9e/NetFx20SP1_x86.exe';

procedure dotnetfx20sp1();
var
	version: cardinal;
begin
	RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v2.0.50727', 'SP', version);
	if IntToStr(version) < '1' then
		AddProduct('dotnetfx20sp1', 'dotnetfx20sp1.exe', CustomMessage('dotnetfx20sp1_title'), CustomMessage('dotnetfx20sp1_size'), dotnetfx20sp1_url);
end;
