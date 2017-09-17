unit FireBirdDBManager;

interface

uses
  Classes, iniFiles, DB, Variants, HashMap, DCL_intf, ADODB, StrUtils,
  SysUtils, DBManager, DBTables, QueryReader, Data.SqlExpr, uib, Uni,
  InterBaseUniProvider;

type
//-----------------------------------------------------------------+
// 클래스명:    TFireBirdDBManager
// 주요역할:    FireBird DB를 제어할 때 쓰임.
//-----------------------------------------------------------------+
  TFireBirdDBManager = Class(TAbsEmbededDB)
    private
      FConnect: TUniConnection;//TUIBDataBase;
      //FTransact: TUIBTransaction;
      FQuery: TUniQuery;//TUIBQuery;
      FProvider: TInterbaseUniProvider;
    protected
      procedure DoInsertColumnNames(dataset: TDataSet);
      procedure Init;
    public
      Constructor Create(); overload;
      constructor Create(username, password: String); overload;
      Destructor Destroy(); override;
      procedure SetTableNames(); override;
      procedure SetColumnNames(); override;
      function ExecuteQuery(query: String): TDataSet; override;
      function ExecuteNonQuery(query: String): Integer; override;
      function Backup(backupPath: String): Boolean; override;
      function Open(): Boolean; override;
      function IsOpen(): Boolean; override;
      procedure Close(); override;
      function GetDBList(isFilter: Boolean): TStringList; override;
      function GetDBFileExt: String; override;
      function GetDBMSName: String; override;
  end;

implementation

uses
  Winapi.Windows, SimpleDS, uibdataset, uiblib, FMX.Forms, FileManager;


{ TFireBirdDBManager }

//-----------------------------------------------------------------+
// 지정한 경로에 DB를 백업 한다.
//-----------------------------------------------------------------+
function TFireBirdDBManager.Backup(backupPath: String): Boolean;
begin
  result := DBFileCopy( DBFile, backupPath );
end;

//-----------------------------------------------------------------+
// 열려진 DB를 닫는다.
//-----------------------------------------------------------------+
procedure TFireBirdDBManager.Close;
begin
  inherited;
  FConnect.Connected := false;
  FQuery.Close;
end;

constructor TFireBirdDBManager.Create(username, password: String);
begin
  Init;
  FConnect.Username := username;
  FConnect.Password := password;
end;

//-----------------------------------------------------------------+
// 생성자. 내부 맴버를 생성하고 초기화 한다.
//-----------------------------------------------------------------+
constructor TFireBirdDBManager.Create;
begin
  Init;
end;

//-----------------------------------------------------------------+
// 소멸자. 현재 DB 관리자를 메모리에서 제거 한다.
//-----------------------------------------------------------------+
destructor TFireBirdDBManager.Destroy;
begin
  self.Close;
  FConnect.Free;
  FQuery.Close;
  FDataSource.Free;
  FProvider.Free;
  //FTransact.Free;
end;

procedure TFireBirdDBManager.DoInsertColumnNames(dataset: TDataSet);
var
  enumerator: TStringsEnumerator;
  fieldTable, fieldCol: TField;
  List_Columns: TStringList;
begin
  enumerator := FTableNames.GetEnumerator;

  while enumerator.MoveNext do
  begin
    List_Columns := TStringList.Create;

    while dataset.Eof = false do
    begin
      fieldTable := dataset.Fields.FieldByName( 'tname' );
      fieldCol   := dataset.Fields.FieldByName( 'cname' );

      if enumerator.Current = fieldTable.Value then
      begin
        List_Columns.Add( fieldCol.Value );
      end;
      dataset.Next;
    end;
    dataset.First;

    FColumnNames.PutValue( enumerator.Current , List_Columns);
  end;
  dataset.Free;
end;

//-----------------------------------------------------------------+
// Select문을 제외한 모든 쿼리문을 수행 한다.
// 리턴값이 -1일 경우는 오류가 난 것이다.
//-----------------------------------------------------------------+
function TFireBirdDBManager.ExecuteNonQuery(query: String): Integer;
begin
  try
    FQuery.SQL.Clear;
    FQuery.SQL.Add( query );
    FQuery.ExecSQL;
    result := 0;
  except
    on e: Exception
    do begin
      WriteErrorMessage( query + '::::' + e.Message );
      result := -1;
    end;
  end;

end;

//-----------------------------------------------------------------+
// Select문과 같이 검색 결과가 있는 쿼리문을 수행 한다.
//-----------------------------------------------------------------+
function TFireBirdDBManager.ExecuteQuery(query: String): TDataSet;
var
  objQuery: TUniQuery;//TUIBDataSet;
begin
  try
    objQuery := TUniQuery.Create( nil );//TUIBDataSet.Create( nil );
    objQuery.Connection := FConnect;
    //objQuery.Transaction := FTransact;
    //query := StringReplace( query, '|', '#124', [ rfReplaceAll ] );
    objQuery.SQL.Add( query );
    objQuery.Execute;

    result := objQuery
  except
    on e: Exception
    do begin
      WriteErrorMessage( query + '::::' + e.Message );
      result := nil;
    end;
  end;

