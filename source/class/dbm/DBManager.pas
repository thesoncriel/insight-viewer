//-----------------------------------------------------------------+
// 파일명칭:    DBManager
// 프로젝트:    InsightViewer
// 처리개요:    MS-SQL Server 및 Fire Bird 의 DB Data 처리
// 개발언어:    Delphi XE2 with Fire Monkey
// 작성수정:    아즈텍 장비개발팀 S/W 손준현s
// 개발버전:    Ver 1.1 (2011.10.10)
//-----------------------------------------------------------------+

unit DBManager;

interface

uses
  Classes, iniFiles, DB, Variants, HashMap, DCL_intf, ADODB, StrUtils,
  DBTables, Windows;

//-----------------------------------------------------------------+
//DB 관리에 쓰이는 상수 정의
//-----------------------------------------------------------------+
const
  DEFAULT_DB_NAME = 'INSIGHTDB_';
  DEFAULT_DB_PATH = 'DB';
  DEFAULT_DB_LIST_FILTER = 'INSIGHT%';
  DEFAULT_ERR_FILE_NAME = '..\log\sqlerror.txt';
  DEFAULT_MSSQL_CONN_STR = 'Server=localhost\SQLEXPRESS;Integrated security=SSPI;database=master';
  DEFAULT_EXCEL_CONN_STR = 'Provider=Microsoft.Jet.OLEDB.4.0; Data Source="{0}"; Mode=ReadWrite|Share Deny None; Extended Properties=''Excel 8.0; HDR=YES; IMEX=1''; Persist Security Info=False';
  DEFAULT_EXCEL2007_CONN_STR = 'Provider=Microsoft.ACE.OLEDB.12.0; Data Source="{0}"; Mode=ReadWrite|Share Deny None; Extended Properties=''Excel 12.0 Xml; HDR=YES; IMEX=1''; Persist Security Info=False';
  DEFAULT_SQLITE_CONN_STR = 'Data Source={0};Pooling=true;FailIfMissing=false';
  DEFAULT_SQLITE_DBLIST_FILE_NAME = 'dblist.db';
  DEFAULT_EMBEDED_DBPATH = '..\db\';
  DEFAULT_EMBEDED_EMPTY = 'empty';
  DBMS_MSSQL = 'mssql';
  DBMS_FIREBIRD = 'firebird';

  SERVER_MSSQL_CONN_STR = 'Password=%s;Persist Security Info=True;User ID=%s;Initial Catalog=%s;Data Source=%s';
type
  TTextAppender = Class(TObject)
    protected
      function CreateTextFile(filePath: String): Boolean;
      function CreateAllDir(directory: String): Boolean;
      function GetParentDir(const Directory: String): String;
    public
      procedure TextFileAppend(filePath, msg: String);
  End;

//-----------------------------------------------------------------+
// 클래스명:    TAbsDBManager
// 주요역할:    DB를 관리 하기 위한 상위 추상 클래스 이다.
//-----------------------------------------------------------------+
  TAbsDBManager = Class(TObject)
    private


      function GetDBName: String; virtual;
      procedure SetDBName(const Value: String); virtual;

    protected
      FDBName: String;
      FConnStr: String;
      FTableNames: TStringList;
      FColumnNames: IStrMap;
      FDataSource: TDataSource;
      FDefaultDBName: String;
      //procedure WriteErrorMessage(msg: String);
      function WideStringToString(const ws: WideString; codePage: Word): AnsiString;
    public
      property DBName: String read GetDBName write SetDBName;
      function GetTableNames: TStringList;
      function GetColumnNames(tableName: String): TStringList;
      procedure SetTableNames(); virtual; abstract;
      procedure SetColumnNames(); virtual; abstract;
      function ExecuteQuery(query: String): TDataSet; virtual; abstract;
      function ExecuteNonQuery(query: String): Integer; virtual; abstract;
      function Backup(backupPath: String): Boolean; virtual; abstract;
      function Open(): Boolean; overload; virtual; abstract;
      function Open(dbName: String): Boolean; overload; virtual;
      function IsOpen(): Boolean; virtual; abstract;
      procedure Close(); virtual; abstract;
      function Restore(filePath, RestoreName: String): Boolean; virtual; abstract;
      function CreateDB(DBName: String): Boolean; virtual; abstract;
      function DropDB(DbName: String): Boolean; virtual; abstract;
      function GetDBList(isFilter: Boolean): TStringList; virtual; abstract;
      function GetDBMSName: String; virtual; abstract;
      procedure WriteErrorMessage(msg: String);
  end;

  TAbsDBServer = Class(TAbsDBManager)
    protected
      FID: String;
      FPW: String;
      FAddr: String;
    public
      function Login(id, pw, defDB, addr: String): Boolean; virtual; abstract;
  End;

  TAbsEmbededDB = Class(TAbsDBManager)
    private
      FDBFile: String;
      procedure SetDBName(const dbName: String); override;
    protected
      FRestoredFilePath: String;
      FRestoredName: String;
      function GetDBFile: String; virtual;
      procedure SetDBFile(dbFile: String); virtual;
      function DBFileCopy(srcFile, desFile: String): Boolean;
      function DBFileDelete(srcFile: String): Boolean;
      function DBFileCheckAndAppendPath(dbName: String): String;
    public
      property DBFile: String read GetDBFile write SetDBFile;
      function CreateDB(DBName: String): Boolean; override;
      function DropDB(DbName: String): Boolean; override;
      function Restore(filePath, RestoreName: String): Boolean; override;
      function GetDBFileExt: String; virtual; abstract;
  End;








