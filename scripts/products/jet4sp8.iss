// http://support.microsoft.com/kb/239114

[CustomMessages]
jet4sp8_title=Jet 4

en.jet4sp8_size=3.7 MB
de.jet4sp8_size=3,7 MB


[Run]
Filename: "{ini:{tmp}{\}dep.ini,install,jet4sp8}"; Description: "{cm:jet4sp8_title}"; StatusMsg: "{cm:depinstall_status,{cm:jet4sp8_title}}"; Parameters: "/q:a /c:""install /qb /l"""; Flags: skipifdoesntexist

[Code]
const
	jet4sp8_url = 'http://download.microsoft.com/download/4/3/9/4393c9ac-e69e-458d-9f6d-2fe191c51469/Jet40SP8_9xNT.exe';

procedure jet4sp8(MinVersion: string);
begin
	if (fileversion(ExpandConstant('{sys}{\}msjet40.dll')) < MinVersion) then
	   AddProduct('jet4sp8', 'jet4sp8.exe', CustomMessage('jet4sp8_title'), CustomMessage('jet4sp8_size'), jet4sp8_url);
end;