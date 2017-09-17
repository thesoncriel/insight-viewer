unit UIWrapper_RoundUnit;

interface

uses
  UIWrapper_SchOptPartUnit, FMX.ListBox, FMX.Controls, SearchOption_Intf;

const
  ITEM_LIST_ROUND_DECPLACE_MIN = 0;
  ITEM_LIST_ROUND_DECPLACE_MAX = 7;
  ITEM_LIST_ROUND_DECPLACE_DEF = ITEM_LIST_ROUND_DECPLACE_MAX;

type
  TUIWrapper_SchOpt_Round = class(TUIWrapper_AbsSearchOptionPart)
    private
      FCmbDecPlace: TComboBox;
    public
      constructor Create(owner: TExpander; cmbDecPlace: TComboBox);
      function GetSearchOptionPart: ISearchOptionPart; override;
  end;
implementation

uses
  SimpleOptionPart, SysUtils, Const_SearchOptionUnit;

{ TEvent_SchOpt_Round }

constructor TUIWrapper_SchOpt_Round.Create(owner: TExpander;
  cmbDecPlace: TComboBox);
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

function TUIWrapper_SchOpt_Round.GetSearchOptionPart: ISearchOptionPart;
var
  schOpt: TSimpleOptionPart;
begin
  schOpt := TSimpleOptionPart.Create;
  schOpt.SetUse( FExpander.IsChecked );
  schOpt.SetValues( SOP_ITEM_SEQ[ 9 ], FCmbDecPlace.Selected.Text );
end;

end.
