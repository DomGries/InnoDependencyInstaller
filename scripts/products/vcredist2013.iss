// https://www.microsoft.com/en-us/download/details.aspx?id=40784

[Code]
procedure vcredist2013(MinVersion: String);
begin
	if not msiproductupgrade(GetString('{B59F5BF1-67C8-3802-8E59-2CE551A39FC5}', '{20400CF0-DE7C-327E-9AE4-F0F38D9085F8}'), MinVersion) then begin
		AddProduct('vcredist2013' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2013 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe', 'https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe'),
			'', False, False, False);
	end;
end;
