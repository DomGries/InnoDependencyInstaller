// https://www.microsoft.com/en-us/download/details.aspx?id=48145

[Code]
const
	vcredist2015_url = 'https://download.microsoft.com/download/d/e/c/dec58546-c2f5-40a7-b38e-4df8d60b9764/vc_redist.x86.exe';
	vcredist2015_url_x64 = 'https://download.microsoft.com/download/2/c/6/2c675af0-2155-4961-b32e-289d7addfcec/vc_redist.x64.exe';

	vcredist2015_upgradecode = '{65E5BD06-6392-3027-8C26-853107D3CF1A}';
	vcredist2015_upgradecode_x64 = '{36F68A90-239C-34DF-B58C-64B30153CE35}';

procedure vcredist2015(MinVersion: String);
begin
	if not msiproductupgrade(GetString(vcredist2015_upgradecode, vcredist2015_upgradecode_x64), MinVersion) then begin
		AddProduct('vcredist2015' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2015 Redistributable' + GetArchitectureTitle,
			GetString(vcredist2015_url, vcredist2015_url_x64),
			'', False, False, False);
	end;
end;
