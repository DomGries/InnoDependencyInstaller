[Code]
const
	msi45_url = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x86.msu';
	msi45_url_x64 = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x64.msu';

procedure msi45(minVersion: String);
var
	version: String;
begin
	if GetVersionNumbersString(ExpandConstant('{sys}{\}msi.dll'), version) and (compareversion(version, minVersion) < 0) then begin
		AddProduct('msi45' + GetArchitectureString() + '.msu',
			'/quiet /norestart',
			'Windows Installer 4.5',
			GetString(msi45_url, msi45_url_x64),
			'', False, False, False);
	end;
end;
