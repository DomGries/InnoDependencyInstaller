# Inno Setup Dependency Installer

![Download page](https://user-images.githubusercontent.com/341158/100111336-4727c100-2e6e-11eb-9d80-2c8696718c55.PNG)

**Inno Setup Dependency Installer** can download and install any dependency such as .NET, Visual C++ or SQL Server during your application's installation. In addition, it is easy to add your own dependencies as well.

## Installation and Usage

1. Download and install [Inno Setup 6.1+](https://www.jrsoftware.org/isinfo.php).
2. Download and extract [this repository](https://github.com/DomGries/InnoDependencyInstaller/archive/master.zip) or clone it.
3. Open the extracted _setup.iss_ file.
4. Comment out dependency defines to disable installing them and leave only dependencies that need to be installed:
    - `#define UseVC2013 <-- will be installed`
    - `//#define UseVC2013 <-- commented out and will not be installed`
5. Modify other sections like _[Setup] [Files] [Icons]_ as necessary.
6. Build setup using Inno Setup compiler.

## Details

![Ready to Install page](https://user-images.githubusercontent.com/341158/100111333-468f2a80-2e6e-11eb-91f5-7a35bba5f5a9.PNG)

You have two ways to distribute the dependency installers. By default, the dependency will be downloaded from the official website once it is defined as required in the _setup.iss_. Another way is to pack the dependency into a single _setup.exe_ file. To do so, you need:

* Include the dependency setup file by defining the source:

    `Source: "dxwebsetup.exe"; Flags: dontcopy noencryption`

* Call the _ExtractTemporaryFile()_ function before _AddDependency()_  

    `ExtractTemporaryFile('dxwebsetup.exe');`

The installation routine of the dependencies is automatic, and in quiet or semi quiet mode. Therefore no user interaction is needed.

## Dependencies

* .NET
    * .NET Framework 1.1
    * .NET Framework 1.1 Service Pack 1 (Patch)
    * .NET Framework 2.0 Service Pack 2
    * .NET Framework 3.5 Service Pack 1
    * .NET Framework 4.0 Client
    * .NET Framework 4.0 Full
    * .NET Framework 4.5.2
    * .NET Framework 4.6.2
    * .NET Framework 4.7.2
    * .NET Framework 4.8
    * .NET Core Runtime 3.1
    * ASP.NET Core Runtime 3.1
    * .NET Desktop Runtime 3.1
    * .NET Runtime 5.0
    * ASP.NET Core Runtime 5.0
    * .NET Desktop Runtime 5.0

* C++
    * Visual C++ 2005 Service Pack 1 Redistributable
    * Visual C++ 2008 Service Pack 1 Redistributable
    * Visual C++ 2010 Service Pack 1 Redistributable
    * Visual C++ 2012 Update 4 Redistributable
    * Visual C++ 2013 Update 5 Redistributable
    * Visual C++ 2015-2019 Redistributable

* SQL
    * SQL Server 2008 R2 Service Pack 2 Express
    * SQL Server 2012 Service Pack 4 Express
    * SQL Server 2014 Service Pack 3 Express
    * SQL Server 2016 Service Pack 2 Express
    * SQL Server 2017 Express
    * SQL Server 2019 Express

* DirectX End-User Runtime
* Windows Installer 4.5

## Credits

Thanks to the community for sharing many fixes and improvements. To contribute please create a pull request on this repository.

## License

[The Code Project Open License (CPOL) 1.02](https://github.com/DomGries/InnoDependencyInstaller/blob/master/LICENSE.md)
