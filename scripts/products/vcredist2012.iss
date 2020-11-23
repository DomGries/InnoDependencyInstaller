// https://www.microsoft.com/en-us/download/details.aspx?id=30679

[Code]
procedure vcredist2012;
begin
	if not msiproductupgrade(GetString('{4121ED58-4BD9-3E7B-A8B5-9F8BAAE045B7}', '{EFA6AFA1-738E-3E00-8101-FD03B86B29D1}'), '11') then begin
		AddProduct('vcredist2012' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2012 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe'),
			'', False, False, False);
	end;
end;
