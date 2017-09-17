unit SearchOption;

interface

uses
  DCL_intf, HashMap, SysUtils, Classes,
  StageOptionPartList, DBManager, SearchOption_Intf;

type
  TTableOption = class(TAbsSearchOptionPart)
    private
      FTableName: String;
    public
      function GetValues(key: String): String; override;
      procedure SetValues(key, val: String); override;
  end;

  TSearchOption = class(TObject)
    private
      FOptHash: IStrIntfMap;
      //FSearchOptions: array of ISearchOptionPart;
      FSearchOptionPointer: Integer;
      FStageOptionList: TStageOptionList;
      FTableName: String;
      FDBManager: TAbsDBManager;
      FStageNames: TStringList;
    protected
      procedure Init; virtual;
      function GetOption(key: String): ISearchOptionPart;
      procedure SetTableName(tableName: String);
      procedure ClearStageNames;
    public
      constructor Create;
      destructor Destroy;
      procedure SetStageOptionList(stageOptions: TStageOptionList);
      procedure AddSearchOption(key: String; option: ISearchOptionPart);
      function GetStageName(stageNum: Integer): String;
      function GetStageNameList: TStringList;
      function Count: Integer;
      function GetQuery: string; overload; virtual;
      function GetQuery(stageNum: Integer): string; overload; virtual;
      function GetQueryListByManual: TStringList; virtual;
      function GetQueryListByAuto: TStringList; virtual;
      function GetQueryList(isAuto: Boolean): TStringList; virtual;

      property TableName: String read FTableName write SetTableName;
      property Options[key: String]: ISearchOptionPart read GetOption;
      function GetDBManager: TAbsDBManager; virtual;
      procedure SetDBManager(dbm: TAbsDBManager); virtual;
      function IsAutoDetected: Boolean;
  end;

implementation

uses
  QueryReader, Const_SearchOptionUnit, StageOptionPart;

{ TTableOption }

function TTableOption.GetValues(key: String): String;
begin
  if key = 'table.name' then result := FTableName;
end;

procedure TTableOption.SetValues(key, val: String);
begin
  if key = 'table.name' then FTableName := val;
end;

{ TSearchOption }

procedure TSearchOption.SetTableName(tableName: String);
var
  tableNameOpt: TAbsSearchOptionPart;
begin
  tableNameOpt := TTableOption.Create;
  tableNameOpt.SetValues( 'table.name', tableName );
  AddSearchOption( 'table', tableNameOpt );

  FTableName := tableName;
end;

procedure TSearchOption.AddSearchOption(key: String; option: ISearchOptionPart);
begin
  FOptHash.PutValue( key, option );
end;

procedure TSearchOption.ClearStageNames;
begin
  FreeAndNil( FStageNames );
  FStageNames := TStringList.Create;
end;

function TSearchOption.Count: Integer;
begin
  result := FOptHash.Size;
end;

constructor TSearchOption.Create;
begin
  Init;
end;

destructor TSearchOption.Destroy;
begin
  FOptHash.Clear;
end;

function TSearchOption.GetDBManager: TAbsDBManager;
begin
  result := FDBManager;
end;

function TSearchOption.GetOption(key: String): ISearchOptionPart;
begin
  result := FOptHash.GetValue( key ) as ISearchOptionPart;
end;

function TSearchOption.GetQuery(stageNum: Integer): string;
var
  stgOpt: TStageOptionPart;
begin

  if stageNum < 0 then
  begin
    stgOpt := TStageOptionPart.Create;
    ClearStageNames;
    FStageNames.Add( FTableName );

    if stageNum = -10 then
      stgOpt.SetUse( true )
    else
      stgOpt.SetUse( false );
  end
  else
  begin
    stgOpt := FStageOptionList.GetStageOption( stageNum );

    if stgOpt = nil then
    begin
      result := GetQuery( -1 ); exit;
    end;
  end;

  AddSearchOption( 'stage', stgOpt );
  GetOption( 'stage_auto' ).SetValues( 'stage_auto.stagenum', IntToStr( stageNum ) );
  result := GetQuery;
end;

function TSearchOption.GetQueryListByManual: TStringList;
var
  sList: TStringList;
  i: Integer;
begin
  sList := TStringList.Create;

  if FStageOptionList.IsUse = true then
  begin
    for i := 0 to FStageOptionList.Count - 1 do
    begin
      sList.Add( GetQuery( i ) );
    end;
  end
  else
  begin
    sList.Add( GetQuery( -1 ) );
  end;

  result := sList;
end;

function TSearchOption.GetQueryList(isAuto: Boolean): TStringList;
begin
  if isAuto = true then
  begin
    result := GetQueryListByAuto;
  end
  else
  begin
    result := GetQueryListByManual;
  end;
end;

function TSearchOption.GetQueryListByAuto: TStringList;
var
  i: Integer;
  stgOpt: TStageOptionPart;
  sList: TStringList;
begin
  ClearStageNames;

  for i := 0 to High( ITEM_LIST_AUTO_STAGE_SEQ )  do
  begin
    FStageNames.Add( STAGE_NAME_LIST[ ITEM_LIST_AUTO_STAGE_SEQ[ i ] ] );  //
  end;

  stgOpt := TStageOptionPart.Create;
  stgOpt.SetUse( false );
  AddSearchOption( 'stage', stgOpt );

  sList := TStringList.Create;

  for i := 0 to High( ITEM_LIST_AUTO_STAGE_SEQ ) do
  begin
    GetOption( 'stage_auto' ).SetValues( 'stage_auto.stagenum', IntToStr( ITEM_LIST_AUTO_STAGE_SEQ[ i ] ) );
    sList.Add( GetQuery );
  end;

  result := sList;
end;

function TSearchOption.GetStageName(stageNum: Integer): String;
begin
  result := FStageNames[ stageNum ];
end;

function TSearchOption.GetStageNameList: TStringList;
begin
  result := FStageNames;
end;

function TSearchOption.GetQuery: string;
var
  sTagQuery: String;
  queryReader: TQueryReader;
  i: Integer;
  sList: TStringList;
begin
  queryReader := TQueryReader.Create( FDBManager.GetDBMSName, 'insightviewer' );
  sTagQuery := queryReader.GetQuery( 'template.viewer' );
  sList := TStringList.Create;
  sList.Delimiter := '.';

  for i := 0 to High( SOP_ITEM_SEQ ) do
  begin
    sList.DelimitedText := SOP_ITEM_SEQ[ i ];
    sTagQuery := Options[ sList[ 0 ] ].InsertPartToQuery( sTagQuery, SOP_ITEM_SEQ[ i ], i );
  end;

  queryReader.Free;
  result := sTagQuery;
end;

procedure TSearchOption.Init;
begin
  FOptHash := TStrIntfHashMap.Create;
end;

function TSearchOption.IsAutoDetected: Boolean;
var
  schOpt: ISearchOptionPart;
begin
  schOpt := GetOption( 'stage_auto' );

  result := schOpt.IsUse;
end;

procedure TSearchOption.SetDBManager(dbm: TAbsDBManager);
begin
  FDBManager := dbm;
end;

procedure TSearchOption.SetStageOptionList(stageOptions: TStageOptionList);
var
  i: Integer;
begin
  FreeAndNil( FStageNames );

  FStageNames := TStringList.Create;
  FStageOptionList := stageOptions;

  for i := 0 to FStageOptionList.Count - 1 do
  begin
    FStageNames.Add( FStageOptionList.GetStageOption( i ).StageName );
  end;

end;



end.


