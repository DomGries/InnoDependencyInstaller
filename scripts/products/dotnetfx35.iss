// https://www.microsoft.com/downloads/details.aspx?FamilyID=ab99342f-5d1a-413d-8319-81da479ab0d7

[Code]
procedure dotnetfx35;
begin
	if not IsDotNetInstalled(net35, 0) then begin
		AddProduct('dotnetfx35.exe',
			'/lang:enu /passive /norestart',
			'.NET Framework 3.5',
			'https://download.microsoft.com/download/0/6/1/061f001c-8752-4600-a198-53214c69b51f/dotnetfx35setup.exe',
			'', False, False, False);
	end;
end;
