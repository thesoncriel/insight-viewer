unit SearchResult;

interface

uses
  Classes, SearchOption, DB, DBManager, DataFileSaver;

type
  TSearchResultSet = class(TInterfacedObject, IDataSetIterator)
    private
      FDataSetList: TList;
      FNames: TStringList;
      FIterPointer: Integer;
      FDBManager: TAbsDBManager;
    protected
      procedure Init;
    public
      constructor Create(dbm: TAbsDBManager); overload;
      constructor Create(searchOpt: TSearchOption; dbm: TAbsDBManager); overload;
      destructor Destroy; override;
      procedure Search(searchOpt: TSearchOption);
      function HasNext: Boolean;
      function CurData: TDataSet;
      procedure MoveFirst;
      function MoveNext: Boolean;
      function Count: Integer;
      function CurName: String;
      procedure Clear;
  end;

  TSearchResultEvent = procedure(Sender: TObject; schResult: IDataSetIterator) of object;

implementation

uses
  MsSqlDBManager, FireBirdDBManager, Winapi.Windows, System.SysUtils;

{ TSearchResultSet }

procedure TSearchResultSet.Clear;
begin
  FDataSetList.Clear;
  FNames.Clear;
  MoveFirst;
end;

function TSearchResultSet.Count: Integer;
begin
  result := FDataSetList.Count;
end;

constructor TSearchResultSet.Create(searchOpt: TSearchOption; dbm: TAbsDBManager);
begin
  Init;
  FDBManager := dbm;
  Search( searchOpt );
end;

constructor TSearchResultSet.Create(dbm: TAbsDBManager);
begin
  Init;
  FDBManager := dbm;
end;

function TSearchResultSet.CurData: TDataSet;
var
  dataSource: TDataSet;
  dataDest: TDataSet;
begin
  //dataDest := TDataSet.Create( nil );
  dataSource := TDataSet( FDataSetList.Items[ FIterPointer ] );
  //dataDest.CopyFields( dataSource );
  //CopyMemory( dataDest, dataSource, dataSource.InstanceSize );
  //result := dataDest;
  result := dataSource;
end;

function TSearchResultSet.CurName: String;
begin
  result := FNames[ FIterPointer ];
end;

destructor TSearchResultSet.Destroy;
begin
  FDataSetList.Free;
  FNames.Free;
  inherited;
end;

function TSearchResultSet.HasNext: Boolean;
begin
  result := ( FDataSetList.Count > FIterPointer );
end;

procedure TSearchResultSet.Init;
begin
  FDataSetList := TList.Create;
  FNames := TStringList.Create;
  MoveFirst;
end;

procedure TSearchResultSet.MoveFirst;
begin
  FIterPointer := -1;
end;

function TSearchResultSet.MoveNext: Boolean;
begin
  Inc( FIterPointer );
  result := HasNext;
end;


procedure TSearchResultSet.Search(searchOpt: TSearchOption);
var
  queryList: TStringList;
  i: Integer;
  dataset: TDataSet;
  sTmp: String;
begin
  queryList := searchOpt.GetQueryList( searchOpt.IsAutoDetected );

  FNames := searchOpt.GetStageNameList;

  for i := 0 to queryList.Count - 1 do
  begin
    //TextFileAppend( 'c:\sql_test\query_ivr.txt', queryList[ i ] );

// :(콜론)이 SQL 내에 포함 되면 에러 뜬다 ㅡㅡ;
    dataset := FDBManager.ExecuteQuery( queryList[ i ] );
    FDataSetList.Add( dataset );
  end;

  queryList.Free;
end;

end.
