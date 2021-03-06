unit RoundOptionPart;

interface
uses
  Classes, SearchOption_Intf, FMX.ListBox, FMX.Controls, UIWappedPartUnit;

type
  TRoundOptionPart = class(TAbsUIWrappedPart)
    private
      FCmbDecPlace: TComboBox;
    public
      constructor Create(owner: TExpander; cmbDecPlace: TComboBox);
      function GetValues(key: String): String; override;
      procedure SetValues(key, val: String); override;
  end;
implementation

uses
  Const_SearchOptionUnit, SysUtils;

{ TRoundOptionPart }

constructor TRoundOptionPart.Create(owner: TExpander; cmbDecPlace: TComboBox);
var
  i: Integer;
begin
  Init( owner );
  FCmbDecPlace := cmbDecPlace;

  for i := ITEM_LIST_ROUND_DECPLACE_MIN to ITEM_LIST_ROUND_DECPLACE_MAX do
  begin
    FCmbDecPlace.Items.Add( IntToStr( i ) );
  end;

  FCmbDecPlace.ItemIndex := ITEM_LIST_ROUND_DECPLACE_DEF;
end;

function TRoundOptionPart.GetValues(key: String): String;
begin
  if      key = 'round.use'       then result := IsUseToString
  else if key = 'round.decplace'  then result := FCmbDecPlace.Selected.Text;

end;

procedure TRoundOptionPart.SetValues(key, val: String);
begin
  if      key = 'round.use'       then SetUse( StrToBool( val ) )
  else if key = 'round.decplace'  then FCmbDecPlace.ItemIndex := FCmbDecPlace.Items.IndexOf( val );
end;

end.
