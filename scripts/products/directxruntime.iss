// https://www.microsoft.com/en-US/download/details.aspx?id=35

[Files]
Source: "src\dxwebsetup.exe"; Flags: dontcopy noencryption

[Code]
const
	directxruntime_url = 'https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe';

procedure directxruntime;
begin
	ExtractTemporaryFile('dxwebsetup.exe');

	AddProduct('dxwebsetup.exe',
		'/Q',
		'DirectX Runtime',
		directxruntime_url,
		'', True, False, False);
end;
