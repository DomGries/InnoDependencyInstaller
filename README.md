# Inno Setup Dependency Installer

![Inno Setup Dependency Installer](https://user-images.githubusercontent.com/341158/122873592-3e2e9d80-d332-11eb-8055-8a4c6064ac4e.gif)

**Inno Setup Dependency Installer** can download and install any dependency such as .NET, Visual C++ or SQL Server during your application's installation. In addition, it is easy to add your own dependencies as well.

## Installation and Usage

1. Download and install [Inno Setup 6.2+](https://www.jrsoftware.org/isinfo.php).
2. Download [this repository](https://github.com/DomGries/InnoDependencyInstaller/archive/master.zip) or clone it.
3. Open the extracted _CodeDependencies.iss_ file.
4. Comment out dependency defines to disable installing them in the example setup and leave only dependencies that need to be installed:
    ```iss
    #define UseVC2013 <-- installed in example setup
    ;#define UseVC2013 <-- commented out and not installed in example setup
    ```
5. Modify other sections like _[Setup] [Files] [Icons]_ as necessary.
6. Build setup using Inno Setup compiler.

## Integration

You can include _CodeDependencies.iss_ file into your setup by disabling compilation of the example setup before and calling the desired _Dependency_Add_ functions:

```iss
#define public Dependency_NoExampleSetup
#include "CodeDependencies.iss"

[Setup]
; ...

[Code]
function InitializeSetup: Boolean;
begin
  // add the dependencies you need
  Dependency_AddVC2013;
  // ...

  Result := True;
end;
```

## Details

You have two ways to distribute the dependency installers. By default, the dependency will be downloaded from the official website once it is defined as required in the _CodeDependencies.iss_ file. Another way is to pack the dependency into a single executable setup like so:

* Include the dependency setup file by defining the source:

    ```iss
    Source: "dxwebsetup.exe"; Flags: dontcopy noencryption
    ```

* Call _ExtractTemporaryFile()_ before the corresponding _Dependency_Add_ function

    ```iss
    ExtractTemporaryFile('dxwebsetup.exe');
    ```

The dependencies are installed based on the system architecture. If you want to install 32-bit dependencies on a 64-bit system you can force 32-bit mode like so:

```iss
Dependency_ForceX86 := True; // force 32-bit install of next dependencies
Dependency_AddVC2013;
Dependency_ForceX86 := False; // disable forced 32-bit install again
```

If you only deploy 32-bit binaries and dependencies you can also instead just not define [ArchitecturesInstallIn64BitMode](https://jrsoftware.org/ishelp/index.php?topic=setup_architecturesinstallin64bitmode) in [Setup].

## Dependencies

* .NET
    * .NET Framework 3.5 Service Pack 1
    * .NET Framework 4.0
    * .NET Framework 4.5.2
    * .NET Framework 4.6.2
    * .NET Framework 4.7.2
    * .NET Framework 4.8
    * .NET Core 3.1 (Runtime, ASP.NET, Desktop)
    * .NET 5.0 (Runtime, ASP.NET, Desktop)
    * .NET 6.0 (Runtime, ASP.NET, Desktop)
    * .NET 7.0 (Runtime, ASP.NET, Desktop)
* C++
    * Visual C++ 2005 Service Pack 1 Redistributable
    * Visual C++ 2008 Service Pack 1 Redistributable
    * Visual C++ 2010 Service Pack 1 Redistributable
    * Visual C++ 2012 Update 4 Redistributable
    * Visual C++ 2013 Update 5 Redistributable
    * Visual C++ 2015-2022 Redistributable
* SQL
    * SQL Server 2008 R2 Service Pack 2 Express
    * SQL Server 2012 Service Pack 4 Express
    * SQL Server 2014 Service Pack 3 Express
    * SQL Server 2016 Service Pack 2 Express
    * SQL Server 2017 Express
    * SQL Server 2019 Express
* DirectX End-User Runtime
* WebView2 runtime

## Credits

Thanks to the community for sharing many fixes and improvements. To contribute please [create a pull request](https://github.com/DomGries/InnoDependencyInstaller/pulls).

## License

[The Code Project Open License (CPOL) 1.02](https://github.com/DomGries/InnoDependencyInstaller/blob/master/LICENSE.md)
