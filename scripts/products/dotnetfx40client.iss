// https://www.microsoft.com/downloads/en/details.aspx?FamilyID=5765d7a8-7722-4888-a970-ac39b33fd8ab

[Code]
const
	dotnetfx40client_url = 'https://download.microsoft.com/download/7/B/6/7B629E05-399A-4A92-B5BC-484C74B5124B/dotNetFx40_Client_setup.exe';

procedure dotnetfx40client;
begin
	if not dotnetfxinstalled(NetFx40Client, 0) then begin
		AddProduct('dotNetFx40_Client_setup.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.0',
			dotnetfx40client_url,
			'', False, False, False);
	end;
end;
