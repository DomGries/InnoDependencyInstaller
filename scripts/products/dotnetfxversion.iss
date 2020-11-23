[Code]
type
	NetFXType = (NetFx10, NetFx11, NetFx20, NetFx30, NetFx35, NetFx40Client, NetFx40Full, NetFx4x);

function dotnetfxinstalled(Version: NetFXType; LanguageId: Integer): Boolean;
var
	RegVersion: Cardinal;
	RegVersionString: String;
	LanguagePath: String;
begin
	if LanguageId <> 0 then begin
		LanguagePath := '\' + IntToStr(LanguageId);
	end else begin
		LanguagePath := '';
	end;

	case Version of
		NetFx10: begin
			Result := RegQueryStringValue(HKLM, 'Software\Microsoft\.NETFramework\Policy\v1.0\3705', 'Install', RegVersionString) and (RegVersionString <> '');
		end;
		NetFx11: begin
			Result := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v1.1.4322' + LanguagePath, 'Install', RegVersion) and (RegVersion <> 0);
		end;
		NetFx20: begin
			Result := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v2.0.50727' + LanguagePath, 'Install', RegVersion) and (RegVersion <> 0);
		end;
		NetFx30: begin
			Result := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup' + LanguagePath, 'InstallSuccess', RegVersion) and (RegVersion <> 0);
		end;
		NetFx35: begin
			Result := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v3.5' + LanguagePath, 'Install', RegVersion) and (RegVersion <> 0);
		end;
		NetFx40Client: begin
			Result := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v4\Client' + LanguagePath, 'Install', RegVersion) and (RegVersion <> 0);
		end;
		NetFx40Full: begin
			Result := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v4\Full' + LanguagePath, 'Install', RegVersion) and (RegVersion <> 0);
		end;
		NetFx4x: begin
			Result := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v4\Full' + LanguagePath, 'Release', RegVersion) and (RegVersion >= 378389); // 4.5.0+
		end;
	end;
end;

function dotnetfxspversion(Version: NetFXType; LanguageId: Integer): Integer;
var
	RegVersion: Cardinal;
	LanguagePath: String;
begin
	if LanguageId <> 0 then begin
		LanguagePath := '\' + IntToStr(LanguageId);
	end else begin
		LanguagePath := '';
	end;

	case Version of
		NetFx10: begin
			// not supported
			RegVersion := -1;
		end;
		NetFx11: begin
			if not RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v1.1.4322' + LanguagePath, 'SP', RegVersion) then begin
				RegVersion := -1;
			end;
		end;
		NetFx20: begin
			if not RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v2.0.50727' + LanguagePath, 'SP', RegVersion) then begin
				RegVersion := -1;
			end;
		end;
		NetFx30: begin
			if not RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v3.0' + LanguagePath, 'SP', RegVersion) then begin
				RegVersion := -1;
			end;
		end;
		NetFx35: begin
			if not RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v3.5' + LanguagePath, 'SP', RegVersion) then begin
				RegVersion := -1;
			end;
		end;
		NetFx40Client: begin
			if not RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v4\Client' + LanguagePath, 'Servicing', RegVersion) then begin
				RegVersion := -1;
			end;
		end;
		NetFx40Full: begin
			if not RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v4\Full' + LanguagePath, 'Servicing', RegVersion) then begin
				RegVersion := -1;
			end;
		end;
		NetFx4x: begin
			if RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v4\Full' + LanguagePath, 'Release', RegVersion) then begin
				if RegVersion >= 528040 then begin
					RegVersion := 80; // 4.8.0+ 
				end else if RegVersion >= 461808 then begin
					RegVersion := 72; // 4.7.2+
				end else if RegVersion >= 461308 then begin
					RegVersion := 71; // 4.7.1+
				end else if RegVersion >= 460798 then begin
					RegVersion := 70; // 4.7.0+
				end else if RegVersion >= 394802 then begin
					RegVersion := 62; // 4.6.2+
				end else if RegVersion >= 394254 then begin
					RegVersion := 61; // 4.6.1+
				end else if RegVersion >= 393295 then begin
					RegVersion := 60; // 4.6.0+
				end else if RegVersion >= 379893 then begin
					RegVersion := 52; // 4.5.2+
				end else if RegVersion >= 378675 then begin
					RegVersion := 51; // 4.5.1+
				end else if RegVersion >= 378389 then begin
					RegVersion := 50; // 4.5.0+
				end else begin
					RegVersion := -1;
				end;
			end;
		end;
	end;
	Result := RegVersion;
end;
