[CustomMessages]
dotnetfx35sp1lp_title=
de.dotnetfx35sp1lp_title=.NET Framework 3.5 SP1 Sprachpaket: Deutsch

dotnetfx35sp1lp_size=98 MB

dotnetfx35sp1lp_url=
de.dotnetfx35sp1lp_url=https://download.microsoft.com/download/d/7/2/d728b7b9-454b-4b57-8270-45dac441b0ec/dotnetfx35langpack_x86de.exe

[Code]
procedure dotnetfx35sp1lp();
begin
	if (CustomMessage('dotnetfx35sp1lp_url') <> '') and (dotnetfxspversion(NetFx35, GetUILanguage) < 1) then begin
		AddProduct('dotnetfx35sp1_' + ActiveLanguage() + '.exe',
			'/lang:enu /passive /norestart',
			CustomMessage('dotnetfx35sp1lp_title'),
			CustomMessage('dotnetfx35sp1lp_size'),
			CustomMessage('dotnetfx35sp1lp_url'),
			'', False, False, False);
	end;
end;
