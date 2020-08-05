[Code]
function GetFullVersion(VersionMS, VersionLS: Cardinal): String;
var
	version: String;
begin
	version := IntToStr(word(VersionMS shr 16));
	version := version + '.' + IntToStr(word(VersionMS and not $ffff0000));

	version := version + '.' + IntToStr(word(VersionLS shr 16));
	version := version + '.' + IntToStr(word(VersionLS and not $ffff0000));

	Result := version;
end;

function fileversion(file: String): String;
var
	versionMS, versionLS: Cardinal;
begin
	if GetVersionNumbers(file, versionMS, versionLS) then
		Result := GetFullVersion(versionMS, versionLS)
	else
		Result := '0';
end;

[Setup]
