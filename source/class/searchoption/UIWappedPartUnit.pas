unit UIWappedPartUnit;

interface

uses
  SearchOption_Intf, FMX.Controls, System.Classes;

type
  TAbsUIWrappedPart = class(TAbsSearchOptionPart)
    protected
      FExpander: TExpander;
      procedure Init(owner: TExpander);
      function StrArrayToStrList(strArr: array of String): TStringList;
      function StringComp(str1, str2: String): Boolean;
    public
      constructor Create(expander: TExpander);
      function IsUse: Boolean; override;
      procedure SetUse(val: Boolean); override;

  end;
implementation

uses
  System.SysUtils, StrUtils;

{ TUIWrappedSearchOptionPart }

constructor TAbsUIWrappedPart.Create(expander: TExpander);
begin
  Init( expander );
end;

procedure TAbsUIWrappedPart.Init(owner: TExpander);
begin
  FExpander := owner;
end;

function TAbsUIWrappedPart.IsUse: Boolean;
begin
  result := ( FExpander.ShowCheck = false ) or
            ( ( FExpander.ShowCheck = true ) and ( FExpander.IsChecked = true ) );
end;

procedure TAbsUIWrappedPart.SetUse(val: Boolean);
begin
  if FExpander.ShowCheck = true then
  begin
    FExpander.IsChecked := val;
  end;
end;


function TAbsUIWrappedPart.StrArrayToStrList(
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

function TAbsUIWrappedPart.StringComp(str1, str2: String): Boolean;
var
  pWideChar1, pWideChar2: PWideChar;
begin
  pWideChar1 := @str1;
  pWideChar2 := @str2;

  result := StrComp( pWideChar1, pWideChar2 ) > 0;
end;

end.