end;

function TFireBirdDBManager.GetDBFileExt: String;
begin
  result := '.fdb';
end;

//-----------------------------------------------------------------+
// 현재 등록된 모든 Database의 이름들을 얻는다.
//-----------------------------------------------------------------+
function TFireBirdDBManager.GetDBList(isFilter: Boolean): TStringList;
var
  sQuery: String;
  sList: TStringList;
  field: TField;
  data: TDataSet;

  iEndOfList: Integer;
  recFiles: TSearchRec;
begin
  sList := TStringList.Create;

  iEndOfList := FindFirst( DEFAULT_EMBEDED_DBPATH + '*' + GetDBFileExt, faAnyFile, recFiles );

  while iEndOfList = 0 do
  begin
    sList.Add( recFiles.Name )
  end;

  result := sList;
end;

function TFireBirdDBManager.GetDBMSName: String;
begin
  result := 'firebird';
end;

//-----------------------------------------------------------------+
// DB가 열린 상태인지 확인 한다.
//-----------------------------------------------------------------+
procedure TFireBirdDBManager.Init;
begin
  FConnStr := DEFAULT_MSSQL_CONN_STR;
  FConnect := TUniConnection.Create( nil );//TUIBDatabase.Create( nil );
  //FTransact := TUIBTransaction.Create( nil );
  FDataSource := TUniDataSource.Create( nil );
  FQuery := TUniQuery.Create( nil );//TUIBQuery.Create( nil );
  FProvider := TInterBaseUniProvider.Create( nil );
  FConnect.ProviderName := 'InterBase';

  FConnect.Database := 'd:\theson.fdb';
  FConnect.SpecificOptions.Add( 'InterBase.ClientLibrary=' + GetCurrentDir + '\fbembed.dll' );
  FConnect.SpecificOptions.Add( 'InterBase.CodePage=UTF8' );
//  FConnect.SpecificOptions.Add( 'InterBase.Charset=WIN1251' );
//  FConnect.SpecificOptions.Add( 'InterBase.UseUnicode=WIN1251' );
  //FConnect.//DatabaseName := 'd:\theson.fdb';
  FConnect.UserName := 'INSIGHT';
  FConnect.PassWord := 'insight';
  //FConnect.CharacterSet := TCharacterSet.csWIN1251;

  //FTransact.DataBase := FConnect;
  FQuery.Connection := FConnect;
  //FQuery.Transaction := FTransact;
  FDataSource.DataSet := FQuery;

end;

function TFireBirdDBManager.IsOpen: Boolean;
begin
  result := FConnect.Connected;
end;

//-----------------------------------------------------------------+
// DB를 연다.
//-----------------------------------------------------------------+
function TFireBirdDBManager.Open: Boolean;
begin
  try
    if ( FConnect.Database <> DBFile ) or ( FConnect.Connected = false ) then
    begin
      FConnect.Connected := false;
      FConnect.Database := DBFile;
      FConnect.Connected := true;
    end;
    result := true;
  except
    on e: Exception
    do WriteErrorMessage( e.Message );
  end;
  result := false;
end;


//-----------------------------------------------------------------+
// DB내의 각 Table 이름별 열이름을 설정 한다.
//-----------------------------------------------------------------+
procedure TFireBirdDBManager.SetColumnNames;
var
  sQuery: String;
  enumerator: Classes.TStringsEnumerator;
  dataset: TDataSet;

begin
  inherited;
  if FTableNames = nil then self.SetTableNames;
  if FColumnNames <> nil then FColumnNames.Clear;

  FColumnNames := TStrHashMap.Create;
  sQuery := 'select f.rdb$relation_name as tname, f.rdb$field_name as cname ' +
            'from rdb$relation_fields f ' +
            'join rdb$relations r on f.rdb$relation_name = r.rdb$relation_name ' +
            'and r.rdb$view_blr is null ' +
            'and (r.rdb$system_flag is null or r.rdb$system_flag = 0) ' +
            'order by 1, f.rdb$field_position;';

  dataset := ExecuteQuery( sQuery );
  DoInsertColumnNames( dataset );
end;


//-----------------------------------------------------------------+
// DB내 모든 Table의 이름을 설정한다.
//-----------------------------------------------------------------+
procedure TFireBirdDBManager.SetTableNames;
var
  sQuery: String;
  sCompQuery: String;
  sTableName: String;
  field: TField;
  dataset: TDataSet;
begin
  inherited;
  if FTableNames <> Nil then FTableNames.Free;

  FTableNames := TStringList.Create;

  sQuery := 'select rdb$relation_name as name from rdb$relations where rdb$flags IS NOT NULL;';
  dataset := ExecuteQuery( sQuery );
  field := dataset.Fields.FieldByName( 'name' );
  while dataset.Eof = false do
  begin
    FTableNames.Add( field.Value );
    dataset.Next;
  end;

  dataset.Free;
end;
end.
