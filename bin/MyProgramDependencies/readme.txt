You can put the dependencies in this folder. If they are here, they wont be downloaded. You have to rename them like below...

dependencies:

|   dotnetfx11.exe
|   dotnetfx11_[*2].exe
|   dotnetfx11sp1.exe
|   dotnetfx20[*1].exe
|   dotnetfx20[*1]_[*2].exe
|   dotnetfx20sp1[*1].exe
|   dotnetfx20sp1[*1]_[*2].exe
|   dotnetfx20sp2[*1].exe
|   dotnetfx20sp2[*1]_[*2].exe
|   dotnetfx35.exe
|   dotnetfx35_[*2].exe
|   dotnetfx35sp1.exe
|   dotnetfx35sp1_[*2].exe
|   dotNetFx40_Client_setup.exe
|   dotNetFx40_Full_setup.exe
|   dotnetfx45.exe
|   ie6.exe
|   jet4sp8.exe
|   kb835732.exe
|   mdac28.exe
|   msi20.exe
|   msi31.exe
|   msi45_[*4]
|   sql2005express[*1].exe
|   sql2008express[*1].exe
|   sqlcompact35sp2.msi
|   vcredist2010[*1].exe
|   vcredist2012[*1].exe
|   wic[*1]_[*3].exe


[*1] = "_x64" for 64-bit OS, "_ia64" for 64-bit Itanium OS or "" (empty) for 32-bit OS
[*2] = 2 letter language name ... e.g. "en", "de", "fr", "sp", ...
[*3] = 3 letter language name ... e.g. "enu", "deu", "fra", "esn", ...
[*4] = windows version of msi 4.5 ... either "60.msu", "52.exe" or "51.exe"