// https://dotnet.microsoft.com/download/dotnet-framework/net48

[Code]
procedure dotnetfx48(MinVersion: Integer);
begin
	if dotnetfxspversion(NetFx4x, 0) < MinVersion then begin
		AddProduct('dotnetfx48.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.8',
			'https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/c9b8749dd99fc0d4453b2a3e4c37ba16/ndp48-web.exe',
			'', False, False, False);
	end;
end;
