//http://www.microsoft.com/downloads/details.aspx?familyid=92E0E1CE-8693-4480-84FA-7D85EEF59016

[CustomMessages]
de.dotnetfx20lp_title=.NET Framework 2.0 Sprachpaket: Deutsch

de.dotnetfx20lp_size=1,8 MB

;http://www.microsoft.com/globaldev/reference/lcid-all.mspx
de.dotnetfx20lp_lcid=1031

de.dotnetfx20lp_url=http://download.microsoft.com/download/2/9/7/29768238-56c3-4ea6-abba-4c5246f2bc81/langpack.exe
de.dotnetfx20lp_url_x64=http://download.microsoft.com/download/2/e/f/2ef250ba-a868-4074-a4c9-249004866f87/langpack.exe
de.dotnetfx20lp_url_ia64=http://download.microsoft.com/download/8/9/8/898c5670-5e74-41c4-82fc-68dd837af627/langpack.exe


[Code]
procedure dotnetfx20lp();
var
	version: cardinal;
	regPath: string;
begin
	if ActiveLanguage() <> 'en' then begin
		regPath := GetString('Software', 'Software\Wow6432Node', 'Software\Wow6432Node') + '\Microsoft\NET Framework Setup\NDP\v2.0.50727\' + CustomMessage('dotnetfx20lp_lcid');
		RegQueryDWordValue(HKLM, regPath, 'Install', version);
		
		if version <> 1 then
			AddProduct(GetString('dotnetfx20_' + ActiveLanguage() + '.exe', 'dotnetfx20_x64_' + ActiveLanguage() + '.exe', 'dotnetfx20_ia64_' + ActiveLanguage() + '.exe'),
				'/passive /norestart /lang:ENU',
				CustomMessage('dotnetfx20lp_title'),
				CustomMessage('dotnetfx20lp_size'),
				GetString(CustomMessage('dotnetfx20lp_url'), CustomMessage('dotnetfx20lp_url_x64'), CustomMessage('dotnetfx20lp_url_ia64')));
	end;
end;