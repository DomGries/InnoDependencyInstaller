// https://www.microsoft.com/en-us/download/details.aspx?id=5555

[Code]
const
	vcredist2010_url = 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe';
	vcredist2010_url_x64 = 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe';

	vcredist2010_upgradecode = '{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}';
	vcredist2010_upgradecode_x64 = '{5B75F761-BAC8-33BC-A381-464DDDD813A3}';

procedure vcredist2010(minVersion: String);
begin
	if not msiproductupgrade(GetString(vcredist2010_upgradecode, vcredist2010_upgradecode_x64), minVersion) then begin
		AddProduct('vcredist2010' + GetArchitectureString() + '.exe',
			'/passive /norestart',
			'Visual C++ 2010 Redistributable' + GetArchitectureTitle,
			GetString(vcredist2010_url, vcredist2010_url_x64),
			'', False, False, False);
	end;
end;
