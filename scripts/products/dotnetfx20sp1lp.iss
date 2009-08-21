[CustomMessages]
de.dotnetfx20sp1lp_title=.NET Framework 2.0 SP1 Sprachpaket: Deutsch

de.dotnetfx20sp1lp_size=3,4 MB

;http://www.microsoft.com/globaldev/reference/lcid-all.mspx
en.dotnetfx20sp1lp_lcid=1033
de.dotnetfx20sp1lp_lcid=1031

de.dotnetfx20sp1lp_url=http://download.microsoft.com/download/8/a/a/8aab7e6a-5e58-4e83-be99-f5fb49fe811e/NetFx20SP1_x86de.exe


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,dotnetfx20sp1lp}"; Description: "{cm:dotnetfx20sp1lp_title}"; StatusMsg: "{cm:depinstall_status,{cm:dotnetfx20sp1lp_title}}"; Parameters: "/q:a /c:""install /qb /l"""; Flags: skipifdoesntexist

[Code]
procedure dotnetfx20sp1lp();
var
	version: cardinal;
begin
	RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v2.0.50727\' + CustomMessage('dotnetfx20sp1lp_lcid'), 'SP', version);
	if IntToStr(version) < '1' then
		AddProduct('dotnetfx20sp1lp', ExpandConstant('dotnetfx20sp1_langpack_{language}.exe'), CustomMessage('dotnetfx20sp1lp_title'), CustomMessage('dotnetfx20sp1lp_size'), CustomMessage('dotnetfx20sp1lp_url'));
end;