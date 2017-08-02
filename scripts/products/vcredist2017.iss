; requires Windows 10, Windows 7 Service Pack 1, Windows 8, Windows 8.1, Windows Server 2003 Service Pack 2, Windows Server 2008 R2 SP1, Windows Server 2008 Service Pack 2, Windows Server 2012, Windows Vista Service Pack 2, Windows XP Service Pack 3
; https://www.visualstudio.com/zh-hans/downloads/

[CustomMessages]
vcredist2017_title=Visual C++ 2017 Redistributable
vcredist2017_title_x64=Visual C++ 2017 64-Bit Redistributable

vcredist2017_size=13.74 MB
vcredist2017_size_x64=14.55 MB

[Code]
const
	vcredist2017_url = 'http://download.microsoft.com/download/c/9/3/c93555e3-472e-4493-a796-73fd6721c648/vc_redist.x86.exe';
	vcredist2017_url_x64 = 'http://download.microsoft.com/download/3/f/d/3fd46d4d-c486-4c8c-a874-e97ae62f3633/vc_redist.x64.exe';

	vcredist2017_productcode = '{582EA838-9199-3518-A05C-DB09462F68EC}';
	vcredist2017_productcode_x64 = '{8D4F7A6D-6B81-3DC8-9C21-6008E4866727}';

procedure vcredist2017();
begin
	if (not IsIA64()) then begin
		if (not msiproduct(GetString(vcredist2017_productcode, vcredist2017_productcode_x64, ''))) then
			AddProduct('vcredist2017' + GetArchitectureString() + '.exe',
				'/passive /norestart',
				CustomMessage('vcredist2017_title' + GetArchitectureString()),
				CustomMessage('vcredist2017_size' + GetArchitectureString()),
				GetString(vcredist2017_url, vcredist2017_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
