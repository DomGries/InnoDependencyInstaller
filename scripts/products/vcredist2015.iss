// OS Requirements: https://www.visualstudio.com/en-us/visual-studio-2015-compatibility-vs
//
// http://www.microsoft.com/en-us/download/details.aspx?id=48145

[CustomMessages]
vcredist2015_title=Microsoft Visual C++ 2015 Minimum Runtime - 14.0.23026
vcredist2015_title_x64=Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23026

en.vcredist2015_size=12.8 MB
//de.vcredist2015_size=12,8 MB

en.vcredist2015_size_x64=13.9 MB
//de.vcredist2015_size_x64=13,9 MB


[Code]
const
	vcredist2015_url = 'http://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x86.exe';
	vcredist2015_url_x64 = 'http://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe';

	vcredist2015_productcode = '{74d0e5db-b326-4dae-a6b2-445b9de1836e}';
	vcredist2015_productcode_x64 = '{0D3E9E15-DE7A-300B-96F1-B4AF12B96488}';


procedure vcredist2015();
begin
	log('vcredis2015');
	if (not IsIA64()) then begin
		if (not msiproduct(GetString(vcredist2015_productcode, vcredist2015_productcode_x64, ''))) then
			AddProduct('vcredist2015' + GetArchitectureString() + '.exe',
				'/passive /norestart',
				CustomMessage('vcredist2015_title' + GetArchitectureString()),
				CustomMessage('vcredist2015_size' + GetArchitectureString()),
				GetString(vcredist2015_url, vcredist2015_url_x64, ''),
				false, false);
	end;
end;
