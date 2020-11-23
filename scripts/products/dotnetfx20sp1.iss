// https://www.microsoft.com/downloads/details.aspx?FamilyID=79bc3b77-e02c-4ad3-aacf-a7633f706ba5

[Code]
const
	dotnetfx20sp1_url = 'https://download.microsoft.com/download/0/8/c/08c19fa4-4c4f-4ffb-9d6c-150906578c9e/NetFx20SP1_x86.exe';
	dotnetfx20sp1_url_x64 = 'https://download.microsoft.com/download/9/8/6/98610406-c2b7-45a4-bdc3-9db1b1c5f7e2/NetFx20SP1_x64.exe';

procedure dotnetfx20sp1();
begin
	if dotnetfxspversion(NetFx20, 0) < 1 then begin
		AddProduct('dotnetfx20sp1' + GetArchitectureString() + '.exe',
			'/passive /norestart /lang:ENU',
			'.NET Framework 2.0 Service Pack 1',
			GetString(dotnetfx20sp1_url, dotnetfx20sp1_url_x64),
			'', False, False, False);
	end;
end;
