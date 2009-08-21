[CustomMessages]
de.dotnetfx11lp_title=.NET Framework 1.1 Sprachpaket: Deutsch

de.dotnetfx11lp_size=1,4 MB

;http://www.microsoft.com/globaldev/reference/lcid-all.mspx
en.dotnetfx11lp_lcid=1033
de.dotnetfx11lp_lcid=1031

de.dotnetfx11lp_url=http://download.microsoft.com/download/6/8/2/6821e687-526a-4ef8-9a67-9a402ec5ac9e/langpack.exe


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,dotnetfx11lp}"; Description: "{cm:dotnetfx11lp_title}"; StatusMsg: "{cm:depinstall_status,{cm:dotnetfx11lp_title}}"; Parameters: "/q:a /c:""inst.exe /qb /l"""; Flags: skipifdoesntexist

[Code]
procedure dotnetfx11lp();
var
	version: cardinal;
begin
	RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v1.1.4322\' + CustomMessage('dotnetfx11lp_lcid'), 'Install', version);
	if IntToStr(version) <> '1' then
		AddProduct('dotnetfx11lp', ExpandConstant('dotnetfx11_langpack_{language}.exe'), CustomMessage('dotnetfx11lp_title'), CustomMessage('dotnetfx11lp_size'), CustomMessage('dotnetfx11lp_url'));
end;
