// https://www.microsoft.com/en-us/download/details.aspx?id=3387

[Code]
const
	vcredist2005_url = 'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE';
	vcredist2005_url_x64 = 'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE';

	vcredist2005_upgradecode = '{86C9D5AA-F00C-4921-B3F2-C60AF92E2844}';
	vcredist2005_upgradecode_x64 = '{A8D19029-8E5C-4E22-8011-48070F9E796E}';

procedure vcredist2005(minVersion: String);
begin
	if not msiproductupgrade(GetString(vcredist2005_upgradecode, vcredist2005_upgradecode_x64), minVersion) then begin
		AddProduct('vcredist2005' + GetArchitectureString() + '.exe',
			'/q:a /c:"install /qb /l',
			'Visual C++ 2005 Redistributable' + GetArchitectureTitle,
			GetString(vcredist2005_url, vcredist2005_url_x64),
			'', False, False, False);
	end;
end;