implementation

uses SysUtils, FileManager, FMX.Forms;




{ TDBManager }

//-----------------------------------------------------------------+
// DB내 지정한 테이블의 모든 열이름을 가져온다.
//-----------------------------------------------------------------+
function TAbsDBManager.GetColumnNames(tableName: String): TStringList;
begin
  if ( FColumnNames = nil ) or ( FColumnNames.ContainsKey( tableName ) = false ) then
  begin
    SetColumnNames();
  end;

  result := self.FColumnNames.GetValue(tableName) as TStringList;
end;

//-----------------------------------------------------------------+
// DBName 프로퍼티의 Get 메서드 이다. 현재 지정된 DB 이름을 얻는다.
// 단, DB이름이 지정되지 않았을 시 현재 날짜와 시간을 이용하여
// 새로 지정하고 그 값을 리턴 한다.
//-----------------------------------------------------------------+
function TAbsDBManager.GetDBName: String;
begin
  if FDBName = '' then
  begin
    FDBName := DEFAULT_DB_NAME + FormatDateTime('yyyy_MM_dd_hh_mm_ss', Now);
    FreeAndNil(FTableNames);
    FreeAndNil(FColumnNames);
  end;
  result := FDBName;
end;

//-----------------------------------------------------------------+
// 현재 지정된 DB에 존재하는 모든 테이블 이름들을 얻는다.
//-----------------------------------------------------------------+
function TAbsDBManager.GetTableNames: TStringList;
begin
  if FTableNames = NIL then
  begin
    SetTableNames;
  end;

  result := FTableNames;
end;

function TAbsDBManager.Open(dbName: String): Boolean;
begin
  self.DBName := dbName;
  result := Open();
end;

//-----------------------------------------------------------------+
// DBName 프로퍼티의 Set 메서드 이다.
// 사용할 DB 이름을 설정 한다.
//-----------------------------------------------------------------+
procedure TAbsDBManager.SetDBName(const Value: String);
begin
  FDBName := Value;
end;

//-----------------------------------------------------------------+
// 예외 발생시 그 내용을 기록 하기 위해 쓰인다.
//-----------------------------------------------------------------+
procedure TAbsDBManager.WriteErrorMessage(msg: String);
var
  txtAppender: TTextAppender;
