unit HashedOptionPart;

interface

uses
  Classes, DCL_intf, SearchOption_Intf;

type
  THashedOptionPart = class(TAbsSearchOptionPart)
    protected
      FHashMap: IStrStrMap;
      procedure Init;
    public
      constructor Create; virtual;
      destructor Destroy;
      function GetValues(key: String): String; override;
      procedure SetValues(key, val: String); override;
      property Items[key: String]: String read GetValues write SetValues;
  end;

implementation

uses
  HashMap, System.SysUtils, QueryReader, StrUtils;

{ THashedOptionPart }

constructor THashedOptionPart.Create;
begin
  Init;
end;

destructor THashedOptionPart.Destroy;
begin
  FHashMap.Clear;
  FHashMap._Release;
  inherited;
end;

function THashedOptionPart.GetValues(key: String): String;
begin
  if key = 'use' then
    result := BoolToStr( FUse )
  else
    result := FHashMap.GetValue( key );
end;

procedure THashedOptionPart.Init;
begin
  FHashMap := TStrStrHashMap.Create;
  FUse := false;
end;

procedure THashedOptionPart.SetValues(key: String; val: String);
begin
  FHashMap.PutValue( key, val );

  if RightStr( key, 4 ) = '.use' then FUse := ( val = 'true' );

end;



end.
