[Code]
type
	INSTALLSTATE = Longint;
const
	INSTALLSTATE_INVALIDARG = -2;	// An invalid parameter was passed to the function.
	INSTALLSTATE_UNKNOWN = -1;		// The product is neither advertised or installed.
	INSTALLSTATE_ADVERTISED = 1;	// The product is advertised but not installed.
	INSTALLSTATE_ABSENT = 2;		// The product is installed for a different user.
	INSTALLSTATE_DEFAULT = 5;		// The product is installed for the current user.

function MsiQueryProductState(Product: String): INSTALLSTATE;
external 'MsiQueryProductStateW@msi.dll stdcall';

function MsiEnumRelatedProducts(UpgradeCode: String; Reserved: DWORD; Index: DWORD; ProductCode: String): Integer;
external 'MsiEnumRelatedProductsW@msi.dll stdcall';

function MsiGetProductInfo(ProductCode: String; PropertyName: String; Value: String; var ValueSize: DWORD): Integer;
external 'MsiGetProductInfoW@msi.dll stdcall';

function msiproduct(ProductId: String): Boolean;
begin
	Result := MsiQueryProductState(ProductId) = INSTALLSTATE_DEFAULT;
end;

function msiproductupgrade(UpgradeCode: String; MinVersion: String): Boolean;
var
	ProductCode, Version: String;
	ValueSize: DWORD;
begin
	SetLength(ProductCode, 39);
	Result := False;

	if MsiEnumRelatedProducts(UpgradeCode, 0, 0, ProductCode) = 0 then begin
		SetLength(Version, 39);
		ValueSize := Length(Version);

		if MsiGetProductInfo(ProductCode, 'VersionString', Version, ValueSize) = 0 then begin
			Result := compareversion(Version, MinVersion) >= 0;
		end;
	end;
end;
