[CustomMessages]
de.dotnetfx35lp_title=.NET Framework 3.5 Sprachpaket: Deutsch

de.dotnetfx35lp_size=13 MB - 51 MB

;http://www.microsoft.com/globaldev/reference/lcid-all.mspx
en.dotnetfx35lp_lcid=1033
de.dotnetfx35lp_lcid=1031

de.dotnetfx35lp_url=http://download.microsoft.com/download/d/1/e/d1e617c3-c7f4-467e-a7de-af832450efd3/dotnetfx35langpack_x86de.exe


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,dotnetfx35lp}"; Description: "{cm:dotnetfx35lp_title}"; StatusMsg: "{cm:depinstall_status,{cm:dotnetfx35lp_title}}"; Parameters: "/lang:enu /qb /norestart"; Flags: skipifdoesntexist

[Code]
procedure dotnetfx35lp();
var
	version: cardinal;
begin
	RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v3.5\' + CustomMessage('dotnetfx35lp_lcid'), 'Install', version);
	if IntToStr(version) <> '1' then
		AddProduct('dotnetfx35lp', 'dotnetfx35lp.exe', CustomMessage('dotnetfx35lp_title'), CustomMessage('dotnetfx35lp_size'), CustomMessage('dotnetfx35lp_url'));
end;
