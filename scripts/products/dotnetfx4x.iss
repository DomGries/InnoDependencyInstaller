// requires Windows 7 Service Pack 1, Windows 8, Windows 8.1, Windows Server 2008 R2 SP1, Windows Server 2008 Service Pack 2, Windows Server 2012, Windows Server 2012 R2, Windows Vista Service Pack 2
// WARNING: express setup (downloads and installs the components depending on your OS) if you want to deploy it on cd or network download the full bootsrapper on website below
// https://www.microsoft.com/en-us/download/details.aspx?id=48137

[CustomMessages]
dotnetfx4x_title=.NET Framework 4.6

dotnetfx4x_size=1 MB - 63 MB

;http://www.microsoft.com/globaldev/reference/lcid-all.mspx
en.dotnetfx4x_lcid=
de.dotnetfx4x_lcid=/lcid 1031


[Code]
const
	dotnetfx4x_url = 'http://download.microsoft.com/download/1/4/A/14A6C422-0D3C-4811-A31F-5EF91A83C368/NDP46-KB3045560-Web.exe';

procedure dotnetfx4x(MinVersion: integer);
begin
	if (not netfxinstalled(NetFx4x, '') or (netfxspversion(NetFx4x, '') < MinVersion)) then
		AddProduct('dotnetfx4x.exe',
			CustomMessage('dotnetfx4x_lcid') + ' /q /passive /norestart',
			CustomMessage('dotnetfx4x_title'),
			CustomMessage('dotnetfx4x_size'),
			dotnetfx4x_url,
			false, false);
end;
