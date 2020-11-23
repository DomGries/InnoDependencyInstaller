# Inno Setup Dependency Installer

![Ready to Install page](https://cloud.githubusercontent.com/assets/10548881/26322035/f8abb420-3f31-11e7-8be7-5a73aa29194b.jpg)
![Download page](https://cloud.githubusercontent.com/assets/10548881/26322034/f8aa3ec4-3f31-11e7-8092-868814ea3d2b.jpg)

**Inno Setup Dependency Installer** can download and install dependencies such as any .NET or Visual C++ Redistributable during the installation process of your application. In addition, it is easy to add your own dependencies as well.

## Installation and Usage

1. Download and install [Inno Setup 6.1+](https://www.jrsoftware.org/isinfo.php).
2. Download and extract [this repository](https://github.com/DomGries/InnoDependencyInstaller/archive/master.zip) or clone it.
3. Open the extracted _setup.iss_ file.
4. Comment out dependency defines to disable installing them and leave only dependencies that need to be installed:
    ```
    #define InstallVC2015 <-- will be installed
    ;#define InstallVC2015 <-- commented out and will not be installed
    ```
5. Modify other sections like _[Setup] [Files] [Icons]_ as necessary.
6. Build setup using Inno Setup compiler.

## Details

![Ready to Install prompt](https://cloud.githubusercontent.com/assets/10548881/26322032/f8a87e7c-3f31-11e7-960b-1c2942f5851e.jpg)

You have two ways to distribute the dependency installers. By default, the dependency will be downloaded from the official website once it is defined as required in the _setup.iss_. Another way is to pack the dependency into a single _setup.exe_ file. To do so, you need:

* Include the dependency setup file by defining the source:

    `Source: "src\dxwebsetup.exe"; Flags: dontcopy`

* Call the ExtractTemporaryFile() function before AddDependency()  

    `ExtractTemporaryFile('dxwebsetup.exe');`

The installation routine of the dependencies is automatic, and in quiet or semi quiet mode. Therefore no user interaction is needed.

## Dependencies

* .NET
    * .NET Framework 1.1
    * .NET Framework 1.1 Service Pack 1
    * .NET Framework 2.0 + Service Pack 2
    * .NET Framework 3.5 + Service Pack 1
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

* C++ Redistributable
    * Visual C++ 2005 Redistributable
    * Visual C++ 2008 Redistributable
    * Visual C++ 2010 Redistributable
    * Visual C++ 2012 Redistributable
    * Visual C++ 2013 Redistributable
    * Visual C++ 2015 Redistributable
    * Visual C++ 2017 Redistributable
    * Visual C++ 2015-2019 Redistributable

* SQL Server
    * SQL Server 2008 Express R2
    * SQL Server Compact 3.5 + Service Pack 2

* Windows Installer 4.5
* DirectX End-User Runtime

## Credits

I wanted to thank the community for sharing many fixes and improvements. To contribute please create a pull request on this repository.

## History

* October 2007
    * Initial version
* August 2008
    * Added .NET Framework language pack(s) to script
    * Added translation for download page
* January 2009
    * Added code for Windows 2000 Security Update KB835732, .NET Framework 1.1, 2.0 SP1, 3.5, 3.5 SP1 and their language packs
    * Improved source code modularity (each dependency now has one file)
* September 2009
    * Added executing dependency installation routine before the actual installation of the application
    * Added checking if all dependencies are installed successfully and if not, displays an error page
    * Added support for 32-bit (x86) and 64-bit (x64) OS including Itanium (ia64)
    * Added code for .NET Framework 2.0 SP2 and its language pack
    * Fixed Windows version check bug and language pack check bug
* September 2011
    * Added support for .NET Framework 4.0, Windows Installer 4.5, Visual C++ 2010 Redistributable, SQL 2008 Express and SQL 3.5 Compact Edition (community)
    * Added helper functions to determine the installed .NET Framework version which removed redundant code
    * Added version strings parser to fix wrong detection for version numbers above 9
    * Added delayed and forced mid-install restart support
    * Added usage of #define in setup.iss (community)
    * Added Unicode version of Inno Setup as default for better multi-language support
    * Fixed restart on 3010 result code from installers
    * Fixed missing check in Windows 2000 Security Update KB835732
    * Added support for offline files on x64 and IA64 OS
* June 2014
    * Added support for .NET Framework 4.5.2
    * Fixed installing WIC before .NET Framework 4.0 (community)
    * Fixed Visual C++ 2010 Redistributable install parameters (community)
    * Fixed KB835732 install parameters (community)
* January 2015
    * Added support for Visual C++ 2005, 2008, 2012, 2013 Redistributable
    * Improved Visual C++ Redistributable detection method (community)
    * Fixed installing dependencies with LCID parameter in certain cases (community)
* August 2015
    * Added support for Visual C++ 2015 Redistributable (community)
    * Added support for .NET Framework 4.6 (community)
    * Fixed download URL for Visual C++ 2012 32-Bit Redistributable (community)
    * Fixed comparing version numbers with different amount of numbers
* August 2017
    * Added support for Visual C++ 2017 Redistributable
    * Added support for .NET Framework 4.6.2 and 4.7
    * Added support for DirectX End-User Runtime
    * Added support to install 32-bit version of dependencies on 64-bit operating system
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
    * Removed download confirmation dialog
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
    * Removed old unsupported dependencies which targeted end-of-life Windows versions
* November 2020
    * Added native Inno Setup 6.1+ downloader instead of isxdl
    * Added .NET Core 3.1.10 version support
    * Improved security by using HTTPS download links
    * Improved using official language strings to remove custom languages
    * Improved code simplicity by merging it into a single file
    * Fixed triggering the UAC privilege elevation prompt when running an EXE dependency installer
    * Fixed ready page memo text in some cases
    * Fixed checking full sql server before sql express
    * Fixed exception on invalid string version comparison
    * Removed old unsupported dependencies
    * Removed support for Itanium due to reaching end of life
    * Removed installing dependencies from a local directory as they should be either statically included or downloaded

## License

[The Code Project Open License (CPOL) 1.02](https://github.com/stfx/innodependencyinstaller/blob/master/LICENSE.md)
