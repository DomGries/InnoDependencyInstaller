# About

Inno Dependencies Installer is a collection of scripts to integrate into your [Inno Setup](http://www.jrsoftware.org/) install package scripts, to download additional installers like the .Net framework, instead of including them in your package, thus reducing your package's size.

More informations can be found here : http://www.codeproject.com/Articles/20868/NET-Framework-Installer-for-InnoSetup

# How to use from scratch

If you don't yet have a setup project/file:

* Open the `setup.iss` file with an editor: either your favorite text editor, or Inno Setup Compiler, Inno Script Studio...
* Comment unnecessary `#define use_xxx` lines.
* Modify the `#define MyAppSetupName` and `#define MyAppVersion` lines
* Modify the `[Setup]`, `[Files]`, `[Icons]` and other sections as needed.
* Leave the `#include` and `#ifdef` instructions below.

Then build the setup using Inno Setup Compiler (GUI or command line).

# How to use in an existing setup

Inside your Inno script, include the scripts from this library.

In order for the scripts to be run, you will either need to enable the Memo/Ready page in your setup, or modify the scripts to suit your needs.

    [Setup]
    DisableReadyPage=no
    DisableReadyMemo=no
    
    ; always include this
    #include "scripts\products.iss"
    
    ; these are not mandatory for all scripts but are nice to have
    #include "scripts\products\stringversion.iss"
    #include "scripts\products\winversion.iss"
    #include "scripts\products\fileversion.iss"
    
    ; include this if you need .Net
    #include "scripts\products\dotnetfxversion.iss"
    
    ; include the products you need
    ; for instance if you need .Net 4 Client and Visual C++ 2010 redist:
    #include "scripts\products\dotnetfx40client.iss"
    #include "scripts\products\vcredist2010.iss"
    
    [Code]
    function InitializeSetup(): boolean;
    begin
        // run the functions that check if there is a need to install the dependencies
        // for instance if you need .Net 4 and VC++2010:
        if (not netfxinstalled(NetFx40Client, '') and not netfxinstalled(NetFx40Full, '')) then
		    dotnetfx40client();
    
        vcredist2010();
    
        Result := true;
    end;

If you don't want or cannot enable the ready/memo page, see the "how it works" section below, so you can modify it to suit your needs.

# Include your language / translations

In your `[Languages]` section, include the wanted language(s), as you would normally.

Add an `ini` language file in `scripts\isxdl`.

Edit the `products.iss` file:

* Translate the `[CustomMessages]` sections for your language(s)
* Add a `xx.isxdl_langfile` property to include it.
* Edit the `[Files]` section to actually copy the language file:  
`Source: "scripts\isxdl\xxx.ini"; Flags: dontcopy`

Then, edit the components files you have included (for instance `products\dotnetfx40client.iss`), and check if there is content in the `[CustomMessages]` section. Edit the section to include the necessary informations. For instance, the .Net components scripts have a `LCID` property that change the installer's language.

If you have translated a whole new language, don't hesitate to make a pull request!

# How it works

* In the `setup.iss` file, the calls to the various components methods (ex: `dotnetfx40client()`) in the `InitializeSetup` function add products to a global array.
* The `UpdateReadyMemo` function (runs when displaying the `wpReady` page) displays the components that will be downloaded and installed from this global array.
* The `NextButtonClick` function then downloads the components (through the `isxdl` plugin) once the user clicks on the "next" button in the `wpReady` page.
* The `PrepareToInstall` function actually installs the components (through the `InstallProducts` function) and displays possible errors once finished.

# Tips and tricks

If your `wpReady` page is empty when the user already has all necessary packages, you can skip it with this piece of code (hat tip to [TLama](http://stackoverflow.com/a/24999629/6776)):

    [Code]
    function ShouldSkipPage(PageID: Integer): Boolean;
    begin
      Result := (PageID = wpReady) and (WizardForm.ReadyMemo.Text = '');
    end;