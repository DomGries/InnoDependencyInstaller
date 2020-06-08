[Code]
type
	NetCoreType = (NetC21, NetC22, NetC30, NetC31);

const
    netcore_reg_x64 = 'Software\WOW6432Node\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.NETCore.App\';
	netcore_reg_x86 = 'Software\WOW6432Node\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.NETCore.App\';

function netcoreversioninstalled(version: NetCoreType): Boolean;
var
    netcore_reg: String;
	names: TArrayOfString;
    regVersion: String;
    i: Integer;
begin
    Result := false;
    case ProcessorArchitecture of
        paX64: netcore_reg := netcore_reg_x64;
        paX86: netcore_reg := netcore_reg_x86;
    end;

    if RegGetValueNames(HKLM, netcore_reg, names) then
        begin
            case version of
                NetC21:
                    regVersion := '2.1';
                NetC22:
                    regVersion := '2.2';
                NetC30:
                    regVersion := '3.0';
                NetC31:
                    regVersion := '3.1';
            end;

            for i := 0 to GetArrayLength(names)-1 do
                begin
                    if pos(regVersion, names[i]) == 0 then
                        begin
                            Result := true;
                            break;
                        end;
                end;
        end;
end;

[Setup]