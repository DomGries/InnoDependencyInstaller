[Code]
var
	WindowsVersion: TWindowsVersion;

function exactwinversion(MajorVersion, MinorVersion: integer): boolean;
begin
	GetWindowsVersionEx(WindowsVersion);
	Result := ((WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor = MinorVersion));
end;

function exactwinspversion(MajorVersion, MinorVersion, SpVersion: integer): boolean;
begin
	GetWindowsVersionEx(WindowsVersion);
	Result := (exactwinversion(MajorVersion, MinorVersion) and (WindowsVersion.ServicePackMajor = SpVersion));
end;

function minwinversion(MajorVersion, MinorVersion: integer): boolean;
begin
	GetWindowsVersionEx(WindowsVersion);
	Result := (WindowsVersion.Major > MajorVersion) or ((WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor >= MinorVersion));
end;

function minwinspversion(MajorVersion, MinorVersion, SpVersion: integer): boolean;
begin
	GetWindowsVersionEx(WindowsVersion);
	if ((WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor = MinorVersion)) then
	   Result := (WindowsVersion.ServicePackMajor >= SpVersion)
	else
	   Result := minwinversion(MajorVersion, MinorVersion);
end;

function maxwinversion(MajorVersion, MinorVersion: integer): boolean;
begin
	GetWindowsVersionEx(WindowsVersion);
	Result := (WindowsVersion.Major < MajorVersion) or ((WindowsVersion.Major == MajorVersion) and (WindowsVersion.Minor <= MinorVersion));
end;

function maxwinspversion(MajorVersion, MinorVersion, SpVersion: integer): boolean;
begin
	GetWindowsVersionEx(WindowsVersion);
	if ((WindowsVersion.Major = MajorVersion) and (WindowsVersion.Minor = MinorVersion)) then
	   Result := (WindowsVersion.ServicePackMajor <= SpVersion)
	else
	   Result := maxwinversion(MajorVersion, MinorVersion);
end;