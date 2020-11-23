[Code]
function stringtoversion(var Temp: String): Integer;
var
	Part: String;
	Pos1: Integer;
begin
	if Length(Temp) = 0 then begin
		Result := -1;
		Exit;
	end;

	Pos1 := Pos('.', Temp);
	if Pos1 = 0 then begin
		Result := StrToIntDef(Temp, 0);
		Temp := '';
	end else begin
		Part := Copy(Temp, 1, Pos1 - 1);
		Temp := Copy(Temp, Pos1 + 1, Length(Temp));
		Result := StrToIntDef(Part, 0);
	end;
end;

function compareinnerversion(var X, Y: String): Integer;
var
	Num1, Num2: Integer;
begin
	Num1 := stringtoversion(X);
	Num2 := stringtoversion(Y);
	if (Num1 = -1) and (Num2 = -1) then begin
		Result := 0;
		Exit;
	end;

	if Num1 < 0 then begin
		Num1 := 0;
	end;
	if Num2 < 0 then begin
		Num2 := 0;
	end;

	if Num1 < Num2 then begin
		Result := -1;
	end else if Num1 > Num2 then begin
		Result := 1;
	end else begin
		Result := compareinnerversion(X, Y);
	end;
end;

function compareversion(VersionA, VersionB: String): Integer;
var
	Temp1, Temp2: String;
begin
	Temp1 := VersionA;
	Temp2 := VersionB;
	Result := compareinnerversion(Temp1, Temp2);
end;
