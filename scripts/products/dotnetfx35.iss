// requires Windows Server 2003 Service Pack 1, Windows Server 2008, Windows Vista, Windows XP Service Pack 2
// requires Windows Installer 3.1
// express setup (downloads and installs the components depending on your OS) if you want to deploy it locally download the full installer on website below
// https://www.microsoft.com/downloads/details.aspx?FamilyId=333325FD-AE52-4E35-B531-508D977D32A6

[CustomMessages]
dotnetfx35_title=.NET Framework 3.5

[Code]
const
	dotnetfx35_url = 'https://download.microsoft.com/download/7/0/3/703455ee-a747-4cc8-bd3e-98a615c3aedb/dotNetFx35setup.exe';

procedure dotnetfx35();
begin
	if not dotnetfxinstalled(NetFx35, 0) then begin
		AddProduct('dotnetfx35.exe',
			'/lang:enu /passive /norestart',
			CustomMessage('dotnetfx35_title'),
			dotnetfx35_url,
			'', False, False, False);
	end;
end;
