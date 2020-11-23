// https://www.microsoft.com/en-us/download/details.aspx?id=29

[Code]
procedure vcredist2008;
begin
	if not msiproductupgrade(GetString('{DE2C306F-A067-38EF-B86C-03DE4B0312F9}', '{FDA45DDF-8E17-336F-A3ED-356B7B7C688A}'), '9') and not msiproductupgrade('{AA783A14-A7A3-3D33-95F0-9A351D530011}', '9') then begin
		AddProduct('vcredist2008' + GetArchitectureSuffix + '.exe',
			'/q',
			'Visual C++ 2008 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe', 'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe'),
			'', False, False, False);
	end;
end;
