You can put the renamed setup files of the dependencies in this folder so that they will be installed from the drive instead of being downloaded.

Alternatively you can include them inside the installer by adding a Source to the [Files] section and calling ExtractTemporaryFile in the [Code] section (see directxruntime.iss).

Either way have to rename them like below...

Supported dependency names:

dotnetfx11.exe
dotnetfx11sp1.exe
dotnetfx20[*].exe
dotnetfx35.exe
dotNetFx40_Client_setup.exe
dotNetFx40_Full_setup.exe
dotnetfx45.exe
dotnetfx46.exe
dotnetfx47.exe
dotnetfx48.exe
dotnet50[*].exe
dotnet50asp[*].exe
dotnet50desktop[*].exe
dxwebsetup.exe
msi45[*].msu
netcore31[*].exe
netcore31asp[*].exe
netcore31desktop[*].exe
sql2008express[*].exe
sqlcompact35sp2.msi
vcredist2005[*].exe
vcredist2008[*].exe
vcredist2010[*].exe
vcredist2012[*].exe
vcredist2013[*].exe
vcredist2015[*].exe
vcredist2017[*].exe
vcredist2019[*].exe


[*] = "_x64" for 64-bit OS or "" (empty) for 32-bit OS
