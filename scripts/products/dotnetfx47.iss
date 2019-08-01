; requires Windows 10, Windows 7 Service Pack 1, Windows 8.1, Windows Server 2008 R2 SP1, Windows Server 2012, Windows Server 2012 R2, Windows Server 2016
; WARNING: express setup (downloads and installs the components depending on your OS) if you want to deploy it on cd or network download the full bootsrapper on website below
; https://dotnet.microsoft.com/download/thank-you/net472-offline

[CustomMessages]
dotnetfx47_title=.NET Framework 4.7

dotnetfx47_size=1 MB - 59 MB

[Code]
const
	dotnetfx47_url = 'http://download.microsoft.com/download/0/5/C/05C1EC0E-D5EE-463B-BFE3-9311376A6809/NDP472-KB4054531-Web.exe';

procedure dotnetfx47(minVersion: integer);
begin
	if (not netfxinstalled(NetFx4x, '') or (netfxspversion(NetFx4x, '') < minVersion)) then
		AddProduct('dotnetfx47.exe',
			'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
			CustomMessage('dotnetfx47_title'),
			CustomMessage('dotnetfx47_size'),
			dotnetfx47_url,
			false, false, false);
end;

[Setup]
