[CustomMessages]
msi20_title=Windows Installer 2.0

en.msi20_size=1.7 MB
de.msi20_size=1,7 MB


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,msi20}"; Description: "{cm:msi20_title}"; StatusMsg: "{cm:depinstall_status,{cm:msi20_title}}"; Parameters: "/q:a /c:""msiinst /delayrebootq"""; Flags: skipifdoesntexist

[Code]
const
	msi20_url = 'http://download.microsoft.com/download/WindowsInstaller/Install/2.0/W9XMe/EN-US/InstMsiA.exe';

procedure msi20(MinVersion: string);
begin
	// Check for required Windows Installer 2.0 on Windows 98 and ME
	if maxwinversion(4, 9) and (fileversion(ExpandConstant('{sys}{\}msi.dll')) < MinVersion) then
		AddProduct('msi20', 'msi20.exe', CustomMessage('msi20_title'), CustomMessage('msi20_size'), msi20_url);
end;