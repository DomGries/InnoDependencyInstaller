[CustomMessages]
de.dotnetfx20lp_title=.NET Framework 2.0 Sprachpaket: Deutsch

de.dotnetfx20lp_size=1,8 MB

;http://www.microsoft.com/globaldev/reference/lcid-all.mspx
en.dotnetfx20lp_lcid=1033
de.dotnetfx20lp_lcid=1031

de.dotnetfx20lp_url=http://download.microsoft.com/download/2/9/7/29768238-56c3-4ea6-abba-4c5246f2bc81/langpack.exe


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,dotnetfx20lp}"; Description: "{cm:dotnetfx20lp_title}"; StatusMsg: "{cm:depinstall_status,{cm:dotnetfx20lp_title}}"; Parameters: "/q:a /c:""install /qb /l"""; Flags: skipifdoesntexist

[Code]
procedure dotnetfx20lp();
var
	version: cardinal;
begin
	RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v2.0.50727\' + CustomMessage('dotnetfx20lp_lcid'), 'Install', version);
	if IntToStr(version) <> '1' then
		AddProduct('dotnetfx20lp', ExpandConstant('dotnetfx20_langpack_{language}.exe'), CustomMessage('dotnetfx20lp_title'), CustomMessage('dotnetfx20lp_size'), CustomMessage('dotnetfx20lp_url'));
end;
