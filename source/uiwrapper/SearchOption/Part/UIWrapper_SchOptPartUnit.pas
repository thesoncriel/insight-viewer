unit UIWrapper_SchOptPartUnit;

interface

uses
  FMX.Controls, Classes, FMX.Types, iniFiles, SearchOption_Intf, DCL_intf,
  FMX.ListBox;

type
  TUIWrapper_AbsSearchOptionPart = class(TObject)
    protected
      FDataHash: IStrMap;
      FExpander: TExpander;
      function StrArrayToStrList(strArr: array of String): TStringList;
      procedure Init(expander: TExpander);
    public
      constructor Create(owner: TExpander); virtual;
      destructor Destroy; virtual;
      function IsUse: Boolean;
      function IsUseToString: String;

      function GetSearchOptionPart: ISearchOptionPart; virtual; abstract;
      procedure SetData(sList: TStringList); virtual;
  end;



implementation

uses
  HashMap, SysUtils, HashedOptionPart, ColumnListOptionPart;

{ TEvent_AbsSearchOptionPart }


constructor TUIWrapper_AbsSearchOptionPart.Create(owner: TExpander);
begin
  Init( owner );
end;

destructor TUIWrapper_AbsSearchOptionPart.Destroy;
begin
  FDataHash.Clear;
end;

procedure TUIWrapper_AbsSearchOptionPart.Init(expander: TExpander);
begin
  FExpander := expander;
  FDataHash := TStrHashMap.Create;
end;

function TUIWrapper_AbsSearchOptionPart.IsUse: Boolean;
begin
  result := ( FExpander.ShowCheck = false ) or
            ( ( FExpander.ShowCheck = true ) and ( FExpander.IsChecked = true ) );
end;


function TUIWrapper_AbsSearchOptionPart.IsUseToString: String;
begin
  if IsUse = true then
    result := 'true'
  else
    result := 'false';
end;

procedure TUIWrapper_AbsSearchOptionPart.SetData(sList: TStringList);
begin

end;

function TUIWrapper_AbsSearchOptionPart.StrArrayToStrList(
  strArr: array of String): TStringList;
var
  sList: TStringList;
  i: Integer;
begin
  sList := TStringList.Create;

  for i := 0 to High( strArr ) do
  begin
    sList.Add( strArr[ i ] );
  end;

  result := sList;
end;

end.
