// https://www.microsoft.com/en-us/download/details.aspx?id=48145

[Code]
procedure vcredist2015;
begin
	if not msiproductupgrade(GetString('{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}'), '14') then begin
		AddProduct('vcredist2015' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2015 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/d/e/c/dec58546-c2f5-40a7-b38e-4df8d60b9764/vc_redist.x86.exe', 'https://download.microsoft.com/download/2/c/6/2c675af0-2155-4961-b32e-289d7addfcec/vc_redist.x64.exe'),
			'', False, False, False);
	end;
end;
