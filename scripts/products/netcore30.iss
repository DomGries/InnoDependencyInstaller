; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2

[CustomMessages]
netcore30_title=.NET Core 3.0

netcore30_size=1 MB - 28 MB

[Code]
const
	netcore30_url_x64 = 'http://download.visualstudio.microsoft.com/download/pr/c525a2bb-6e98-4e6e-849e-45241d0db71c/d21612f02b9cae52fa50eb54de905986/windowsdesktop-runtime-3.0.3-win-x64.exe';
	netcore30_url_x86 = 'http://download.visualstudio.microsoft.com/download/pr/e312618d-85c4-4cad-b660-569b5522eca9/e951e76ebe011b5d3ea1289ef68e8281/windowsdesktop-runtime-3.0.3-win-x86.exe';

procedure netcore30();
var
    netcore30_url: String;
begin
    case ProcessorArchitecture of
        paX64: netcore30_url := netcore30_url_x64;
        paX86: netcore30_url := netcore30_url_x86;
    end;

    if not netcoreversioninstalled(NetC30) then
        AddProduct('netcore30.exe',
            '/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
            CustomMessage('netcore30_title'),
            CustomMessage('netcore30_size'),
            netcore30_url,
            false, false, false);
end;

[Setup]