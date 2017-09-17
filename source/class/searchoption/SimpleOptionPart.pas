unit SimpleOptionPart;

interface

uses
  SearchOption_Intf;

type
  TSimpleOptionPart = class(TAbsSearchOptionPart)
    protected
      FKey: String;
      FValue: String;
    public
      function GetValues(key: String): String; override;
      procedure SetValues(key, val: String); override;
  end;

implementation

{ TSimpleOptionPart }

function TSimpleOptionPart.GetValues(key: String): String;
begin
  if key = 'use' then
  begin
    if IsUse = true then
      result := 'true'
    else
      result := 'false';
  end
  else if key = FKey then
  begin
    result := FValue;
  end;
end;

procedure TSimpleOptionPart.SetValues(key, val: String);
begin
  FKey := key;
  FValue := val;
end;

end.
