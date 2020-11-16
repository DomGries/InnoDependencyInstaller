// requires Windows 7, Windows Server 2003 Service Pack 1, Windows Server 2003 Service Pack 2, Windows Server 2008, Windows Vista, Windows XP Service Pack 2, Windows XP Service Pack 3
// https://www.microsoft.com/en-US/download/details.aspx?id=35

[CustomMessages]
directxruntime_title=DirectX End-User Runtime

directxruntime_size=96 MB

[Files]
Source: "src\dxwebsetup.exe"; Flags: dontcopy noencryption

[Code]
const
	directxruntime_url = 'https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe';

procedure directxruntime();
begin
	ExtractTemporaryFile('dxwebsetup.exe');

	AddProduct('dxwebsetup.exe',
		'/Q',
		CustomMessage('directxruntime_title'),
		CustomMessage('directxruntime_size'),
		directxruntime_url,
		true, false, false);
end;