begin
  txtAppender := TTextAppender.Create;
  txtAppender.TextFileAppend(GetCurrentDir + '\' + DEFAULT_ERR_FILE_NAME, msg);
  txtAppender.Free;
end;

function TAbsDBManager.WideStringToString(const ws: WideString; codePage: Word): AnsiString;
var
  l: integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(codePage,
      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
      @ws[1], - 1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(codePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        @ws[1], - 1, @Result[1], l - 1, nil, nil);
  end;
end; { WideStringToString }



//-----------------------------------------------------------------+
// 텍스트 파일의 기존 내용에 새로이 추가 해 준다.
// 만약 지정한 경로에 파일이 없을 경우 새로 생성 한다.
// filePath: 내용을 추가 할 텍스트 파일의 경로.
// msg: 추가할 내용.
//-----------------------------------------------------------------+
procedure TTextAppender.TextFileAppend(filePath, msg: String);
var
  targetFile: TextFile;
begin
  CreateTextFile(filePath);
  AssignFile(targetFile, filePath);
  Append(targetFile);
  Writeln(targetFile, msg);
  CloseFile(targetFile);
end;

//-----------------------------------------------------------------+
// 지정한 경로에 텍스트 파일을 만든다.
// 만약 그 경로에 해당되는 부모 폴더가 없다면 스스로 만든다.
// filePath: 텍스트 파일을 만들 경로.
//-----------------------------------------------------------------+
function TTextAppender.CreateTextFile(filePath: string): Boolean;
var
  iFileHandlerId: Integer;
begin
  try
    CreateAllDir(GetParentDir(filePath));
    if FileExists(filePath) = false then
    begin
      iFileHandlerId := FileCreate(filePath);
      SysUtils.FileClose(iFileHandlerId);
    end;
    result := true;
  except
    result := false;
  end;
end;

//-----------------------------------------------------------------+
// 설정한 경로의 폴더를 만든다.
// 만약 상위 폴더가 없다면 그것도 함께 만든다. (재귀 호출 사용)
// directory: 폴더를 만들 경로./
//-----------------------------------------------------------------+
function TTextAppender.CreateAllDir(directory: String): Boolean;
var
  targetFile: TextFile;
  parentPath: String;
  iFileHandlerId: Integer;
begin
  parentPath := GetParentDir(directory);
  try
    if DirectoryExists(parentPath) = false then
    begin
      CreateAllDir(parentPath);
    end;
    CreateDir(directory);
    result := true;
  except
    result := false;
  end;
end;

//-----------------------------------------------------------------+
// 지정한 경로를 통해 부모 폴더의 경로를 얻는다.
// Directory: 부모 폴더의 경로를 얻고 싶은 전체 경로.
//-----------------------------------------------------------------+
function TTextAppender.GetParentDir(const Directory: String): String;
var
  TempStr: String;
begin
  TempStr := Directory;
  if (TempStr[Length(Result)] = '\') then
  begin
  Delete(TempStr, Length(TempStr), 1);
  end;
  Result := Copy(TempStr, 1, LastDelimiter('\', TempStr) - 1);
end;








{ TAbsEmbededDB }

function TAbsEmbededDB.CreateDB(DBName: String): Boolean;
begin
  result := DBFileCopy( DEFAULT_EMBEDED_DBPATH + DEFAULT_EMBEDED_EMPTY + GetDBFileExt,
                        DBFileCheckAndAppendPath( dbName ) );
end;

function TAbsEmbededDB.DBFileCheckAndAppendPath(dbName: String): String;
var
  sRet: String;
begin
  if AnsiContainsText( LowerCase( dbName ), ':\' ) = true then
  begin
    sRet := dbName;
  end
  else if AnsiContainsText( LowerCase( dbName ), GetDBFileExt ) = true then
  begin
    sRet := TFile.CurrentDir + '\' + DEFAULT_EMBEDED_DBPATH + dbName;
  end
  else
  begin
    sRet := TFile.CurrentDir + '\' + DEFAULT_EMBEDED_DBPATH + dbName + GetDBFileExt;
  end;

  FRestoredName := dbName;
  FRestoredFilePath := sRet;
  result := sRet;
end;

function TAbsEmbededDB.DBFileCopy(srcFile, desFile: String): Boolean;
var
  fileMgr: TFile;
begin
  fileMgr := TFile.Create;
  result := fileMgr.CopyFile( srcFile, desFile );
  fileMgr.Free;
end;

function TAbsEmbededDB.DBFileDelete(srcFile: String): Boolean;
begin
  try
    DeleteFile( srcFile );
    result := true;
  except
    on e: Exception
    do WriteErrorMessage( e.Message );
  end;
  result := false;
end;

function TAbsEmbededDB.DropDB(DbName: String): Boolean;
begin
  result :=  DBFileDelete( DBFileCheckAndAppendPath( dbName ) );
end;

function TAbsEmbededDB.GetDBFile: String;
begin
  result := FDBFile;
end;

function TAbsEmbededDB.Restore(filePath, RestoreName: String): Boolean;
begin
  result := DBFileCopy( filePath, DBFileCheckAndAppendPath( restoreName ) );
end;

procedure TAbsEmbededDB.SetDBFile(dbFile: String);
var
  sList: TStringList;
  sTmp: String;
begin
  FDBFile := dbFile;

  sList := TSTringList.Create;
  sList.Delimiter := '\';
  sList.DelimitedText := dbFile;
//  sTmp := sList[ sList.Count - 1 ];
//
//
//  sList.Clear;
//  sList.Delimiter := '.';
//  sList.DelimitedText := sTmp;
  FDBName := sList[ sList.Count - 1 ];

  sList.Free;
end;

procedure TAbsEmbededDB.SetDBName(const dbName: String);
begin
  if dbName = FRestoredName then
    SetDBFile( FRestoredFilePath )
  else
    SetDBFile( dbName );
end;



end.
