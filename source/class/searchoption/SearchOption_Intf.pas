unit SearchOption_Intf;

interface

const
  GUID_ISearchOptionPart: TGUID = '{C2436293-51A4-4D4B-8104-E0C6B77AC78B}';

type


  ISearchOptionPart = interface
  ['{C2436293-51A4-4D4B-8104-E0C6B77AC78B}'] // Ctrl + Shift + G
    function GetValues(key: String): String;
    procedure SetValues(key, val: String);
    function InsertPartToQuery(tagQuery, key: String; currIndex: Integer): String;
    function IsUse: Boolean;
  end;

  ILogData = interface
  ['{FF5EFD1C-F749-4593-80D8-3CE08101BEA8}']
    function GetDate: String;
    function GetMsg: String;
  end;

  TLogDataEvent = procedure(Sender: TObject; logData: ILogData) of object;

  TAbsSearchOptionPart = class(TInterfacedObject, ISearchOptionPart)
    protected
      FUse: Boolean;
      function InsertPartToQueryByBoolean(tagQuery: String; val: Boolean; currIndex: Integer): String;
      function IsUseToString: String;
    public
      constructor Create; virtual;
      function GetValues(key: String): String; virtual; abstract;
      procedure SetValues(key, val: String); virtual; abstract;

      function InsertPartToQuery(tagQuery, key: String; currIndex: Integer): String; virtual;
      function IsUse: Boolean; virtual;
      procedure SetUse(val: Boolean); virtual;
  end;

  TJournalData = class(TInterfacedObject, ILogData)
    private
      FDate: String;
      FMsg: String;
    protected
      procedure Init(date, msg: String);
    public
      constructor Create(date, msg: String); overload;
      constructor Create(datemsg: String); overload;
      function GetDate: String;
      function GetMsg: String;
  end;



implementation

uses
  SysUtils, System.Classes;

{ TAbsSearchOptionPart }

constructor TAbsSearchOptionPart.Create;
begin
  FUse := false;
end;

function TAbsSearchOptionPart.InsertPartToQuery(tagQuery, key: String;
  currIndex: Integer): String;
var
  sTemp: String;
  sVal: String;
begin
  sVal := GetValues( key );

  if (sVal = 'true') or (sVal = 'false') then
    sTemp := InsertPartToQueryByBoolean( tagQuery, StrToBool( sVal), currIndex )
  else
    sTemp := StringReplace( tagQuery, '{' + IntToStr( currIndex ) + '}', sVal, [ rfReplaceAll, rfIgnoreCase ] );

  result := sTemp;
end;

function TAbsSearchOptionPart.IsUse: Boolean;
begin
  result := FUse;
end;

function TAbsSearchOptionPart.IsUseToString: String;
begin
  if IsUse = true then
    result := 'true'
  else
    result := 'false';
end;

function TAbsSearchOptionPart.InsertPartToQueryByBoolean(tagQuery: String; val: Boolean;
  currIndex: Integer): String;
var
  sRightBracket1: String;
  sRightBracket2: String;
  sTemp: String;
begin
  if val = true then
  begin
    sRightBracket1 := 't}';
    sRightBracket2 := 'f}';
  end
  else
  begin
    sRightBracket1 := 'f}';
    sRightBracket2 := 't}';
  end;

  sTemp := StringReplace( tagQuery, '{' + IntToStr( currIndex ) + sRightBracket1, '', [ rfReplaceAll, rfIgnoreCase ] );
  sTemp := StringReplace( sTemp, '{/' + IntToStr( currIndex ) + sRightBracket1, '', [ rfReplaceAll, rfIgnoreCase ] );
  sTemp := StringReplace( sTemp, '{' + IntToStr( currIndex ) + sRightBracket2, '/*', [ rfReplaceAll, rfIgnoreCase ] );
  sTemp := StringReplace( sTemp, '{/' + IntToStr( currIndex ) + sRightBracket2, '*/', [ rfReplaceAll, rfIgnoreCase ] );

  result := sTemp;
end;

procedure TAbsSearchOptionPart.SetUse(val: Boolean);
begin
  FUse := val;
end;

{ TJournalData }

constructor TJournalData.Create(date, msg: String);
begin
  Init( date, msg );
end;

constructor TJournalData.Create(datemsg: String);
var
  sList: TStringList;
begin
  sList := TStringList.Create;
  sList.Delimiter := '|';
  sList.StrictDelimiter := true;
  sList.DelimitedText := datemsg;

  Init( Trim( sList[ 0 ] ), Trim( sList[ 1 ] ) );
  sList.Free;
end;

function TJournalData.GetDate: String;
begin
  result := FDate;
end;

function TJournalData.GetMsg: String;
begin
  result := FMsg;
end;

procedure TJournalData.Init(date, msg: String);
begin
  FDate := date;
  FMsg := msg;
end;

end.
