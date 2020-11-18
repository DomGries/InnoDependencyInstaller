[Code]
type
	INSTALLSTATE = Longint;
const
	INSTALLSTATE_INVALIDARG = -2;	// An invalid parameter was passed to the function.
	INSTALLSTATE_UNKNOWN = -1;		// The product is neither advertised or installed.
	INSTALLSTATE_ADVERTISED = 1;	// The product is advertised but not installed.
	INSTALLSTATE_ABSENT = 2;		// The product is installed for a different user.
	INSTALLSTATE_DEFAULT = 5;		// The product is installed for the current user.

function MsiQueryProductState(szProduct: String): INSTALLSTATE;
external 'MsiQueryProductStateW@msi.dll stdcall';

function MsiEnumRelatedProducts(szUpgradeCode: String; nReserved: DWORD; nIndex: DWORD; szProductCode: String): Integer;
external 'MsiEnumRelatedProductsW@msi.dll stdcall';

function MsiGetProductInfo(szProductCode: String; szProperty: String; szValue: String; var nvalueSize: DWORD): Integer;
external 'MsiGetProductInfoW@msi.dll stdcall';

function msiproduct(productID: String): Boolean;
begin
	Result := MsiQueryProductState(productID) = INSTALLSTATE_DEFAULT;
end;

function msiproductupgrade(upgradeCode: String; minVersion: String): Boolean;
var
	productCode, version: String;
	valueSize: DWORD;
begin
	SetLength(productCode, 39);
	Result := False;

	if MsiEnumRelatedProducts(upgradeCode, 0, 0, productCode) = 0 then begin
		SetLength(version, 39);
		valueSize := Length(version);

		if MsiGetProductInfo(productCode, 'VersionString', version, valueSize) = 0 then begin
			Result := compareversion(version, minVersion) >= 0;
		end;
	end;
end;
