#include "common.iss"

[Code]
procedure IDI_UseMsi45;
var
  Version: String;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=8483
  if not GetVersionNumbersString(ExpandConstant('{sys}{\}msi.dll'), Version) or (IDI_CompareVersion(Version, '4.5') < 0) then begin
    IDI_AddDependency('msi45' + IDI_GetArchitectureSuffix + '.msu',
      '/quiet /norestart',
      'Windows Installer 4.5',
      IDI_GetString('https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x86.msu', 'https://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/Windows6.0-KB942288-v2-x64.msu'),
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet11;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=26
  if not IsDotNetInstalled(net11, 0) then begin
    IDI_AddDependency('dotnetfx11.exe',
      '/q',
      '.NET Framework 1.1',
      'https://download.microsoft.com/download/a/a/c/aac39226-8825-44ce-90e3-bf8203e74006/dotnetfx.exe',
      '', False, False, False);
  end;

  // https://www.microsoft.com/en-US/download/details.aspx?id=33
  if not IsDotNetInstalled(net11, 1) then begin
    IDI_AddDependency('dotnetfx11sp1.exe',
      '/q',
      '.NET Framework 1.1 Service Pack 1',
      'https://download.microsoft.com/download/8/b/4/8b4addd8-e957-4dea-bdb8-c4e00af5b94b/NDP1.1sp1-KB867460-X86.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet20;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=1639
  if not IsDotNetInstalled(net20, 2) then begin
    IDI_AddDependency('dotnetfx20' + IDI_GetArchitectureSuffix + '.exe',
      '/lang:enu /passive /norestart',
      '.NET Framework 2.0 Service Pack 2',
      IDI_GetString('https://download.microsoft.com/download/c/6/e/c6e88215-0178-4c6c-b5f3-158ff77b1f38/NetFx20SP2_x86.exe', 'https://download.microsoft.com/download/c/6/e/c6e88215-0178-4c6c-b5f3-158ff77b1f38/NetFx20SP2_x64.exe'),
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet35;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=22
  if not IsDotNetInstalled(net35, 1) then begin
    IDI_AddDependency('dotnetfx35.exe',
      '/lang:enu /passive /norestart',
      '.NET Framework 3.5 Service Pack 1',
      'https://download.microsoft.com/download/0/6/1/061f001c-8752-4600-a198-53214c69b51f/dotnetfx35setup.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet40Client;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=24872
  if not IsDotNetInstalled(net4client, 0) and not IsDotNetInstalled(net4full, 0) then begin
    IDI_AddDependency('dotNetFx40_Client_setup.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.0 Client',
      'https://download.microsoft.com/download/7/B/6/7B629E05-399A-4A92-B5BC-484C74B5124B/dotNetFx40_Client_setup.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet40Full;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=17718
  if not IsDotNetInstalled(net4full, 0) then begin
    IDI_AddDependency('dotNetFx40_Full_setup.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.0',
      'https://download.microsoft.com/download/1/B/E/1BE39E79-7E39-46A3-96FF-047F95396215/dotNetFx40_Full_setup.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet45;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=42643
  if not IsDotNetInstalled(net452, 0) then begin
    IDI_AddDependency('dotnetfx45.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.5.2',
      'https://download.microsoft.com/download/B/4/1/B4119C11-0423-477B-80EE-7A474314B347/NDP452-KB2901954-Web.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet46;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=53345
  if not IsDotNetInstalled(net462, 0) then begin
    IDI_AddDependency('dotnetfx46.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.6.2',
      'https://download.microsoft.com/download/D/5/C/D5C98AB0-35CC-45D9-9BA5-B18256BA2AE6/NDP462-KB3151802-Web.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet47;
begin
  // https://support.microsoft.com/en-US/help/4054531
  if not IsDotNetInstalled(net472, 0) then begin
    IDI_AddDependency('dotnetfx47.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.7.2',
      'https://download.microsoft.com/download/0/5/C/05C1EC0E-D5EE-463B-BFE3-9311376A6809/NDP472-KB4054531-Web.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet48;
begin
  // https://dotnet.microsoft.com/download/dotnet-framework/net48
  if not IsDotNetInstalled(net48, 0) then begin
    IDI_AddDependency('dotnetfx48.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Framework 4.8',
      'https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/c9b8749dd99fc0d4453b2a3e4c37ba16/ndp48-web.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseNetCore31;
begin
  // https://dotnet.microsoft.com/download/dotnet-core/3.1
  if not IDI_IsNetCoreInstalled('Microsoft.NETCore.App 3.1.11') then begin
    IDI_AddDependency('netcore31' + IDI_GetArchitectureSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Core Runtime 3.1.11' + IDI_GetArchitectureTitle,
      IDI_GetString('https://go.microsoft.com/fwlink/?linkid=2153351', 'https://go.microsoft.com/fwlink/?linkid=2153460'),
      '', False, False, False);
  end;
end;

procedure IDI_UseNetCore31Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet-core/3.1
  if not IDI_IsNetCoreInstalled('Microsoft.AspNetCore.App 3.1.11') then begin
    IDI_AddDependency('netcore31asp' + IDI_GetArchitectureSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 3.1.11' + IDI_GetArchitectureTitle,
      IDI_GetString('https://go.microsoft.com/fwlink/?linkid=2153349', 'https://go.microsoft.com/fwlink/?linkid=2153348'),
      '', False, False, False);
  end;
end;

procedure IDI_UseNetCore31Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet-core/3.1
  if not IDI_IsNetCoreInstalled('Microsoft.WindowsDesktop.App 3.1.11') then begin
    IDI_AddDependency('netcore31desktop' + IDI_GetArchitectureSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 3.1.11' + IDI_GetArchitectureTitle,
      IDI_GetString('https://go.microsoft.com/fwlink/?linkid=2153350', 'https://go.microsoft.com/fwlink/?linkid=2153459'),
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet50;
begin
  // https://dotnet.microsoft.com/download/dotnet/5.0
  if not IDI_IsNetCoreInstalled('Microsoft.NETCore.App 5.0.2') then begin
    IDI_AddDependency('dotnet50' + IDI_GetArchitectureSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Runtime 5.0.2' + IDI_GetArchitectureTitle,
      IDI_GetString('https://go.microsoft.com/fwlink/?linkid=2153463', 'https://go.microsoft.com/fwlink/?linkid=2153354'),
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet50Asp;
begin
  // https://dotnet.microsoft.com/download/dotnet/5.0
  if not IDI_IsNetCoreInstalled('Microsoft.AspNetCore.App 5.0.2') then begin
    IDI_AddDependency('dotnet50asp' + IDI_GetArchitectureSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      'ASP.NET Core Runtime 5.0.2' + IDI_GetArchitectureTitle,
      IDI_GetString('https://go.microsoft.com/fwlink/?linkid=2153461', 'https://go.microsoft.com/fwlink/?linkid=2153352'),
      '', False, False, False);
  end;
end;

procedure IDI_UseDotNet50Desktop;
begin
  // https://dotnet.microsoft.com/download/dotnet/5.0
  if not IDI_IsNetCoreInstalled('Microsoft.WindowsDesktop.App 5.0.2') then begin
    IDI_AddDependency('dotnet50desktop' + IDI_GetArchitectureSuffix + '.exe',
      '/lcid ' + IntToStr(GetUILanguage) + ' /passive /norestart',
      '.NET Desktop Runtime 5.0.2' + IDI_GetArchitectureTitle,
      IDI_GetString('https://go.microsoft.com/fwlink/?linkid=2153462', 'https://go.microsoft.com/fwlink/?linkid=2153353'),
      '', False, False, False);
  end;
end;

procedure IDI_UseVC2005;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=26347
  if not IDI_IsMsiProductInstalled(IDI_GetString('{86C9D5AA-F00C-4921-B3F2-C60AF92E2844}', '{A8D19029-8E5C-4E22-8011-48070F9E796E}'), '8.0.61000') then begin
    IDI_AddDependency('vcredist2005' + IDI_GetArchitectureSuffix + '.exe',
      '/q',
      'Visual C++ 2005 Service Pack 1 Redistributable' + IDI_GetArchitectureTitle,
      IDI_GetString('https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE', 'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE'),
      '', False, False, False);
  end;
end;

procedure IDI_UseVC2008;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=26368
  if not IDI_IsMsiProductInstalled(IDI_GetString('{DE2C306F-A067-38EF-B86C-03DE4B0312F9}', '{FDA45DDF-8E17-336F-A3ED-356B7B7C688A}'), '9.0.30729.6161') then begin
    IDI_AddDependency('vcredist2008' + IDI_GetArchitectureSuffix + '.exe',
      '/q',
      'Visual C++ 2008 Service Pack 1 Redistributable' + IDI_GetArchitectureTitle,
      IDI_GetString('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe', 'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe'),
      '', False, False, False);
  end;
end;

procedure IDI_UseVC2010;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=26999
  if not IDI_IsMsiProductInstalled(IDI_GetString('{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}', '{5B75F761-BAC8-33BC-A381-464DDDD813A3}'), '10.0.40219') then begin
    IDI_AddDependency('vcredist2010' + IDI_GetArchitectureSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2010 Service Pack 1 Redistributable' + IDI_GetArchitectureTitle,
      IDI_GetString('https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe'),
      '', False, False, False);
  end;
end;

procedure IDI_UseVC2012;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=30679
  if not IDI_IsMsiProductInstalled(IDI_GetString('{4121ED58-4BD9-3E7B-A8B5-9F8BAAE045B7}', '{EFA6AFA1-738E-3E00-8101-FD03B86B29D1}'), '11.0.61030') then begin
    IDI_AddDependency('vcredist2012' + IDI_GetArchitectureSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2012 Update 4 Redistributable' + IDI_GetArchitectureTitle,
      IDI_GetString('https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe', 'https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe'),
      '', False, False, False);
  end;
end;

procedure IDI_UseVC2013;
begin
  //ForceX86 := True; // force 32-bit install of next dependencies
  // https://support.microsoft.com/en-US/help/4032938
  if not IDI_IsMsiProductInstalled(IDI_GetString('{B59F5BF1-67C8-3802-8E59-2CE551A39FC5}', '{20400CF0-DE7C-327E-9AE4-F0F38D9085F8}'), '12.0.40664') then begin
    IDI_AddDependency('vcredist2013' + IDI_GetArchitectureSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2013 Update 5 Redistributable' + IDI_GetArchitectureTitle,
      IDI_GetString('https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe', 'https://download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe'),
      '', False, False, False);
  end;
  //ForceX86 := False; // disable forced 32-bit install again
end;

procedure IDI_UseVC2015To2019;
begin
  // https://support.microsoft.com/en-US/help/2977003/the-latest-supported-visual-c-downloads
  if not IDI_IsMsiProductInstalled(IDI_GetString('{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}'), '14.28.29325') then begin
    IDI_AddDependency('vcredist2019' + IDI_GetArchitectureSuffix + '.exe',
      '/passive /norestart',
      'Visual C++ 2015-2019 Redistributable' + IDI_GetArchitectureTitle,
      IDI_GetString('https://aka.ms/vs/16/release/vc_redist.x86.exe', 'https://aka.ms/vs/16/release/vc_redist.x64.exe'),
      '', False, False, False);
  end;
end;

procedure IDI_UseDirectX;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=35
  ExtractTemporaryFile('dxwebsetup.exe');
  IDI_AddDependency('dxwebsetup.exe',
    '/q',
    'DirectX Runtime',
    'https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe',
    '', True, False, False);
end;

procedure IDI_UseSql2008Express;
var
  Version: String;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=30438
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (IDI_CompareVersion(Version, '10.50.4000') < 0) then begin
    IDI_AddDependency('sql2008express' + IDI_GetArchitectureSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2008 R2 Service Pack 2 Express',
      IDI_GetString('https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR_x64_ENU.exe'),
      '', False, False, False);
  end;
end;

procedure IDI_UseSql2012Express;
var
  Version: String;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=56042
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (IDI_CompareVersion(Version, '11.0.7001') < 0) then begin
    IDI_AddDependency('sql2012express' + IDI_GetArchitectureSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2012 Service Pack 4 Express',
      IDI_GetString('https://download.microsoft.com/download/B/D/E/BDE8FAD6-33E5-44F6-B714-348F73E602B6/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/B/D/E/BDE8FAD6-33E5-44F6-B714-348F73E602B6/SQLEXPR_x64_ENU.exe'),
      '', False, False, False);
  end;
end;

procedure IDI_UseSql2014Express;
var
  Version: String;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=57473
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (IDI_CompareVersion(Version, '12.0.6024') < 0) then begin
    IDI_AddDependency('sql2014express' + IDI_GetArchitectureSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2014 Service Pack 3 Express',
      IDI_GetString('https://download.microsoft.com/download/3/9/F/39F968FA-DEBB-4960-8F9E-0E7BB3035959/SQLEXPR32_x86_ENU.exe', 'https://download.microsoft.com/download/3/9/F/39F968FA-DEBB-4960-8F9E-0E7BB3035959/SQLEXPR_x64_ENU.exe'),
      '', False, False, False);
  end;
end;

procedure IDI_UseSql2016Express;
var
  Version: String;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=56840
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (IDI_CompareVersion(Version, '13.0.5026') < 0) then begin
    IDI_AddDependency('sql2016express' + IDI_GetArchitectureSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2016 Service Pack 2 Express',
      'https://download.microsoft.com/download/3/7/6/3767D272-76A1-4F31-8849-260BD37924E4/SQLServer2016-SSEI-Expr.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseSql2017Express;
var
  Version: String;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=55994
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (IDI_CompareVersion(Version, '14') < 0) then begin
    IDI_AddDependency('sql2017express' + IDI_GetArchitectureSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2017 Express',
      'https://download.microsoft.com/download/5/E/9/5E9B18CC-8FD5-467E-B5BF-BADE39C51F73/SQLServer2017-SSEI-Expr.exe',
      '', False, False, False);
  end;
end;

procedure IDI_UseSql2019Express;
var
  Version: String;
begin
  // https://www.microsoft.com/en-US/download/details.aspx?id=101064
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQLServer\CurrentVersion', 'CurrentVersion', Version) or (IDI_CompareVersion(Version, '15') < 0) then begin
    IDI_AddDependency('sql2019express' + IDI_GetArchitectureSuffix + '.exe',
      '/QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=INSTALL /FEATURES=SQL /INSTANCENAME=MSSQLSERVER',
      'SQL Server 2019 Express',
      'https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe',
      '', False, False, False);
  end;
end;
