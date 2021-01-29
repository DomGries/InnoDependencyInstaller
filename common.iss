[Code]
// shared code for installing the dependencies
// types and variables
type
  TIDI_Dependency = record
    Filename: String;
    Parameters: String;
    Title: String;
    URL: String;
    Checksum: String;
    ForceSuccess: Boolean;
    InstallClean: Boolean;
    RebootAfter: Boolean;
  end;

  IDI_InstallResult = (InstallSuccessful, InstallRebootRequired, InstallError);

var
  IDI_MemoInstallInfo: String;
  IDI_Dependencies: array of TIDI_Dependency;
  IDI_DelayedReboot, IDI_ForceX86: Boolean;
  IDI_DownloadPage: TDownloadWizardPage;

procedure IDI_AddDependency(const Filename, Parameters, Title, URL, Checksum: String; const ForceSuccess, InstallClean, RebootAfter: Boolean);
var
  Dependency: TIDI_Dependency;
  I: Integer;
begin
  IDI_MemoInstallInfo := IDI_MemoInstallInfo + #13#10 + '%1' + Title;

  Dependency.Filename := Filename;
  Dependency.Parameters := Parameters;
  Dependency.Title := Title;

  if FileExists(ExpandConstant('{tmp}{\}') + Filename) then begin
    Dependency.URL := '';
  end else begin
    Dependency.URL := URL;
  end;

  Dependency.Checksum := Checksum;
  Dependency.ForceSuccess := ForceSuccess;
  Dependency.InstallClean := InstallClean;
  Dependency.RebootAfter := RebootAfter;

  I := GetArrayLength(IDI_Dependencies);
  SetArrayLength(IDI_Dependencies, I + 1);
  IDI_Dependencies[I] := Dependency;
end;

function IDI_IsPendingReboot: Boolean;
var
  Value: String;
begin
  Result := RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'PendingFileRenameOperations', Value) or
    (RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'SetupExecute', Value) and (Value <> ''));
end;

function IDI_InstallProducts: IDI_InstallResult;
var
  ResultCode, I, ProductCount: Integer;
