// https://www.visualstudio.com/en-us/downloads/

[Code]
const
	vcredist2017_url = 'https://download.microsoft.com/download/1/f/e/1febbdb2-aded-4e14-9063-39fb17e88444/vc_redist.x86.exe';
	vcredist2017_url_x64 = 'https://download.microsoft.com/download/3/b/f/3bf6e759-c555-4595-8973-86b7b4312927/vc_redist.x64.exe';

	vcredist2017_upgradecode = '{65E5BD06-6392-3027-8C26-853107D3CF1A}';
	vcredist2017_upgradecode_x64 = '{36F68A90-239C-34DF-B58C-64B30153CE35}';

procedure vcredist2017(MinVersion: String);
begin
	if not msiproductupgrade(GetString(vcredist2017_upgradecode, vcredist2017_upgradecode_x64), MinVersion) then begin
		AddProduct('vcredist2017' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2017 Redistributable' + GetArchitectureTitle,
			GetString(vcredist2017_url, vcredist2017_url_x64),
			'', False, False, False);
	end;
end;
