// https://www.microsoft.com/download/en/details.aspx?id=3743

[Code]
const
	sql2008express_url = 'https://download.microsoft.com/download/5/1/A/51A153F6-6B08-4F94-A7B2-BA1AD482BC75/SQLEXPR32_x86_ENU.exe';
	sql2008express_url_x64 = 'https://download.microsoft.com/download/5/1/A/51A153F6-6B08-4F94-A7B2-BA1AD482BC75/SQLEXPR_x64_ENU.exe';

procedure sql2008express;
var
	Version: String;
begin
	// This check does not take into account that a full version of SQL Server could be installed,
	// making Express unnecessary.
	if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\SQLEXPRESS\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (compareversion(Version, '10.5') < 0) then begin
		AddProduct('sql2008express' + GetArchitectureSuffix + '.exe',
			'/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=Install /FEATURES=All /INSTANCENAME=SQLEXPRESS /SQLSVCACCOUNT="NT AUTHORITY\Network Service" /SQLSYSADMINACCOUNTS="builtin\administrators"',
			'SQL Server 2008 Express R2',
			GetString(sql2008express_url, sql2008express_url_x64),
			'', False, False, False);
	end;
end;
