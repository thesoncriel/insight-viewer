unit StageOptionPartList;

interface

uses
  UIWappedPartUnit, System.Classes, FMX.Controls, UIWrapper_StageEditorUnit,
  StageOptionPart, SearchOption_Intf;

type
  TStageOptionList = class(TAbsUIWrappedPart)
    private
      FChkAutoDetect: TCheckBox;
      FStageEditor: TUIWrapper_StageEditor;
      //FAutoStgOpt: TAbsSearchOptionPart;
    protected
      procedure ChkAutoDetectCheckedChange(Sender: TObject);
    public
      constructor Create(owner: TExpander; autoDetect: TCheckBox;
        stageEditor: TUIWrapper_StageEditor);
      destructor Destroy;
      //procedure Add(stageOpt: TStageOption);
      //procedure Remove(stageOpt: TStageOption);
      function Count: Integer;
      function GetStageOption(index: Integer): TStageOptionPart;

      function GetValues(key: String): String; override;
      procedure SetValues(key, val: String); override;
  end;

implementation

uses
  HashedOptionPart, System.SysUtils;

{ TStageOptionList }

//procedure TStageOptionList.Add(stageOpt: TStageOption);
//begin
//  FList.Add( @stageOpt );
//end;

procedure TStageOptionList.ChkAutoDetectCheckedChange(Sender: TObject);
begin
  FStageEditor.SetEnabled( not FChkAutoDetect.IsChecked );
end;

function TStageOptionList.Count: Integer;
begin
  result := FStageEditor.Count;
end;

constructor TStageOptionList.Create(owner: TExpander; autoDetect: TCheckBox;
        stageEditor: TUIWrapper_StageEditor);
begin
  Init( owner );
  FChkAutoDetect := autoDetect;
  FStageEditor := stageEditor;

  FChkAutoDetect.OnChange := ChkAutoDetectCheckedChange;
  
end;

//procedure TStageOptionList.Remove(stageOpt: TStageOption);
//begin
//  FList.Remove( @stageOpt );
//end;

procedure TStageOptionList.SetValues(key, val: String);
var
  bSetVal: Boolean;
begin
  bSetVal := false;

  if key = 'autodetect' then
  begin
    bSetVal := val = 'firebird';
    FChkAutoDetect.IsChecked := bSetVal;
    FChkAutoDetect.Enabled := bSetVal;
  end;
end;

destructor TStageOptionList.Destroy;
begin
  //FAutoStgOpt.Free;
end;

function TStageOptionList.GetStageOption(index: Integer): TStageOptionPart;
begin
  result := FStageEditor.GetStageOption( index );
end;

function TStageOptionList.GetValues(key: String): String;
begin
  //result := FAutoStgOpt.GetValues( key );
end;

end.
