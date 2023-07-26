# Inno Setup Dependency Installer

![Inno Setup Dependency Installer](https://user-images.githubusercontent.com/341158/122873592-3e2e9d80-d332-11eb-8055-8a4c6064ac4e.gif)

**Inno Setup Dependency Installer** can download and install any dependency such as .NET, Visual C++ or SQL Server during your application's installation. In addition, it is easy to add your own dependencies as well.

## Installation and Usage

1. Download and install [Inno Setup 6.2+](https://www.jrsoftware.org/isinfo.php).
2. Download _CodeDependencies.iss_ and _dependencies_ folder in the folder of your iss script.
3. On top of your iss script add this snippet:
```iss
;#define UseDotNet35
;#define UseDotNet40
;#define UseDotNet45
;#define UseDotNet46
;#define UseDotNet47
;#define UseDotNet48
;#define UseNetCore31
;#define UseNetCore31Asp
;#define UseNetCore31Desktop
;#define UseDotNet50
;#define UseDotNet50Asp
;#define UseDotNet50Desktop
;#define UseDotNet60
;#define UseDotNet60Asp
;#define UseDotNet60Desktop
;#define UseDotNet70
;#define UseDotNet70Asp
;#define UseDotNet70Desktop

;#define UseVC2005
;#define UseVC2008
;#define UseVC2010
;#define UseVC2012
;#define UseVC2013
;#define UseVC2015To2022

;#define UseDirectX

;#define UseSql2008Express
;#define UseSql2012Express
;#define UseSql2014Express
;#define UseSql2016Express
;#define UseSql2017Express
;#define UseSql2019Express
;#define UseSql2022Express

;#define UseWebView2

;#define UseAccessDatabaseEngine2010
;#define UseAccessDatabaseEngine2016

#include "CodeDependencies.iss"
```
4. From that snippet remove the comment (the initial semicolon ";") to the dependencies you want to add (you can remove the unused defines if you desire)
5. Build setup using Inno Setup compiler. Done.

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

* Microsoft .NET
    * .NET Framework 3.5 Service Pack 1
    * .NET Framework 4.0
    * .NET Framework 4.5.2
    * .NET Framework 4.6.2
    * .NET Framework 4.7.2
    * .NET Framework 4.8
    * .NET Core 3.1 (Runtime, ASP.NET or Desktop)
    * .NET 5.0 (Runtime, ASP.NET or Desktop)
    * .NET 6.0 (Runtime, ASP.NET or Desktop)
    * .NET 7.0 (Runtime, ASP.NET or Desktop)
* Visual C++
    * Visual C++ 2005 Service Pack 1 Redistributable
    * Visual C++ 2008 Service Pack 1 Redistributable
    * Visual C++ 2010 Service Pack 1 Redistributable
    * Visual C++ 2012 Update 4 Redistributable
    * Visual C++ 2013 Update 5 Redistributable
    * Visual C++ 2015-2022 Redistributable
* Microsoft SQL Server
    * SQL Server 2008 R2 Service Pack 2 Express
    * SQL Server 2012 Service Pack 4 Express
    * SQL Server 2014 Service Pack 3 Express
    * SQL Server 2016 Service Pack 2 Express
    * SQL Server 2017 Express
    * SQL Server 2019 Express
    * SQL Server 2022 Express
* DirectX End-User Runtime
* WebView2 runtime
* Microsoft Access Database Engine
    * Access Database Engine 2010
    * Access Database Engine 2016

## Credits

Thanks to the community for sharing many fixes and improvements. To contribute please [create a pull request](https://github.com/DomGries/InnoDependencyInstaller/pulls).

## License

[The Code Project Open License (CPOL) 1.02](https://github.com/DomGries/InnoDependencyInstaller/blob/master/LICENSE.md)