begin
  Result := InstallSuccessful;
  ProductCount := GetArrayLength(IDI_Dependencies);
  IDI_MemoInstallInfo := SetupMessage(msgReadyMemoTasks);

  if ProductCount > 0 then begin
    IDI_DownloadPage.Show;

    for I := 0 to ProductCount - 1 do begin
      if IDI_Dependencies[I].InstallClean and (IDI_DelayedReboot or IDI_IsPendingReboot) then begin
        Result := InstallRebootRequired;
        break;
      end;

      IDI_DownloadPage.SetText(IDI_Dependencies[I].Title, '');
      IDI_DownloadPage.SetProgress(I + 1, ProductCount);

      while True do begin
        ResultCode := 0;
        if ShellExec('', ExpandConstant('{tmp}{\}') + IDI_Dependencies[I].Filename, IDI_Dependencies[I].Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then begin
          if IDI_Dependencies[I].RebootAfter then begin
            // delay reboot after install if we installed the last dependency anyways
            if I = ProductCount - 1 then begin
              IDI_DelayedReboot := True;
            end else begin
              Result := InstallRebootRequired;
              IDI_MemoInstallInfo := IDI_Dependencies[I].Title;
            end;
            break;
          end else if (ResultCode = 0) or IDI_Dependencies[I].ForceSuccess then begin
            break;
          end else if ResultCode = 3010 then begin
            // Windows Installer ResultCode 3010: ERROR_SUCCESS_REBOOT_REQUIRED
            IDI_DelayedReboot := True;
            break;
          end;
        end;

        case SuppressibleMsgBox(FmtMessage(SetupMessage(msgErrorFunctionFailed), [IDI_Dependencies[I].Title, IntToStr(ResultCode)]), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
          IDABORT: begin
            Result := InstallError;
            IDI_MemoInstallInfo := IDI_MemoInstallInfo + #13#10 + '      ' + IDI_Dependencies[I].Title;
            break;
          end;
          IDIGNORE: begin
            IDI_MemoInstallInfo := IDI_MemoInstallInfo + #13#10 + '      ' + IDI_Dependencies[I].Title;
            break;
          end;
        end;
      end;

      if Result <> InstallSuccessful then begin
        break;
      end;
    end;

    IDI_DownloadPage.Hide;
  end;
end;

// Inno Setup event functions
procedure IDI_InitializeWizard;
begin
  IDI_DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

function IDI_PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  IDI_DelayedReboot := False;

  case IDI_InstallProducts of
    InstallError: begin
      Result := IDI_MemoInstallInfo;
    end;
    InstallRebootRequired: begin
      Result := IDI_MemoInstallInfo;
      NeedsRestart := True;

      // write into the registry that the installer needs to be executed again after restart
      // TODO: use unique key here
      RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', 'InstallBootstrap', ExpandConstant('{srcexe}'));
    end;
  end;
end;

function IDI_NeedRestart: Boolean;
begin
  Result := IDI_DelayedReboot;
end;

function IDI_UpdateReadyMemo(const Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := '';
  if MemoUserInfoInfo <> '' then begin
    Result := Result + MemoUserInfoInfo + Newline + NewLine;
  end;
  if MemoDirInfo <> '' then begin
    Result := Result + MemoDirInfo + Newline + NewLine;
  end;
  if MemoTypeInfo <> '' then begin
    Result := Result + MemoTypeInfo + Newline + NewLine;
  end;
  if MemoComponentsInfo <> '' then begin
    Result := Result + MemoComponentsInfo + Newline + NewLine;
  end;
  if MemoGroupInfo <> '' then begin
    Result := Result + MemoGroupInfo + Newline + NewLine;
  end;
  if MemoTasksInfo <> '' then begin
    Result := Result + MemoTasksInfo;
  end;

  if IDI_MemoInstallInfo <> '' then begin
    if MemoTasksInfo = '' then begin
      Result := Result + SetupMessage(msgReadyMemoTasks);
    end;
    Result := Result + FmtMessage(IDI_MemoInstallInfo, [Space]);
  end;
end;

function IDI_NextButtonClick(const CurPageID: Integer): Boolean;
var
  I, ProductCount: Integer;
  Retry: Boolean;
begin
  Result := True;

  if (CurPageID = wpReady) and (IDI_MemoInstallInfo <> '') then begin
    IDI_DownloadPage.Show;

    ProductCount := GetArrayLength(IDI_Dependencies);
    for I := 0 to ProductCount - 1 do begin
      if IDI_Dependencies[I].URL <> '' then begin
        IDI_DownloadPage.Clear;
        IDI_DownloadPage.Add(IDI_Dependencies[I].URL, IDI_Dependencies[I].Filename, IDI_Dependencies[I].Checksum);

        Retry := True;
        while Retry do begin
          Retry := False;

          try
            IDI_DownloadPage.Download;
          except
            if GetExceptionMessage = SetupMessage(msgErrorDownloadAborted) then begin
              Result := False;
              I := ProductCount;
            end else begin
              case SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbError, MB_ABORTRETRYIGNORE, IDIGNORE) of
                IDABORT: begin
                  Result := False;
                  I := ProductCount;
                end;
                IDRETRY: begin
                  Retry := True;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    IDI_DownloadPage.Hide;
  end;
end;

// architecture helper functions
function IDI_IsX64: Boolean;
begin
  Result := not IDI_ForceX86 and Is64BitInstallMode;
end;

function IDI_GetString(const x86, x64: String): String;
begin
  if IDI_IsX64 then begin
    Result := x64;
  end else begin
    Result := x86;
  end;
end;

function IDI_GetArchitectureSuffix: String;
begin
  Result := IDI_GetString('', '_x64');
end;

function IDI_GetArchitectureTitle: String;
begin
  Result := IDI_GetString(' (x86)', ' (x64)');
end;

function IDI_CompareVersion(const Version1, Version2: String): Integer;
var
  Position, Number1, Number2: Integer;
begin
  Result := 0;
  while (Version1 <> '') or (Version2 <> '') do begin
    Position := Pos('.', Version1);
    if Position > 0 then begin
      Number1 := StrToIntDef(Copy(Version1, 1, Position - 1), 0);
      Delete(Version1, 1, Position);
    end else if Version1 <> '' then begin
      Number1 := StrToIntDef(Version1, 0);
      Version1 := '';
    end else begin
      Number1 := 0;
    end;

    Position := Pos('.', Version2);
    if Position > 0 then begin
      Number2 := StrToIntDef(Copy(Version2, 1, Position - 1), 0);
      Delete(Version2, 1, Position);
    end else if Version2 <> '' then begin
      Number2 := StrToIntDef(Version2, 0);
      Version2 := '';
    end else begin
      Number2 := 0;
    end;

    if Number1 < Number2 then begin
      Result := -1;
      break;
    end else if Number1 > Number2 then begin
      Result := 1;
      break;
    end;
  end;
end;

// source code: https://github.com/dotnet/deployment-tools/tree/master/src/clickonce/native/projects/NetCoreCheck
function IDI_IsNetCoreInstalled(const Version: String): Boolean;
var
  ResultCode: Integer;
begin
  if not FileExists(ExpandConstant('{tmp}{\}') + 'netcorecheck' + IDI_GetArchitectureSuffix + '.exe') then begin
    ExtractTemporaryFile('netcorecheck' + IDI_GetArchitectureSuffix + '.exe');
  end;
  Result := ShellExec('', ExpandConstant('{tmp}{\}') + 'netcorecheck' + IDI_GetArchitectureSuffix + '.exe', Version, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

function IDI_MsiEnumRelatedProducts(UpgradeCode: String; Reserved, Index: DWORD; ProductCode: String): Integer;
external 'MsiEnumRelatedProductsW@msi.dll stdcall';

function IDI_MsiGetProductInfo(ProductCode, PropertyName, Value: String; var ValueSize: DWORD): Integer;
external 'MsiGetProductInfoW@msi.dll stdcall';

function IDI_IsMsiProductInstalled(const UpgradeCode, MinVersion: String): Boolean;
var
  ProductCode, Version: String;
  ValueSize: DWORD;
begin
  SetLength(ProductCode, 39);
  Result := False;

  if IDI_MsiEnumRelatedProducts(UpgradeCode, 0, 0, ProductCode) = 0 then begin
    SetLength(Version, 39);
    ValueSize := Length(Version);

    if IDI_MsiGetProductInfo(ProductCode, 'VersionString', Version, ValueSize) = 0 then begin
      Result := IDI_CompareVersion(Version, MinVersion) >= 0;
    end;
  end;
end;
