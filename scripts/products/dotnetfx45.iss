// https://www.microsoft.com/en-us/download/details.aspx?id=42642

[Code]
procedure dotnetfx45(MinVersion: Integer);
begin
	if dotnetfxspversion(NetFx4x, 0) < MinVersion then begin
		AddProduct('dotnetfx45.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.5.2',
			'https://download.microsoft.com/download/B/4/1/B4119C11-0423-477B-80EE-7A474314B347/NDP452-KB2901954-Web.exe',
			'', False, False, False);
	end;
end;
