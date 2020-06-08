; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2

[CustomMessages]
netcore31_title=.NET Core 3.1

netcore31_size=1 MB - 30 MB

[Code]
const
	netcore31_url_x64 = 'http://download.visualstudio.microsoft.com/download/pr/d8cf1fe3-21c2-4baf-988f-f0152996135e/0c00b94713ee93e7ad5b4f82e2b86607/windowsdesktop-runtime-3.1.4-win-x64.exe';
	netcore31_url_x86 = 'http://download.visualstudio.microsoft.com/download/pr/2d4b7600-5f32-4a1f-abd5-47cdb2d1362b/7b8b7635e3bb63f6b2cc9a1c624b5325/windowsdesktop-runtime-3.1.4-win-x86.exe';

procedure netcore31();
var
    netcore31_url: String;
begin
    case ProcessorArchitecture of
        paX64: netcore31_url := netcore31_url_x64;
        paX86: netcore31_url := netcore31_url_x86;
    end;

    if not netcoreversioninstalled(NetC31) then
        AddProduct('netcore31.exe',
            '/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
            CustomMessage('netcore31_title'),
            CustomMessage('netcore31_size'),
            netcore31_url,
            false, false, false);
end;

[Setup]