// https://www.microsoft.com/downloads/en/details.aspx?FamilyID=9cfb2d51-5ff4-4491-b0e5-b386f32c0992

[Code]
const
	dotnetfx40full_url = 'https://download.microsoft.com/download/1/B/E/1BE39E79-7E39-46A3-96FF-047F95396215/dotNetFx40_Full_setup.exe';

procedure dotnetfx40full();
begin
	if not dotnetfxinstalled(NetFx40Full, 0) then begin
		AddProduct('dotNetFx40_Full_setup.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.0',
			dotnetfx40full_url,
			'', False, False, False);
	end;
end;
