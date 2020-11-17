[Code]
function exactwinversion(MajorVersion, MinorVersion: Integer): Boolean;
var
	WindowsVersion: TWindowsVersion;
begin
	GetWindowsVersionEx(WindowsVersion);
	Result := (WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor = MinorVersion);
end;

function minwinversion(MajorVersion, MinorVersion: Integer): Boolean;
var
	WindowsVersion: TWindowsVersion;
begin
	GetWindowsVersionEx(WindowsVersion);
	Result := (WindowsVersion.Major > MajorVersion) or ((WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor >= MinorVersion));
end;

function maxwinversion(MajorVersion, MinorVersion: Integer): Boolean;
var
	WindowsVersion: TWindowsVersion;
begin
	GetWindowsVersionEx(WindowsVersion);
	Result := (WindowsVersion.Major < MajorVersion) or ((WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor <= MinorVersion));
end;

function exactwinspversion(MajorVersion, MinorVersion, SpVersion: Integer): Boolean;
var
	WindowsVersion: TWindowsVersion;
begin
	GetWindowsVersionEx(WindowsVersion);
	if (WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor = MinorVersion) then
		Result := WindowsVersion.ServicePackMajor = SpVersion
	else
		Result := true;
end;

function minwinspversion(MajorVersion, MinorVersion, SpVersion: Integer): Boolean;
var
	WindowsVersion: TWindowsVersion;
begin
	GetWindowsVersionEx(WindowsVersion);
	if (WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor = MinorVersion) then
		Result := WindowsVersion.ServicePackMajor >= SpVersion
	else
		Result := true;
end;

function maxwinspversion(MajorVersion, MinorVersion, SpVersion: Integer): Boolean;
var
	WindowsVersion: TWindowsVersion;
begin
	GetWindowsVersionEx(WindowsVersion);
	if (WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor = MinorVersion) then
		Result := WindowsVersion.ServicePackMajor <= SpVersion
	else
		Result := true;
end;
