; requires Windows 10 Version 1607+, Windows 7 SP1+, Windows 8.1, Windows Server 2012 R2
; https://dotnet.microsoft.com/download/dotnet-core/3.1

[CustomMessages]
netcore31_title=.NET Core Runtime 3.1
netcore31_title_x64=.NET Core Runtime 3.1 64-Bit

netcore31_size=1 MB - 23 MB
netcore31_size_x64=1 MB - 25 MB

[Code]
const
	netcore31_url = 'http://download.visualstudio.microsoft.com/download/pr/717d875c-557e-4d61-a201-8822a2fe8003/ca8639545eb797adfdb8106d8f1a0791/dotnet-runtime-3.1.6-win-x86.exe';
	netcore31_url_x64 = 'http://download.visualstudio.microsoft.com/download/pr/518aafee-1285-4153-a30a-e4eefd538c90/6437d77a67b9c6b8cf0b7b3323004229/dotnet-runtime-3.1.6-win-x64.exe';

procedure netcore31();
begin
	if (not IsIA64()) then begin
		if not netcoreversioninstalled(Core, NetC31) then
			AddProduct('netcore31' + GetArchitectureString() + '.exe',
				'/lcid ' + CustomMessage('lcid') + ' /passive /norestart',
				CustomMessage('netcore31_title' + GetArchitectureString()),
				CustomMessage('netcore31_size' + GetArchitectureString()),
				GetString(netcore31_url, netcore31_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
