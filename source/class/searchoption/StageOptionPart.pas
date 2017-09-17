unit StageOptionPart;

interface

uses
  SearchOption_Intf, Classes, FMX.Controls, UIWappedPartUnit;


type

  TStageOptionPart = class(TAbsSearchOptionPart)
    private
      FTitle: String;
      FLogData_Start: ILogData;
      FLogData_End: ILogData;
    public
      function GetValues(key: String): String; override;
      procedure SetValues(key, val: String); override;

      property StageName: String read FTitle write FTitle;
      property StartLog: ILogData read FLogData_Start write FLogData_Start;
      property EndLog: ILogData read FLogData_End write FLogData_End;
  end;



implementation

uses
  SysUtils;



{ TStageOption }

function TStageOptionPart.GetValues(key: String): String;
begin
  if key = 'stage.use' then
  begin
    result := IsUseToString; exit;
  end
  else if IsUse = true then
  begin
         if key = 'stage.title'     then result := FTitle
    else if key = 'stage.start'     then result := FLogData_Start.GetDate
    else if key = 'stage.start_msg' then result := FLogData_End.GetMsg
    else if key = 'stage.end'       then result := FLogData_End.GetDate
    else if key = 'stage.end_msg'   then result := FLogData_End.GetMsg;
  end
  else result := '';
end;

procedure TStageOptionPart.SetValues(key, val: String);
begin
  if      key = 'stage.title' then FTitle := val;
end;



end.