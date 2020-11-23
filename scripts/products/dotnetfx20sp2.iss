// https://www.microsoft.com/downloads/details.aspx?familyid=5B2C0358-915B-4EB5-9B1D-10E506DA9D0F

[Code]
const
	dotnetfx20sp2_url = 'https://download.microsoft.com/download/c/6/e/c6e88215-0178-4c6c-b5f3-158ff77b1f38/NetFx20SP2_x86.exe';
	dotnetfx20sp2_url_x64 = 'https://download.microsoft.com/download/c/6/e/c6e88215-0178-4c6c-b5f3-158ff77b1f38/NetFx20SP2_x64.exe';

procedure dotnetfx20sp2;
begin
	if dotnetfxspversion(NetFx20, 0) < 2 then begin
		AddProduct('dotnetfx20sp2' + GetArchitectureSuffix + '.exe',
			'/passive /norestart /lang:ENU',
			'.NET Framework 2.0 Service Pack 2',
			GetString(dotnetfx20sp2_url, dotnetfx20sp2_url_x64),
			'', False, False, False);
	end;
end;
