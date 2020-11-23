// https://www.microsoft.com/en-US/download/details.aspx?id=53345

[Code]
const
	dotnetfx46_url = 'https://download.microsoft.com/download/D/5/C/D5C98AB0-35CC-45D9-9BA5-B18256BA2AE6/NDP462-KB3151802-Web.exe';

procedure dotnetfx46(MinVersion: Integer);
begin
	if dotnetfxspversion(NetFx4x, 0) < MinVersion then begin
		AddProduct('dotnetfx46.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.6.2',
			dotnetfx46_url,
			'', False, False, False);
	end;
end;
