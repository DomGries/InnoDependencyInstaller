; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2008 R2 SP1+

[CustomMessages]
netcore22_title=.NET Core 2.2

netcore22_size=1 MB - 24 MB

[Code]
const
	netcore22_url_x64 = 'https://download.visualstudio.microsoft.com/download/pr/4e14a32d-cf57-42ce-964f-fa40c7d11dde/95cf2d91312fc495bc25ad9137d42698/dotnet-runtime-2.2.8-win-x64.exe';
	netcore22_url_x86 = 'https://download.visualstudio.microsoft.com/download/pr/930685bc-ac92-4149-b4f0-b0b26d480418/c03bbed24f87e66281b5ff99ceecbb0b/dotnet-runtime-2.2.8-win-x86.exe';

procedure netcore22();
var
    netcore22_url: String;
begin
    case ProcessorArchitecture of
        paX64: netcore22_url := netcore22_url_x64;
        paX86: netcore22_url := netcore22_url_x86;
    end;

    if not netcoreversioninstalled(NetC22) then
        AddProduct('netcore22.exe',
            '/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
            CustomMessage('netcore22_title'),
            CustomMessage('netcore22_size'),
            netcore22_url,
            false, false, false);
end;

[Setup]