// https://www.microsoft.com/downloads/details.aspx?familyid=92E0E1CE-8693-4480-84FA-7D85EEF59016

[CustomMessages]
dotnetfx20lp_title=
de.dotnetfx20lp_title=.NET Framework 2.0 Sprachpaket: Deutsch

dotnetfx20lp_size=2 MB

dotnetfx20lp_url=
dotnetfx20lp_url_x64=

de.dotnetfx20lp_url=https://download.microsoft.com/download/2/9/7/29768238-56c3-4ea6-abba-4c5246f2bc81/langpack.exe
de.dotnetfx20lp_url_x64=https://download.microsoft.com/download/2/e/f/2ef250ba-a868-4074-a4c9-249004866f87/langpack.exe

[Code]
procedure dotnetfx20lp();
begin
	if (CustomMessage('dotnetfx20lp_url') <> '') and not dotnetfxinstalled(NetFx20, GetUILanguage) then begin
		AddProduct('dotnetfx20' + GetArchitectureString() + '_' + ActiveLanguage() + '.exe',
			'/passive /norestart /lang:ENU',
			CustomMessage('dotnetfx20lp_title'),
			CustomMessage('dotnetfx20lp_size'),
			CustomMessage('dotnetfx20lp_url' + GetArchitectureString()),
			'', False, False, False);
	end;
end;
