# Inno Setup Dependency Installer

[![Compile Check](https://github.com/DomGries/InnoDependencyInstaller/actions/workflows/compile-check.yml/badge.svg)](https://github.com/DomGries/InnoDependencyInstaller/actions/workflows/compile-check.yml)
[![Install Test](https://github.com/DomGries/InnoDependencyInstaller/actions/workflows/install-test.yml/badge.svg)](https://github.com/DomGries/InnoDependencyInstaller/actions/workflows/install-test.yml)

![Inno Setup Dependency Installer](https://user-images.githubusercontent.com/341158/122873592-3e2e9d80-d332-11eb-8055-8a4c6064ac4e.gif)

**Inno Setup Dependency Installer** automatically downloads and installs any dependency such as .NET, Visual C++, SQL Server, and more during your application's installation. One line per dependency is all it takes — missing ones are installed before your application, anything already present is skipped. More than 60 dependencies are [built in](#supported-dependencies) and you can [add your own](#adding-your-own-dependency).

Requires [Inno Setup 6.4 or newer](https://www.jrsoftware.org/isinfo.php).

## Getting started

1. [Download this repository](https://github.com/DomGries/InnoDependencyInstaller/archive/master.zip) (or clone it) and copy _CodeDependencies.iss_ next to your setup script.

2. Include it at the top of your script:

   ```iss
   #include "CodeDependencies.iss"
   ```

3. Add Inno's standard `InitializeSetup` event function to your `[Code]` section (or extend your existing one) and call one function per dependency your application needs — pick them from the [table below](#supported-dependencies):

   ```iss
   [Code]
   function InitializeSetup: Boolean;
   begin
     // add the dependencies your application needs, for example:
     Dependency_AddVC14;             // Visual C++ Redistributable, needed by most C++ apps
     Dependency_AddDotNet100Desktop; // .NET Desktop Runtime, needed by WPF/WinForms apps

     Result := True;
   end;
   ```

4. Check your `[Setup]` section:

   ```iss
   [Setup]
   ; dependencies are installed for all users, which requires administrative rights
   PrivilegesRequired=admin
   ; enables 64-bit install mode on x64 and Windows on ARM
   ; remove this line if you only deploy 32-bit binaries and dependencies
   ArchitecturesInstallIn64BitMode=x64compatible or arm64
   ```

5. Build your setup with the Inno Setup compiler — that's it. On machines where a dependency is missing, it is downloaded and installed first, as shown in the animation above.

Prefer starting from a working example instead? _ExampleSetup.iss_ in this repository is a complete setup script that uses every dependency. Open it in the Inno Setup compiler, keep the calls for the dependencies you need and comment out the rest, then build:

```iss
Dependency_AddVC2013;   // installed in example setup
//Dependency_AddVC2013; // commented out and not installed in example setup
```

## Supported dependencies

Call any of these functions inside `InitializeSetup`. Every function first checks whether the dependency is already installed and does nothing if so. The matching x86, x64 or ARM64 variant is selected automatically based on the target system.

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
| Windows App SDK Runtime 2.0 (WinUI 3) | `Dependency_AddWinAppRuntime20` |
| Windows App SDK Runtime 2.1 (WinUI 3) | `Dependency_AddWinAppRuntime21` |
| OpenJDK 8 (Eclipse Temurin, x86/x64) | `Dependency_AddJava8` |
| OpenJDK 11 (Microsoft Build of OpenJDK, x64/arm64) | `Dependency_AddJava11` |
| OpenJDK 17 (Microsoft Build of OpenJDK, x64/arm64) | `Dependency_AddJava17` |
| OpenJDK 21 (Microsoft Build of OpenJDK, x64/arm64) | `Dependency_AddJava21` |
| OpenJDK 25 (Microsoft Build of OpenJDK, x64/arm64) | `Dependency_AddJava25` |
| Python 3.13 | `Dependency_AddPython313` |
| Python 3.14 | `Dependency_AddPython314` |
| PowerShell 7 | `Dependency_AddPowerShell7` |

## What happens during the setup

1. When the setup starts, every added dependency is checked and only the missing ones are kept.
2. The user sees the pending dependencies listed on the _Ready to Install_ page.
3. After clicking _Install_, the missing installers are downloaded from their official sources, with a progress bar and a retry prompt if a download fails.
4. Each dependency installs unattended, one after another, and then your application is installed as usual.
5. If a dependency requires a Windows restart, the setup takes care of it: it prompts for the restart at the end — or, when other dependencies are still pending, offers to restart right away and resumes the setup after the reboot.
6. If an installer fails, the user can retry, ignore or abort. Setups running with `/SILENT` or `/VERYSILENT` install all dependencies fully silently, and `/SUPPRESSMSGBOXES` continues automatically on errors.

## Adding your own dependency

Any installer that supports unattended command-line arguments works. Check whether your dependency is missing, then describe it with `Dependency_Add`:

```iss
if not RegKeyExists(HKLM, 'SOFTWARE\MyRuntime') then begin
  Dependency_Add('myruntime.exe',        // file name in the setup's temporary directory
    '/quiet /norestart',                 // arguments for an unattended installation
    'My Runtime 1.0',                    // name shown to the user
    'https://example.com/myruntime.exe', // download URL
    '',                                  // optional SHA-256 checksum the download must match
    False,                               // ForceSuccess: treat any exit code as success
    False);                              // RestartAfter: request a Windows restart afterwards
end;
```

For architecture-dependent downloads use `Dependency_String(x86Url, x64Url, arm64Url)`, which returns the URL matching the target system. `Dependency_IsX64` and `Dependency_IsArm64` can likewise be used as `Check:` functions in `[Files]` to install the matching binaries of your own application (see _ExampleSetup.iss_).

## Bundling installers instead of downloading

By default, missing dependencies are downloaded while the setup runs. You can also pack a dependency installer into your setup — to support offline installations or just to avoid downloads. A file that already exists in the setup's temporary directory is used directly and never downloaded.

For example, a game setup can carry the small DirectX web setup with it:

```iss
[Files]
Source: "dependencies\dxwebsetup.exe"; Flags: dontcopy noencryption
```

```iss
[Code]
function InitializeSetup: Boolean;
begin
  ExtractTemporaryFile('dxwebsetup.exe'); // now already present, so not downloaded
  Dependency_AddDirectX;

  Result := True;
end;
```

This works the same way for every dependency, including [your own](#adding-your-own-dependency). Keep in mind that some installers — like the DirectX web setup — download further components themselves, so bundling them alone does not make the installation fully offline.

## Options

**32-bit dependencies on a 64-bit system** — for example when your application itself is 32-bit:

```iss
Dependency_ForceX86 := True; // force 32-bit install of next dependencies
Dependency_AddVC2013;
Dependency_ForceX86 := False; // disable forced 32-bit install again
```

`Dependency_ForceX64` works the same way to force x64 dependencies on ARM64 systems.

**Dependencies of optional [components](https://jrsoftware.org/ishelp/index.php?topic=componentssection)** — only downloaded and installed when the user selects a matching component:

```iss
Dependency_Components := 'advanced'; // only install next dependencies if the 'advanced' component is selected
Dependency_AddDotNet100;
Dependency_Components := ''; // disable component gating again
```

`Dependency_Components` accepts the same expression syntax as Inno's [Components](https://jrsoftware.org/ishelp/index.php?topic=scriptfunctions) parameter (e.g. `'feature1 or feature2'`).

**Defines** — set before the `#include` to change how the library integrates:

| Define | Effect |
| --- | --- |
| `Dependency_NoUpdateReadyMemo` | Don't attach the `UpdateReadyMemo` event — for scripts implementing their own (call `Dependency_UpdateReadyMemo` from it to keep the dependency listing) |
| `Dependency_CustomExecute` | Name of your own function `function MyExecute(const File, Parameters: String; var ResultCode: Integer): Boolean;` used to run the installers instead of `ShellExec` |

## Credits

Thanks to the community for sharing many fixes and improvements. To contribute please [create a pull request](https://github.com/DomGries/InnoDependencyInstaller/pulls).

## License

[MIT License](https://github.com/DomGries/InnoDependencyInstaller/blob/master/LICENSE.md)
