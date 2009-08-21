[CustomMessages]
msi31_title=Windows Installer 3.1

en.msi31_size=2.5 MB
de.msi31_size=2,5 MB


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,msi31}"; Description: "{cm:msi31_title}"; StatusMsg: "{cm:depinstall_status,{cm:msi31_title}}"; Parameters: "/qb /norestart"; Flags: skipifdoesntexist

[Code]
const
	msi31_url = 'http://download.microsoft.com/download/1/4/7/147ded26-931c-4daf-9095-ec7baf996f46/WindowsInstaller-KB893803-v2-x86.exe';

procedure msi31(MinVersion: string);
begin
	// Check for required Windows Installer 3.0 on Windows 2000 or higher
	if minwinversion(5, 0) and (fileversion(ExpandConstant('{sys}{\}msi.dll')) < MinVersion) then
		AddProduct('msi31', 'msi31.exe', CustomMessage('msi31_title'), CustomMessage('msi31_size'), msi31_url);
end;