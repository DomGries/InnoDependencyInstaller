// requires  Windows 7, Windows Server 2003 Service Pack 1, Windows Server 2003 Service Pack 2, Windows Server 2008, Windows Vista, Windows XP Service Pack 2, Windows XP Service Pack 3
// WARNING: express setup (downloads and installs the components depending on your OS) if you want to deploy it on cd or network download the full bootsrapper on website below
// http://www.microsoft.com/en-us/download/details.aspx?id=35

[CustomMessages]
directx_title=Latest Direct X

directx_size=300 KB - 90+ MB


[Code]
const
	directx_url = 'http://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe';

procedure directx();
begin
  AddProduct('dxwebsetup.exe',
			'/Q',
			CustomMessage('directx_title'),
			CustomMessage('directx_size'),
			directx_url,
			false, false);
end;