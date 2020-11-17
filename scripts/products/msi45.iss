[CustomMessages]
msi45_title=Windows Installer 4.5

msi45win60_size=2 MB
msi45win60_size_x64=3 MB
msi45win60_size_ia64=3 MB
msi45win52_size=3 MB
msi45win52_size_x64=5 MB
msi45win52_size_ia64=25 MB
msi45win51_size=3 MB

[Code]
const
	msi45win60_url = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x86.msu';
	msi45win60_url_x64 = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x64.msu';
	msi45win60_url_ia64 = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-ia64.msu';
	msi45win52_url = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/WindowsServer2003-KB942288-v4-x86.exe';
	msi45win52_url_x64 = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/WindowsServer2003-KB942288-v4-x64.exe';
	msi45win52_url_ia64 = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/WindowsServer2003-KB942288-v4-ia64.exe';
	msi45win51_url = 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/WindowsXP-KB942288-v3-x86.exe';

procedure msi45(minVersion: String);
var
	version: String;
begin
	if (GetVersionNumbersString(ExpandConstant('{sys}{\}msi.dll'), version) and (compareversion(version, minVersion) < 0)) then begin
		if minwinversion(6, 0) then
			AddProduct('msi45_60' + GetArchitectureString() + '.msu',
				'/quiet /norestart',
				CustomMessage('msi45_title'),
				CustomMessage('msi45win60_size' + GetArchitectureString()),
				GetString(msi45win60_url, msi45win60_url_x64, msi45win60_url_ia64),
				'', false, false, false)
		else if minwinversion(5, 2) then
			AddProduct('msi45_52' + GetArchitectureString() + '.exe',
				'/quiet /norestart',
				CustomMessage('msi45_title'),
				CustomMessage('msi45win52_size' + GetArchitectureString()),
				GetString(msi45win52_url, msi45win52_url_x64, msi45win52_url_ia64),
				'', false, false, false)
		else if minwinversion(5, 1) and IsX86() then
			AddProduct('msi45_51.exe',
				'/quiet /norestart',
				CustomMessage('msi45_title'),
				CustomMessage('msi45win51_size'),
				msi45win51_url,
				'', false, false, false);
	end;
end;
