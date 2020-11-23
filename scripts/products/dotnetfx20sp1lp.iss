// https://www.microsoft.com/downloads/details.aspx?FamilyID=1cc39ffe-a2aa-4548-91b3-855a2de99304

[CustomMessages]
dotnetfx20sp1lp_title=
de.dotnetfx20sp1lp_title=.NET Framework 2.0 SP1 Sprachpaket: Deutsch

dotnetfx20sp1lp_size=3 MB

dotnetfx20sp1lp_url=
dotnetfx20sp1lp_url_x64=

de.dotnetfx20sp1lp_url=https://download.microsoft.com/download/8/a/a/8aab7e6a-5e58-4e83-be99-f5fb49fe811e/NetFx20SP1_x86de.exe
de.dotnetfx20sp1lp_url_x64=https://download.microsoft.com/download/1/4/2/1425872f-c564-4ab2-8c9e-344afdaecd44/NetFx20SP1_x64de.exe

[Code]
procedure dotnetfx20sp1lp();
begin
	if (CustomMessage('dotnetfx20sp1lp_url') <> '') and (dotnetfxspversion(NetFx20, GetUILanguage) < 1) then begin
		AddProduct('dotnetfx20sp1' + GetArchitectureString() + '_' + ActiveLanguage() + '.exe',
			'/passive /norestart /lang:ENU',
			CustomMessage('dotnetfx20sp1lp_title'),
			CustomMessage('dotnetfx20sp1lp_size'),
			CustomMessage('dotnetfx20sp1lp_url' + GetArchitectureString()),
			'', False, False, False);
	end;
end;
