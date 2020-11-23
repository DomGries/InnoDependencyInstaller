// https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads

[Code]
const
	vcredist2019_url = 'https://aka.ms/vs/16/release/vc_redist.x86.exe';
	vcredist2019_url_x64 = 'https://aka.ms/vs/16/release/vc_redist.x64.exe';

	vcredist2019_upgradecode = '{65E5BD06-6392-3027-8C26-853107D3CF1A}';
	vcredist2019_upgradecode_x64 = '{36F68A90-239C-34DF-B58C-64B30153CE35}';

procedure vcredist2019(MinVersion: String);
begin
	if not msiproductupgrade(GetString(vcredist2019_upgradecode, vcredist2019_upgradecode_x64), MinVersion) then begin
		AddProduct('vcredist2019' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2015-2019 Redistributable' + GetArchitectureTitle,
			GetString(vcredist2019_url, vcredist2019_url_x64),
			'', False, False, False);
	end;
end;
