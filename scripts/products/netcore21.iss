; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2008 R2 SP1+

[CustomMessages]
netcore21_title=.NET Core 2.1

netcore21_size=1 MB - 25 MB

[Code]
const
	netcore21_url_x64 = 'https://download.visualstudio.microsoft.com/download/pr/53d3ad06-172f-4848-abc1-c70003de009e/1f45c5c98848c284c90b888933298f94/dotnet-runtime-2.1.18-win-x64.exe';
	netcore21_url_x86 = 'https://download.visualstudio.microsoft.com/download/pr/b90bbf7b-8739-4326-8e55-431a65dba1ba/8bfe25d90f428124ff42d63004fb0430/dotnet-runtime-2.1.18-win-x86.exe';

procedure netcore21();
var
    netcore21_url: String;
begin
    case ProcessorArchitecture of
        paX64: netcore21_url := netcore21_url_x64;
        paX86: netcore21_url := netcore21_url_x86;
    end;

    if not netcoreversioninstalled(NetC21) then
        AddProduct('netcore21.exe',
            '/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
            CustomMessage('netcore21_title'),
            CustomMessage('netcore21_size'),
            netcore21_url,
            false, false, false);
end;

[Setup]