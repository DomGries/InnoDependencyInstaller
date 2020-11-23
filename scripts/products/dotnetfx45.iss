// https://www.microsoft.com/en-us/download/details.aspx?id=42642

[Code]
const
	dotnetfx45_url = 'https://download.microsoft.com/download/B/4/1/B4119C11-0423-477B-80EE-7A474314B347/NDP452-KB2901954-Web.exe';

procedure dotnetfx45(minVersion: Integer);
begin
	if dotnetfxspversion(NetFx4x, 0) < minVersion then begin
		AddProduct('dotnetfx45.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.5.2',
			dotnetfx45_url,
			'', False, False, False);
	end;
end;
