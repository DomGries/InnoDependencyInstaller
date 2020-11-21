[Code]
type
	NetFXType = (NetFx10, NetFx11, NetFx20, NetFx30, NetFx35, NetFx40Client, NetFx40Full, NetFx4x);

const
	netfx11plus_reg = 'Software\Microsoft\NET Framework Setup\NDP\';

function dotnetfxinstalled(version: NetFXType; languageId: Integer): Boolean;
var
	regVersion: Cardinal;
	regVersionString: String;
	lcid: String;
begin
	if languageId <> 0 then begin
		lcid := '\' + IntToStr(languageId);
	end else begin
		lcid := '';
	end;

	case version of
		NetFx10: begin
			Result := RegQueryStringValue(HKLM, 'Software\Microsoft\.NETFramework\Policy\v1.0\3705', 'Install', regVersionString) and (regVersionString <> '');
		end;
		NetFx11: begin
			Result := RegQueryDWordValue(HKLM, netfx11plus_reg + 'v1.1.4322' + lcid, 'Install', regVersion) and (regVersion <> 0);
		end;
		NetFx20: begin
			Result := RegQueryDWordValue(HKLM, netfx11plus_reg + 'v2.0.50727' + lcid, 'Install', regVersion) and (regVersion <> 0);
		end;
		NetFx30: begin
			Result := RegQueryDWordValue(HKLM, netfx11plus_reg + 'v3.0\Setup' + lcid, 'InstallSuccess', regVersion) and (regVersion <> 0);
		end;
		NetFx35: begin
			Result := RegQueryDWordValue(HKLM, netfx11plus_reg + 'v3.5' + lcid, 'Install', regVersion) and (regVersion <> 0);
		end;
		NetFx40Client: begin
			Result := RegQueryDWordValue(HKLM, netfx11plus_reg + 'v4\Client' + lcid, 'Install', regVersion) and (regVersion <> 0);
		end;
		NetFx40Full: begin
			Result := RegQueryDWordValue(HKLM, netfx11plus_reg + 'v4\Full' + lcid, 'Install', regVersion) and (regVersion <> 0);
		end;
		NetFx4x: begin
			Result := RegQueryDWordValue(HKLM, netfx11plus_reg + 'v4\Full' + lcid, 'Release', regVersion) and (regVersion >= 378389); // 4.5.0+
		end;
	end;
end;

function dotnetfxspversion(version: NetFXType; languageId: Integer): Integer;
var
	regVersion: Cardinal;
	lcid: String;
begin
	if languageId <> 0 then begin
		lcid := '\' + IntToStr(languageId);
	end else begin
		lcid := '';
	end;

	case version of
		NetFx10: begin
			// not supported
			regVersion := -1;
		end;
		NetFx11: begin
			if not RegQueryDWordValue(HKLM, netfx11plus_reg + 'v1.1.4322' + lcid, 'SP', regVersion) then begin
				regVersion := -1;
			end;
		end;
		NetFx20: begin
			if not RegQueryDWordValue(HKLM, netfx11plus_reg + 'v2.0.50727' + lcid, 'SP', regVersion) then begin
				regVersion := -1;
			end;
		end;
		NetFx30: begin
			if not RegQueryDWordValue(HKLM, netfx11plus_reg + 'v3.0' + lcid, 'SP', regVersion) then begin
				regVersion := -1;
			end;
		end;
		NetFx35: begin
			if not RegQueryDWordValue(HKLM, netfx11plus_reg + 'v3.5' + lcid, 'SP', regVersion) then begin
				regVersion := -1;
			end;
		end;
		NetFx40Client: begin
			if not RegQueryDWordValue(HKLM, netfx11plus_reg + 'v4\Client' + lcid, 'Servicing', regVersion) then begin
				regVersion := -1;
			end;
		end;
		NetFx40Full: begin
			if not RegQueryDWordValue(HKLM, netfx11plus_reg + 'v4\Full' + lcid, 'Servicing', regVersion) then begin
				regVersion := -1;
			end;
		end;
		NetFx4x: begin
			if RegQueryDWordValue(HKLM, netfx11plus_reg + 'v4\Full' + lcid, 'Release', regVersion) then begin
				if regVersion >= 528040 then begin
					regVersion := 80; // 4.8.0+ 
				end else if regVersion >= 461808 then begin
					regVersion := 72; // 4.7.2+
				end else if regVersion >= 461308 then begin
					regVersion := 71; // 4.7.1+
				end else if regVersion >= 460798 then begin
					regVersion := 70; // 4.7.0+
				end else if regVersion >= 394802 then begin
					regVersion := 62; // 4.6.2+
				end else if regVersion >= 394254 then begin
					regVersion := 61; // 4.6.1+
				end else if regVersion >= 393295 then begin
					regVersion := 60; // 4.6.0+
				end else if regVersion >= 379893 then begin
					regVersion := 52; // 4.5.2+
				end else if regVersion >= 378675 then begin
					regVersion := 51; // 4.5.1+
				end else if regVersion >= 378389 then begin
					regVersion := 50; // 4.5.0+
				end else begin
					regVersion := -1;
				end;
			end;
		end;
	end;
	Result := regVersion;
end;
