#include "isxdl\isxdl.iss"

[CustomMessages]
DependenciesDir=MyProgramDependencies

en.depdownload_title=Download dependencies
de.depdownload_title=Abhängigkeiten downloaden

en.depinstall_title=Install dependencies
de.depinstall_title=Abhängigkeiten installieren

en.depinstall_status=Installing %1...
de.depinstall_status=Installiere %1...

en.depdownload_msg=The following applications are required before setup can continue:%n%1%nDownload and install now?
de.depdownload_msg=Die folgenden Programme werden benötigt bevor das Setup fortfahren kann:%n%1%nJetzt downloaden und installieren?

en.depinstall_missing=%1 must be installed before setup can continue. Please install %1 and run Setup again.
de.depinstall_missing=%1 muss installiert werden bevor das Setup fortfahren kann. Bitte installieren Sie %1 und starten Sie das Setup erneut.

de.isxdl_langfile=german2.ini


[Files]
Source: "scripts\isxdl\german2.ini"; Flags: dontcopy

[Code]
var
	installMemo, downloadMemo, downloadMessage: string;

procedure AddProduct(PackageName, FileName, Title, Size, URL: string);
var
	path: string;
begin
	installMemo := installMemo + '%1' + Title + #13;
	
	path := ExpandConstant('{src}{\}') + CustomMessage('DependenciesDir') + '\' + FileName;
	if not FileExists(path) then begin
		path := ExpandConstant('{tmp}{\}') + FileName;
		
		isxdl_AddFile(URL, path);
		
		downloadMemo := downloadMemo + '%1' + Title + #13;
		downloadMessage := downloadMessage + Title + ' (' + Size + ')' + #13;
	end;
	
	SetIniString('install', PackageName, path, ExpandConstant('{tmp}{\}dep.ini'));
end;

function NextButtonClick(CurPage: Integer): Boolean;
begin
	Result := true;

	if CurPage = wpReady then begin

		if downloadMemo <> '' then begin
			// only change isxdl language if it is not english because isxdl default language is already english
			if ActiveLanguage() <> 'en' then begin
				ExtractTemporaryFile(CustomMessage('isxdl_langfile'));
				isxdl_SetOption('language', ExpandConstant('{tmp}{\}') + CustomMessage('isxdl_langfile'));
			end;
			//isxdl_SetOption('title', FmtMessage(SetupMessage(msgSetupWindowTitle), [CustomMessage('appname')]));
			
			if SuppressibleMsgBox(FmtMessage(CustomMessage('depdownload_msg'), [downloadMessage]), mbConfirmation, MB_YESNO, IDYES) = IDNO then
				Result := false
			else if isxdl_DownloadFiles(StrToInt(ExpandConstant('{wizardhwnd}'))) = 0 then
				Result := false;
		end;
	end;
end;

function InstallProducts: Boolean;
var
	ResultCode, i: Integer;
begin
	Result := true;
	
	//class: filepath, title, parameters
	for i := 0 to products.Count - 1 do begin
		//SuppressibleMsgBox(products[i], mbConfirmation, MB_YESNO, IDYES);
		if not Exec(products[i], '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then begin
			// handle success if necessary; ResultCode contains the exit code
			if not (ResultCode = 0) then begin
				Result := false;
			end;
		end else begin
			// handle failure if necessary; ResultCode contains the error code
			Result := false;
		end;
	end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
	if (CurStep = ssInstall) then begin
		if (not InstallProducts()) then
			Abort();
	end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
	s: string;
begin
	if downloadMemo <> '' then
		s := s + CustomMessage('depdownload_title') + ':' + NewLine + FmtMessage(downloadMemo, [Space]) + NewLine;
	if installMemo <> '' then
		s := s + CustomMessage('depinstall_title') + ':' + NewLine + FmtMessage(installMemo, [Space]) + NewLine;

	s := s + MemoDirInfo + NewLine + NewLine + MemoGroupInfo
	
	if MemoTasksInfo <> '' then
		s := s + NewLine + NewLine + MemoTasksInfo;

	Result := s
end;
