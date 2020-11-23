// https://www.microsoft.com/en-us/download/details.aspx?id=40784

[Code]
const
	vcredist2013_url = 'https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe';
	vcredist2013_url_x64 = 'https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe';

	vcredist2013_upgradecode = '{B59F5BF1-67C8-3802-8E59-2CE551A39FC5}';
	vcredist2013_upgradecode_x64 = '{20400CF0-DE7C-327E-9AE4-F0F38D9085F8}';

procedure vcredist2013(minVersion: String);
begin
	if not msiproductupgrade(GetString(vcredist2013_upgradecode, vcredist2013_upgradecode_x64), minVersion) then begin
		AddProduct('vcredist2013' + GetArchitectureString() + '.exe',
			'/passive /norestart',
			'Visual C++ 2013 Redistributable' + GetArchitectureTitle,
			GetString(vcredist2013_url, vcredist2013_url_x64),
			'', False, False, False);
	end;
end;
