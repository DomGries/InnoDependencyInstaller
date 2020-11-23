// https://www.microsoft.com/en-us/download/details.aspx?id=3387

[Code]
procedure vcredist2005(MinVersion: String);
begin
	if not msiproductupgrade(GetString('{86C9D5AA-F00C-4921-B3F2-C60AF92E2844}', '{A8D19029-8E5C-4E22-8011-48070F9E796E}'), MinVersion) then begin
		AddProduct('vcredist2005' + GetArchitectureSuffix + '.exe',
			'/q:a /c:"install /qb /l',
			'Visual C++ 2005 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE', 'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE'),
			'', False, False, False);
	end;
end;
