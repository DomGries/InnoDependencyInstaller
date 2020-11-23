// https://www.visualstudio.com/en-us/downloads/

[Code]
procedure vcredist2017;
begin
	if not msiproductupgrade(GetString('{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}'), '14.10') then begin
		AddProduct('vcredist2017' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2017 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/1/f/e/1febbdb2-aded-4e14-9063-39fb17e88444/vc_redist.x86.exe', 'https://download.microsoft.com/download/3/b/f/3bf6e759-c555-4595-8973-86b7b4312927/vc_redist.x64.exe'),
			'', False, False, False);
	end;
end;
