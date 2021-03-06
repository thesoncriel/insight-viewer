unit UIWrapper_StageUnit;

interface

uses
  SearchOption_Intf, FMX.Controls, UIWrapper_SchOptPartUnit,
  UIWrapper_StageEditorUnit, StageOptionPart, UIWrapper_LogSearchUnit;

type
  TUIWrapper_SchOpt_Stage = class(TUIWrapper_AbsSearchOptionPart)
    private
      FChkAutoDetect: TCheckBox;
      FStageEditor: TUIWrapper_StageEditor;
      FLogSearch: TUIWrapper_LogSearch;
    protected
      procedure ChkAutoDetectCheckedChange(Sender: TObject);
    public
      constructor Create(owner: TExpander; autoDetect: TCheckBox;
        stageEditor: TUIWrapper_StageEditor; logSearch: TUIWrapper_LogSearch);
      function GetSearchOptionPart: ISearchOptionPart; override;
      procedure SetAutoStageDetectionByDBMS(dbmsName: String);
      function GetStageOptionList: TStageOptionList;
  end;
implementation

{ TUIWrapper_SchOpt_Stage }

procedure TUIWrapper_SchOpt_Stage.ChkAutoDetectCheckedChange(Sender: TObject);
begin
  FStageEditor.SetEnabled( not FChkAutoDetect.IsChecked );
  FLogSearch.SetEnabled( not FChkAutoDetect.IsChecked );
end;

constructor TUIWrapper_SchOpt_Stage.Create(owner: TExpander; autoDetect: TCheckBox;
        stageEditor: TUIWrapper_StageEditor; logSearch: TUIWrapper_LogSearch);
begin
  Init( owner );
  FChkAutoDetect := autoDetect;
  FStageEditor := stageEditor;
  FLogSearch := logSearch;

  FChkAutoDetect.OnChange := ChkAutoDetectCheckedChange;
end;

function TUIWrapper_SchOpt_Stage.GetSearchOptionPart: ISearchOptionPart;
begin
  result := FStageEditor.GetStageOption( 0 );
end;

function TUIWrapper_SchOpt_Stage.GetStageOptionList: TStageOptionList;
begin
  result := FStageEditor.GetStageOptionList;
end;

procedure TUIWrapper_SchOpt_Stage.SetAutoStageDetectionByDBMS(dbmsName: String);
begin
  if dbmsName = 'firebird' then
  begin
    FChkAutoDetect.Enabled := true;
    FChkAutoDetect.IsChecked := true;
  end
  else
  begin
    FChkAutoDetect.Enabled := false;
    FChkAutoDetect.IsChecked := false;
  end;
end;

end.
