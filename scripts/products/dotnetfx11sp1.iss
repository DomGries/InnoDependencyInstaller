// https://www.microsoft.com/downloads/details.aspx?familyid=A8F5654F-088E-40B2-BBDB-A83353618B38

[Code]
const
	dotnetfx11sp1_url = 'https://download.microsoft.com/download/8/b/4/8b4addd8-e957-4dea-bdb8-c4e00af5b94b/NDP1.1sp1-KB867460-X86.exe';

procedure dotnetfx11sp1();
begin
	if not IsX64() and (dotnetfxspversion(NetFx11, 0) < 1) then begin
		AddProduct('dotnetfx11sp1.exe',
			'/q',
			'.NET Framework 1.1 Service Pack 1',
			dotnetfx11sp1_url,
			'', False, False, False);
	end;
end;
