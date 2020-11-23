// https://support.microsoft.com/en-us/help/4054531

[Code]
procedure dotnetfx47;
begin
	if not IsDotNetInstalled(net47, 0) then begin
		AddProduct('dotnetfx47.exe',
			'/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
			'.NET Framework 4.7.2',
			'https://download.microsoft.com/download/0/5/C/05C1EC0E-D5EE-463B-BFE3-9311376A6809/NDP472-KB4054531-Web.exe',
			'', False, False, False);
	end;
end;
