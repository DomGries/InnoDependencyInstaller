// https://support.microsoft.com/en-us/help/4054531

[Code]
const
	dotnetfx47_url = 'https://download.microsoft.com/download/0/5/C/05C1EC0E-D5EE-463B-BFE3-9311376A6809/NDP472-KB4054531-Web.exe';

procedure dotnetfx47(MinVersion: Integer);
begin
	if dotnetfxspversion(NetFx4x, 0) < MinVersion then begin
		AddProduct('dotnetfx47.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.7.2',
			dotnetfx47_url,
			'', False, False, False);
	end;
end;
