unit DatetimeOptionPart;

interface
uses
  Classes, SearchOption_Intf, FMX.ListBox, FMX.Controls, UIWappedPartUnit;

type
  TDatetimeOptionPart = class(TAbsUIWrappedPart)

    public
      function GetValues(key: String): String; override;
      procedure SetValues(key, val: String); override;
  end;
implementation

uses
  System.SysUtils;

{ TDatetimeOptionPart }

function TDatetimeOptionPart.GetValues(key: String): String;
begin
  if key = 'datetime.split' then result := IsUseToString;

end;

procedure TDatetimeOptionPart.SetValues(key, val: String);
begin
  if key = 'datetime.split' then SetUse( StrToBool( val ) );

end;

end.
