// https://www.microsoft.com/en-us/download/details.aspx?id=5555

[Code]
procedure vcredist2010(MinVersion: String);
begin
	if not msiproductupgrade(GetString('{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}', '{5B75F761-BAC8-33BC-A381-464DDDD813A3}'), MinVersion) then begin
		AddProduct('vcredist2010' + GetArchitectureSuffix + '.exe',
			'/passive /norestart',
			'Visual C++ 2010 Redistributable' + GetArchitectureTitle,
			GetString('https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe'),
			'', False, False, False);
	end;
end;
