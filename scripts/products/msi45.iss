[Code]
procedure msi45(MinVersion: String);
var
	Version: String;
begin
	if GetVersionNumbersString(ExpandConstant('{sys}{\}msi.dll'), Version) and (compareversion(Version, MinVersion) < 0) then begin
		AddProduct('msi45' + GetArchitectureSuffix + '.msu',
			'/quiet /norestart',
			'Windows Installer 4.5',
			GetString('https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x86.msu', 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x64.msu'),
			'', False, False, False);
	end;
end;
