// https://www.microsoft.com/downloads/details.aspx?FamilyId=333325FD-AE52-4E35-B531-508D977D32A6

[Code]
procedure dotnetfx35;
begin
	if not dotnetfxinstalled(NetFx35, 0) then begin
		AddProduct('dotnetfx35.exe',
			'/lang:enu /passive /norestart',
			'.NET Framework 3.5',
			'https://download.microsoft.com/download/7/0/3/703455ee-a747-4cc8-bd3e-98a615c3aedb/dotNetFx35setup.exe',
			'', False, False, False);
	end;
end;
