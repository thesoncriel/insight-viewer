unit StrOptComponent;

interface

uses
  FMX.Controls, Classes, FMX.ListBox;

const
  EXPANDER_CHILD_PANEL_HEIGHT = 35;
  EXPANDER_MARGIN = 5;
  EXPANDER_CHILD_LABEL_WIDTH = 100;
  EXPANDER_CHILD_ITEM_WIDTH = 120;
  EXPANDER_CHILD_LABEL_FONT_SIZE = 15;

type
  IStrOptionComponent = Interface
  ['{6B3873BC-CB3D-4E85-8C79-76D2DE847E62}']
    function GetValue: String;
    procedure SetValue(val: String);
  End;

  TStrOptComboBox = class(TComboBox, IStrOptionComponent)
    public
      constructor Create(owner: TComponent); override;
      function GetValue: String;
      procedure SetValue(val: String);
  end;

  TStrOptCheckButton = class(TButton, IStrOptionComponent)
    protected
      procedure CheckBox_OnCheckedChange(sender: TObject);
    public
      constructor Create(owner: TComponent); override;
      function GetValue: String;
      procedure SetValue(val: String);
  end;

implementation

uses
  FMX.Types, SysUtils;


{ TStrOptCheckButton }

constructor TStrOptCheckButton.Create(owner: TComponent);
begin
  inherited;
  self.Width := EXPANDER_CHILD_ITEM_WIDTH;
  self.Align := TAlignLayout.alLeft;
  self.StaysPressed := true;
  self.Parent := TFmxObject( owner );
  self.OnClick := CheckBox_OnCheckedChange;
end;

function TStrOptCheckButton.GetValue: String;
begin
  if IsPressed = true then
    result := 'true'
  else
    result := 'false';
end;

procedure TStrOptCheckButton.SetValue(val: String);
begin
  if LowerCase( val ) = 'true' then
    IsPressed := true
  else
    IsPressed := false;
end;

procedure TStrOptCheckButton.CheckBox_OnCheckedChange(sender: TObject);
var
  btn: TButton;
begin
  btn := TButton( sender );
  if btn.IsPressed = true then
    btn.Text := 'Check !'
  else
    btn.Text := '';
end;

{ TStrOptComboBox }

constructor TStrOptComboBox.Create(owner: TComponent);
begin
  inherited;
  self.Width := EXPANDER_CHILD_ITEM_WIDTH;
  self.Align := TAlignLayout.alLeft;
  self.Parent := TFmxObject( owner );
end;

function TStrOptComboBox.GetValue: String;
begin
  self.Selected.Text;
end;

procedure TStrOptComboBox.SetValue(val: String);
var
  index: Integer;
begin
  index := self.Items.IndexOf( val );
  self.ItemIndex := index;
end;

end.
