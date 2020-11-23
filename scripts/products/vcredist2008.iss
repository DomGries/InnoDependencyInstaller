// https://www.microsoft.com/en-us/download/details.aspx?id=29

[Code]
const
	vcredist2008_url = 'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe';
	vcredist2008_url_x64 = 'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe';

	vcredist2008_upgradecode = '{AA783A14-A7A3-3D33-95F0-9A351D530011}';
	vcredist2008_upgradecode_sp1 = '{DE2C306F-A067-38EF-B86C-03DE4B0312F9}';
	vcredist2008_upgradecode_sp1_x64 = '{FDA45DDF-8E17-336F-A3ED-356B7B7C688A}';

procedure vcredist2008(minVersion: String);
begin
	if not msiproductupgrade(GetString(vcredist2008_upgradecode_sp1, vcredist2008_upgradecode_sp1_x64), minVersion) and not msiproductupgrade(vcredist2008_upgradecode, minVersion) then begin
		AddProduct('vcredist2008' + GetArchitectureString() + '.exe',
			'/q',
			'Visual C++ 2008 Redistributable' + GetArchitectureTitle,
			GetString(vcredist2008_url, vcredist2008_url_x64),
			'', False, False, False);
	end;
end;
