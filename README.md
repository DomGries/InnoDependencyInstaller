# Inno Setup Dependency Installer

[![Compile Check](https://github.com/DomGries/InnoDependencyInstaller/actions/workflows/compile-check.yml/badge.svg)](https://github.com/DomGries/InnoDependencyInstaller/actions/workflows/compile-check.yml)
[![Install Test](https://github.com/DomGries/InnoDependencyInstaller/actions/workflows/install-test.yml/badge.svg)](https://github.com/DomGries/InnoDependencyInstaller/actions/workflows/install-test.yml)

![Inno Setup Dependency Installer](https://user-images.githubusercontent.com/341158/122873592-3e2e9d80-d332-11eb-8055-8a4c6064ac4e.gif)

**Inno Setup Dependency Installer** downloads and installs the dependencies of your application, such as .NET, Visual C++ or SQL Server, before your application is installed. You only need to add one code line per dependency. Dependencies that are already installed are skipped. More than 60 dependencies are [built in](#supported-dependencies), and you can [add your own](#adding-your-own-dependency).

Requires [Inno Setup 6.7 or newer](https://www.jrsoftware.org/isinfo.php).

## Getting started

1. [Download this repository](https://github.com/DomGries/InnoDependencyInstaller/archive/master.zip) and copy _CodeDependencies.iss_ next to your setup script.

2. Include it at the top of your script:

   ```iss
   #include "CodeDependencies.iss"
   ```

3. In the `[Code]` section, add the dependencies in the `InitializeSetup` event function. If your script already has this function, add the calls there. Choose the dependencies from the [table below](#supported-dependencies):

   ```iss
   [Code]
   function InitializeSetup: Boolean;
   begin
     Dependency_AddVC14;             // Visual C++ Redistributable
     Dependency_AddDotNet100Desktop; // .NET Desktop Runtime for WPF and Windows Forms apps

     Result := True;
   end;
   ```

4. Set these values in the `[Setup]` section:

   ```iss
   [Setup]
   ; dependencies are installed for all users, which needs administrative rights
   PrivilegesRequired=admin
   ; installs 64-bit dependencies on x64 and ARM64 Windows
   ; remove this line if your application and its dependencies are 32-bit only
   ArchitecturesInstallIn64BitMode=x64compatible or arm64
   ```

5. Compile your setup.

_ExampleSetup.iss_ is a complete example that uses every dependency. Remove or comment out the ones you do not need:

```iss
Dependency_AddVC2013;   // installed
//Dependency_AddVC2013; // not installed
```

## Supported dependencies

Call these functions in `InitializeSetup`. Each function adds the dependency only if it is not installed yet. The x86, x64 or ARM64 version is selected automatically.

| Dependency | Function |
| --- | --- |
| .NET Framework 3.5 Service Pack 1 | `Dependency_AddDotNet35` |
| .NET Framework 4.0 | `Dependency_AddDotNet40` |
| .NET Framework 4.5.2 | `Dependency_AddDotNet45` |
| .NET Framework 4.6.2 | `Dependency_AddDotNet46` |
| .NET Framework 4.7.2 | `Dependency_AddDotNet47` |
| .NET Framework 4.8 | `Dependency_AddDotNet48` |
| .NET Framework 4.8.1 | `Dependency_AddDotNet481` |
| .NET Core Runtime 3.1 | `Dependency_AddNetCore31` |
| ASP.NET Core Runtime 3.1 | `Dependency_AddNetCore31Asp` |
| .NET Desktop Runtime 3.1 | `Dependency_AddNetCore31Desktop` |
| .NET Runtime 5.0 | `Dependency_AddDotNet50` |
| ASP.NET Core Runtime 5.0 | `Dependency_AddDotNet50Asp` |
| .NET Desktop Runtime 5.0 | `Dependency_AddDotNet50Desktop` |
| .NET Runtime 6.0 | `Dependency_AddDotNet60` |
| ASP.NET Core Runtime 6.0 | `Dependency_AddDotNet60Asp` |
| .NET Desktop Runtime 6.0 | `Dependency_AddDotNet60Desktop` |
| .NET Runtime 7.0 | `Dependency_AddDotNet70` |
| ASP.NET Core Runtime 7.0 | `Dependency_AddDotNet70Asp` |
| .NET Desktop Runtime 7.0 | `Dependency_AddDotNet70Desktop` |
| .NET Runtime 8.0 | `Dependency_AddDotNet80` |
| ASP.NET Core Runtime 8.0 | `Dependency_AddDotNet80Asp` |
| ASP.NET Core Hosting Bundle 8.0 | `Dependency_AddDotNet80Hosting` |
| .NET Desktop Runtime 8.0 | `Dependency_AddDotNet80Desktop` |
| .NET Runtime 9.0 | `Dependency_AddDotNet90` |
| ASP.NET Core Runtime 9.0 | `Dependency_AddDotNet90Asp` |
| ASP.NET Core Hosting Bundle 9.0 | `Dependency_AddDotNet90Hosting` |
| .NET Desktop Runtime 9.0 | `Dependency_AddDotNet90Desktop` |
| .NET Runtime 10.0 | `Dependency_AddDotNet100` |
| ASP.NET Core Runtime 10.0 | `Dependency_AddDotNet100Asp` |
| ASP.NET Core Hosting Bundle 10.0 | `Dependency_AddDotNet100Hosting` |
| .NET Desktop Runtime 10.0 | `Dependency_AddDotNet100Desktop` |
| Visual C++ 2005 Service Pack 1 Redistributable | `Dependency_AddVC2005` |
| Visual C++ 2008 Service Pack 1 Redistributable | `Dependency_AddVC2008` |
| Visual C++ 2010 Service Pack 1 Redistributable | `Dependency_AddVC2010` |
| Visual C++ 2012 Update 4 Redistributable | `Dependency_AddVC2012` |
| Visual C++ 2013 Update 5 Redistributable | `Dependency_AddVC2013` |
| Visual C++ v14 Redistributable (2015–2026) | `Dependency_AddVC14` |
| SQL Server 2008 R2 Service Pack 2 Express | `Dependency_AddSql2008Express` |
| SQL Server 2012 Service Pack 4 Express | `Dependency_AddSql2012Express` |
| SQL Server 2014 Service Pack 3 Express | `Dependency_AddSql2014Express` |
| SQL Server 2016 Service Pack 3 Express | `Dependency_AddSql2016Express` |
| SQL Server 2017 Express | `Dependency_AddSql2017Express` |
| SQL Server 2019 Express | `Dependency_AddSql2019Express` |
| SQL Server 2022 Express | `Dependency_AddSql2022Express` |
| SQL Server 2025 Express | `Dependency_AddSql2025Express` |
| OLE DB Driver 19 for SQL Server | `Dependency_AddSqlOleDb19` |
| ODBC Driver 18 for SQL Server | `Dependency_AddSqlOdbc18` |
| Access Database Engine 2016 | `Dependency_AddAccessDatabaseEngine2016` |
| Visual Studio 2010 Tools for Office Runtime (VSTO) | `Dependency_AddVSTORuntime` |
| DirectX End-User Runtime | `Dependency_AddDirectX` |
| WebView2 Runtime | `Dependency_AddWebView2` |
| Windows App SDK Runtime 1.6 (WinUI 3) | `Dependency_AddWinAppRuntime16` |
| Windows App SDK Runtime 1.7 (WinUI 3) | `Dependency_AddWinAppRuntime17` |
| Windows App SDK Runtime 1.8 (WinUI 3) | `Dependency_AddWinAppRuntime18` |
| Windows App SDK Runtime 2 (WinUI 3) | `Dependency_AddWinAppRuntime2` |
| OpenJDK 8 (Eclipse Temurin, x86/x64) | `Dependency_AddJava8` |
| OpenJDK 11 (Microsoft Build of OpenJDK, x64/arm64) | `Dependency_AddJava11` |
| OpenJDK 17 (Microsoft Build of OpenJDK, x64/arm64) | `Dependency_AddJava17` |
| OpenJDK 21 (Microsoft Build of OpenJDK, x64/arm64) | `Dependency_AddJava21` |
| OpenJDK 25 (Microsoft Build of OpenJDK, x64/arm64) | `Dependency_AddJava25` |
| Python 3.13 | `Dependency_AddPython313` |
| Python 3.14 | `Dependency_AddPython314` |
| PowerShell 7 | `Dependency_AddPowerShell7` |

## What happens during the setup

1. `InitializeSetup` checks each dependency and keeps only the missing ones. The _Ready to Install_ page lists them.
2. After the user clicks _Install_, each installer is downloaded from its official source. Every built-in download is checked against a SHA-256 checksum, so a changed or broken file is never run. A failed download is retried a few times. Then the user can retry, ignore or abort.
3. The installers run one after another without user input. If another installation is already running, for example Windows Update, the setup waits for it. If an installer fails, the user can retry, ignore or abort.
4. Your application is installed.
5. If a dependency needs a restart, the setup asks for it at the end. If the restart is needed before the next dependency can be installed, the setup asks to restart Windows at once and continues after the restart.

With `/SILENT` or `/VERYSILENT` the installers run silently. With `/SUPPRESSMSGBOXES` no questions are asked, so a download or installer that still fails after the automatic retries aborts the setup.

## Adding your own dependency

You can use any installer that can run without user input. Add it with `Dependency_AddIfMissing`. The first argument is your own check whether the dependency is missing:

```iss
Dependency_AddIfMissing(not RegKeyExists(HKLM, 'SOFTWARE\MyRuntime'),
  'myruntime.exe',                     // file name in the temporary directory of the setup
  '/quiet /norestart',                 // arguments for an installation without user input
  'My Runtime 1.0',                    // name shown to the user
  'https://example.com/myruntime.exe', // download URL
  '',                                  // SHA-256 checksum of the download, optional
  False,                               // ForceSuccess: treat every exit code as success
  False);                              // RestartAfter: restart Windows after the installation
```

The result of the check is written to the setup log. `Dependency_Add` takes the same arguments without the first one and always adds the dependency.

Instead of a file name you can pass the full path of a program that is already on the computer. Nothing is downloaded then. For example, the built-in .NET Framework 3.5 dependency enables a Windows feature:

```iss
Dependency_AddIfMissing(not IsDotNetInstalled(net35, 1),
  GetSysNativeDir + '\dism.exe',
  '/online /enable-feature /featurename:NetFx3 /all /quiet /norestart',
  '.NET Framework 3.5', '', '', False, False);
```

If the download depends on the architecture, use `Dependency_String(x86Url, x64Url, arm64Url)`. It returns the value for the architecture of the setup. An empty URL means that the dependency is not available for this architecture. `Dependency_StringWin` returns the value for the architecture of Windows instead. Use it for components that are shared by the whole system. On ARM64 Windows it returns the x64 value if the ARM64 value is empty.

`Dependency_IsX64` and `Dependency_IsArm64` can also be used as `Check:` functions in `[Files]` to install the matching files of your own application. See _ExampleSetup.iss_.

If you pass a SHA-256 checksum, the download is checked against it. If you pass an empty string, the download is not checked. Use `Dependency_String(x86Hash, x64Hash, arm64Hash)` for downloads that depend on the architecture. To get the checksum of a download, run:

```powershell
pwsh ./tools/Get-UrlSha256.ps1 'https://example.com/installer.exe'
```

## Bundling installers instead of downloading

By default, missing dependencies are downloaded during the setup. You can also put an installer into your setup, for example to install without internet access. If the file is already in the temporary directory of the setup, it is used and not downloaded. A bundled file is not checked against the checksum.

For example, to bundle the DirectX web setup:

```iss
[Files]
Source: "dependencies\dxwebsetup.exe"; Flags: dontcopy noencryption
```

```iss
[Code]
function InitializeSetup: Boolean;
begin
  ExtractTemporaryFile('dxwebsetup.exe'); // must come before Dependency_AddDirectX
  Dependency_AddDirectX;

  Result := True;
end;
```

This works the same way for every dependency, including [your own](#adding-your-own-dependency). Some installers, like the DirectX web setup, download more files themselves, so they still need internet access.

## Options

**32-bit dependencies on 64-bit Windows**, for example when your application is 32-bit:

```iss
Dependency_ForceX86 := True;  // the next dependencies are 32-bit
Dependency_AddVC2013;
Dependency_ForceX86 := False; // back to the default
```

`Dependency_ForceX64` works the same way. It selects x64 dependencies on ARM64 Windows, or in a setup that runs in 32-bit mode on 64-bit Windows. These options do not change dependencies that follow the architecture of Windows: SQL Server, OLE DB, ODBC, WebView2, OpenJDK and PowerShell.

**Dependencies of optional [components](https://jrsoftware.org/ishelp/index.php?topic=componentssection)** are only downloaded and installed if the user selects the component:

```iss
Dependency_Components := 'advanced'; // the next dependencies need the 'advanced' component
Dependency_AddDotNet100;
Dependency_Components := '';         // back to the default
```

`Dependency_Components` accepts the same expressions as the [Components](https://jrsoftware.org/ishelp/index.php?topic=scriptfunctions) parameter, for example `'feature1 or feature2'`.

**Defines** change how the library works. Set them before the `#include`:

| Define | Effect |
| --- | --- |
| `Dependency_NoUpdateReadyMemo` | Do not handle the `UpdateReadyMemo` event. Use it if your script has its own `UpdateReadyMemo` function. Call `Dependency_UpdateReadyMemo` from it to still list the dependencies. |
| `Dependency_CustomExecute` | Name of your own function that runs the installers instead of `ShellExec`: `function MyExecute(const Filename, Parameters: String; var ResultCode: Integer): Boolean;`. Declare it before the `#include`. |
| `Dependency_DownloadRetryCount` | How often a failed download is retried before the user is asked. Default `3`. Use `0` to ask at once. |
| `Dependency_DownloadRetryBackoffMs` | Delay in milliseconds before the first download retry. Retry _n_ waits _n_ times this delay. Default `2000`. |
| `Dependency_InstallBusyRetryCount` | How often an installer is retried if another installation is running. Default `30`. |
| `Dependency_InstallBusyRetryDelayMs` | Delay in milliseconds between these retries. Default `10000`. |

## Troubleshooting

Run your setup with `/LOG="C:\setup.log"`. With `/LOG` only, the log is written to `%TEMP%`. The library writes each decision to the log:

| Log entry | Meaning |
| --- | --- |
| `Dependency already installed: X` | _X_ is installed, so nothing is done. |
| `Dependency queued for download: X` | _X_ is missing and will be downloaded. |
| `Dependency queued (already present): X` | _X_ is missing. Its installer is already in the temporary directory or is a program on the computer, so it is not downloaded. |
| `Dependency not available for this architecture: X` | _X_ has no installer for this architecture. |
| `Dependency skipped (component not selected): X` | _X_ belongs to a component that the user did not select. |
| `Dependency skipped after failed download: X` | The download of _X_ failed and the user chose to ignore it. |
| `Dependency exit code N: X` | The installer of _X_ ended with exit code _N_. |

These exit codes count as success:

| Exit code | Meaning |
| --- | --- |
| `0` | Success. |
| `1638` | A newer version is already installed. |
| `3010` | Success. Windows must restart. The setup asks for the restart at the end. |
| `1641` | Success. The installer started a restart. The setup continues after the restart. |

Exit code `1618` means that another installation is running. The setup waits and tries again. Every other exit code is an error, unless `ForceSuccess` is set.

To continue after a restart, the setup adds itself to the `RunOnce` registry key. It is started again with the choices of the wizard, the original silent, restart and log switches, and `/restart=1`. Your script can check `/restart=1` with `ParamStr` if it must work differently after the restart. A log set with `/LOG="setup.log"` continues in `setup-2.log`.

## Credits

Thanks to the community for many fixes and improvements. To contribute, [create a pull request](https://github.com/DomGries/InnoDependencyInstaller/pulls).

## License

[MIT License](https://github.com/DomGries/InnoDependencyInstaller/blob/master/LICENSE.md)
