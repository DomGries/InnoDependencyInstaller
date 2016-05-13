// Richard M Parslow 28/02/2015
// requires Windows 10, Windows 7 Service Pack 1, Windows 8, Windows 8.1, Windows Server 2003 Service Pack 2, Windows Server 2008 R2 SP1, Windows Server 2008 Service Pack 2, Windows Server 2012, Windows Vista Service Pack 2, Windows XP Service Pack 3
// http://www.microsoft.com/en-us/download/details.aspx?id=49984
// Additional Prerequisite: April 2014 Update (see KB 2919355) and Servicing Stack Update (see KB 2919442 or later) for Windows 8.1 and Windows Server 2012 R2.

[CustomMessages]
vcredist2015up1_title=Visual C++ Redistributable for Visual Studio 2015 Update 1
vcredist2015up1_title_x64=Visual C++ Redistributable for Visual Studio 2015 Update 1 64-Bit

; Version: 2015 - Date Published: 17th of November 2015

en.vcredist2015up1_size=13.3 MB
de.vcredist2015up1_size=13,3 MB
fr.vcredist2015up1_size=13,3 Mo
it.vcredist2015up1_size=13,3 MB
pl.vcredist2015up1_size=13,3 MB

en.vcredist2015up1_size_x64=14.1 MB
de.vcredist2015up1_size_x64=14,1 MB
fr.vcredist2015up1_size_x64=14,1 Mo
it.vcredist2015up1_size_x64=14,1 MB
pl.vcredist2015up1_size_x64=14,1 MB


[Code]
const


  vcredist2015up1_url = 'http://download.microsoft.com/download/C/E/5/CE514EAE-78A8-4381-86E8-29108D78DBD4/VC_redist.x86.exe';
  vcredist2015up1_url_x64 = 'http://download.microsoft.com/download/C/E/5/CE514EAE-78A8-4381-86E8-29108D78DBD4/VC_redist.x64.exe';

	vcredist2015up1_productcode = '{65AD78AD-D23D-3A1E-9305-3AE65CD522C2}';
	vcredist2015up1_productcode_x64 = '{A1C31BA5-5438-3A07-9EEE-A5FB2D0FDE36}';

procedure vcredist2015up1();
begin
	if (not IsIA64()) then begin
		if (not msiproduct(GetString(vcredist2015up1_productcode, vcredist2015up1_productcode_x64, ''))) then
			AddProduct('vcredist2015up1' + GetArchitectureString() + '.exe',
				'/passive /norestart',
				CustomMessage('vcredist2015up1_title' + GetArchitectureString()),
				CustomMessage('vcredist2015up1_size' + GetArchitectureString()),
				GetString(vcredist2015up1_url, vcredist2015up1_url_x64, ''),
				false, false);
	end;
end;
