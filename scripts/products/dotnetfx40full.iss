// https://www.microsoft.com/downloads/en/details.aspx?FamilyID=9cfb2d51-5ff4-4491-b0e5-b386f32c0992

[Code]
procedure dotnetfx40full;
begin
	if not IsDotNetInstalled(net4full, 0) then begin
		AddProduct('dotNetFx40_Full_setup.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.0',
			'https://download.microsoft.com/download/1/B/E/1BE39E79-7E39-46A3-96FF-047F95396215/dotNetFx40_Full_setup.exe',
			'', False, False, False);
	end;
end;
