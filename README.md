# Inno Setup Dependency Installer

![Ready to Install page](https://cloud.githubusercontent.com/assets/10548881/26322035/f8abb420-3f31-11e7-8be7-5a73aa29194b.jpg)
![Download page](https://cloud.githubusercontent.com/assets/10548881/26322034/f8aa3ec4-3f31-11e7-8092-868814ea3d2b.jpg)

**Inno Setup Dependency Installer** is a set of Inno Setup scripts and a bunch of Pascal code that extends the functionality of [Inno Setup](http://www.jrsoftware.org/isinfo.php) installer to provide the possibility of dependencies installation (such as .NET Framework or Visual C++ Redistributable) during installing your product on end-user workstations.

It allows you to install various products during the installation process of your application. In addition, you may add your own product dependency scripts.

## Installation and Usage

1. Download and install [Inno Setup 6.1+](https://www.jrsoftware.org/isinfo.php).
2. Download and extract [this repository](https://github.com/DomGries/InnoDependencyInstaller/archive/master.zip) or clone it.
3. Open the extracted _setup.iss_ file.
4. Comment out product defines to disable installing them and leave only products that need to be installed:
    ```
    #define use_vc2015 <-- will be installed
    ;#define use_vc2015 <-- commented out and will not be installed
    ```
5. Modify other sections like _[Setup] [Files] [Icons]_ as necessary.
6. Build setup using Inno Setup compiler.

## Details

![Ready to Install prompt](https://cloud.githubusercontent.com/assets/10548881/26322032/f8a87e7c-3f31-11e7-960b-1c2942f5851e.jpg)

Most of the time, you need to tweak the _setup.iss_ file because of different Windows version checks and the inclusion of your required dependencies.

You have a few ways to distribute the dependency installers. By default, the dependency will be downloaded from the official website once it is defined as required in the _setup.iss_. Another way is to distribute the 3rd party installers with your own installer by putting them into _.\MyProgramDependencies_ folder. In addition, you may pack the dependency into a single _setup.exe_ file. To do so, you need:

* Include 3rd party installer by defining the source in your _setup.iss_ or in the appropriate _product.iss_ file:

    `Source: "src\dxwebsetup.exe"; Flags: dontcopy`

* Call the ExtractTemporaryFile() function before AddProduct()  

    `ExtractTemporaryFile('dxwebsetup.exe');`

The installation routine of the dependencies is automatic, and in quiet or semi quiet mode. Therefore no user interaction is needed.

## Project Structure

The source code is written modular and is structured as follows:

![Product structure](https://cloud.githubusercontent.com/assets/10548881/26322036/f8af63ea-3f31-11e7-9378-5184becc970e.jpg)

* _setup.iss_ file contains the basic setup where you include the modules (products) you need. They need to be included at the top like `#include "scripts\products\dotnetfx11.iss"` and then you only have to call their main function inside the _[Code]_ part like `dotnetfx11();`
* _bin_ folder contains the final output of the installer
* _src_ folder contains the application files of your program
* _scripts_ folder
    * _products.pas_ file contains the shared code for the product scripts
    * _products_ folder contains the scripts for products which are required by the application

## Supported Products List

* .NET
    * .NET Framework 1.1 (dotnetfx11.iss)
    * .NET Framework 1.1 Language Pack (dotnetfx11lp.iss)
    * .NET Framework 1.1 + Service Pack 1 (dotnetfx11sp1.iss)
    * .NET Framework 2.0 (dotnetfx20.iss)
    * .NET Framework 2.0 Language Pack (dotnetfx20lp.iss)
    * .NET Framework 2.0 + Service Pack 1 (dotnetfx20sp1.iss)
    * .NET Framework 2.0 Service Pack 1 Language Pack (dotnetfx20sp1lp.iss)
    * .NET Framework 2.0 + Service Pack 2 (dotnetfx20sp2.iss)
    * .NET Framework 2.0 Service Pack 2 Language Pack (dotnetfx20sp2lp.iss)
    * .NET Framework 3.5 (dotnetfx35.iss)
    * .NET Framework 3.5 Language Pack (dotnetfx35lp.iss)
    * .NET Framework 3.5 + Service Pack 1 (dotnetfx35sp1.iss)
    * .NET Framework 3.5 Service Pack 1 Language Pack (dotnetfx35sp1lp.iss)
    * .NET Framework 4.0 Client Profile (dotnetfx40client.iss)
    * .NET Framework 4.0 Full (dotnetfx40full.iss)
    * .NET Framework 4.5.2 (dotnetfx45.iss)
    * .NET Framework 4.6.2 (dotnetfx46.iss)
    * .NET Framework 4.7.2 (dotnetfx47.iss)
    * .NET Framework 4.8 (dotnetfx47.iss)
    * .NET Runtime 5.0 (dotnet50.iss)
    * .NET Core Runtime 3.1 (netcore31.iss)
    * ASP.NET Core Runtime 3.1 (netcore31asp.iss)
    * .NET Desktop Runtime 3.1 (netcore31desktop.iss)
    * ASP.NET Core Runtime 5.0 (dotnet50asp.iss)
    * .NET Desktop Runtime 5.0 (dotnet50desktop.iss)

* C++ Redistributable
    * Visual C++ 2005 Redistributable (vcredist2005.iss)
    * Visual C++ 2008 Redistributable (vcredist2008.iss)
    * Visual C++ 2010 Redistributable (vcredist2010.iss)
    * Visual C++ 2012 Redistributable (vcredist2012.iss)
    * Visual C++ 2013 Redistributable (vcredist2013.iss)
    * Visual C++ 2015 Redistributable (vcredist2015.iss)
    * Visual C++ 2017 Redistributable (vcredist2017.iss)
    * Visual C++ 2015-2019 Redistributable (vcredist2019.iss)

* SQL Server
    * SQL Server 2008 Express R2 (sql2008express.iss)
    * SQL Server Compact 3.5 + Service Pack 2 (sqlcompact35sp2.iss)

* Windows Installer 4.5 (msi45.iss)
* DirectX End-User Runtime (directxruntime.iss)
* Helper functions
    * winversion.iss - helper functions to determine the installed Windows version
    * fileversion.iss - helper functions to determine the version of a file
    * stringversion.iss - helper functions to correctly parse a version string
    * dotnetfxversion.iss - helper functions to determine the installed .NET Framework version including service packs
    * netcorecheck.iss - helper functions to determine the installed .NET Core version
    * msiproduct.iss - helper functions to check for installed msi products

## Known Issues

If dependencies are needed, the required free hard drive space shown before installation is incorrect.

## Credits

I wanted to thank the community for sharing many fixes and improvements. To contribute please create a pull request on this repository.

## History

* October 2007
    * Initial version
* August 2008
    * Now uses dotnetchk.exe to determine which version of .NET Framework and its language pack is installed
    * Added .NET Framework language pack(s) to script
    * Added translation for download page
    * Separated script code into multiple files to make it easier to update the script for different versions of the .NET Framework
* January 2009
    * Wrote source code modular (each dependency now has one file)
    * Added code for Windows 2000 Security Update KB835732, .NET Framework 1.1, 2.0 SP1, 3.5, 3.5 SP1 and their language packs
    * Remove usage of dotnetchk.exe again as it only worked for .NET Framework 2.0 and below
* September 2009
    * Code for dependencies installation routine was completely rewritten and is now executed before the actual installation of the application. Setup also checks if all dependencies are installed successfully and if not, displays an error page
    * Added support for 32-bit (x86) and 64-bit (x64) OS including Itanium (ia64)
    * Added code for .NET Framework 2.0 SP2 and its language pack
    * Fixed Windows version check bug and language pack check bug
* September 2011
    * Added support for .NET Framework 4.0, Windows Installer 4.5, Visual C++ 2010 Redistributable, SQL 2008 Express and SQL 3.5 Compact Edition (community)
    * Added helper functions to determine the installed .NET Framework version which removed redundant code
    * Added version strings parser to fix wrong detection for version numbers above 9
    * Added delayed and forced mid-install restart support
    * Added usage of #define in setup.iss (community)
    * Added Unicode version of Inno Setup as default for better multilanguage support
    * Fixed restart on 3010 result code from installers
    * Fixed missing check in Windows 2000 Security Update KB835732
    * Added support for offline files on x64 and IA64 OS
* June 2014
    * Added support for .NET Framework 4.5 - 4.5.2
    * Fixed installing WIC before .NET Framework 4.0 (community)
    * Fixed Visual C++ 2010 Redistributable install parameters (community)
    * Fixed KB835732 install parameters (community)
* January 2015
    * Added support for Visual C++ 2005, 2008, 2012, 2013 Redistributable
    * Improved Visual C++ Redistributable detection method (community)
    * Fixed installing products with LCID parameter in certain cases (community)
* August 2015
    * Added support for Visual C++ 2015 Redistributable (community)
    * Added support for .NET Framework 4.6 and Windows 10 with 4.5.x (community)
    * Fixed download URL for Visual C++ 2012 32-Bit Redistributable (community)
    * Fixed comparing version numbers with different amount of numbers
* August 2017
    * Added support for Visual C++ 2017 Redistributable
    * Added support for .NET Framework 4.6.2 and 4.7
    * Added support for DirectX End-User Runtime
    * Added support to install 32-bit version of products on 64-bit operating system
    * Added Russian, Italian, Dutch, Japanese and Korean localizations (community)
    * Improved detection of Visual C++ Redistributables
    * Improved formatting on ready to install page (community)
    * Improved and fixed some localizations (community)
    * Improved and normalized file sections
* October 2017
    * Added skippable error message if dependency failed to install to be able to continue on errors
    * Fixed detecting C++ Redistributable 2008 in rare cases
    * Fixed encoding of languages relying on Unicode
    * Fixed missing diacritics after last update
    * Fixed incorrectly installing non-supported .NET Framework language packs
    * Disabled download confirmation dialog
* August 2020
    * Added support for .NET 5 (Microsoft)
    * Added support for .NET Core 3.1 (Microsoft)
    * Added support for .NET Framework 4.7.2 and 4.8 (community)
    * Added support for Visual C++ 2019 Redistributable (community)
    * Added Chinese localization (community)
    * Improved code formatting, style, clarity and comments
    * Fixed excessive setup decompression time
    * Fixed duplicate .NET registry checks
    * Fixed Inno Setup 6+ warnings
    * Fixed Italian localization (community)
    * Removed old unsupported dependencies which targetted end-of-life Windows versions
* November 2020
    * Added native Inno Setup 6.1+ downloader instead of isxdl
    * Added .NET Core 3.1.10 version support
    * Added ability to not check dependencies directory
    * Improved security by using https download links
    * Improved using official language strings to remove custom languages
    * Improved setup code simplicity
    * Fixed triggering the UAC privilege elevation prompt when running an EXE dependency installer
    * Fixed ready page memo text in some cases
    * Removed pre Windows Vista dependencies

## License

[The Code Project Open License (CPOL) 1.02](https://github.com/stfx/innodependencyinstaller/blob/master/LICENSE.md)
