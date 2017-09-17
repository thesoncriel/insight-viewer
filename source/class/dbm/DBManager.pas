//-----------------------------------------------------------------+
// ���ϸ�Ī:    DBManager
// ������Ʈ:    InsightViewer
// ó������:    MS-SQL Server �� Fire Bird �� DB Data ó��
// ���߾��:    Delphi XE2 with Fire Monkey
// �ۼ�����:    ������ ��񰳹��� S/W ������s
// ���߹���:    Ver 1.1 (2011.10.10)
//-----------------------------------------------------------------+

unit DBManager;

interface

uses
  Classes, iniFiles, DB, Variants, HashMap, DCL_intf, ADODB, StrUtils,
  DBTables, Windows;

//-----------------------------------------------------------------+
//DB ������ ���̴� ��� ����
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
// Ŭ������:    TAbsDBManager
// �ֿ俪��:    DB�� ���� �ϱ� ���� ���� �߻� Ŭ���� �̴�.
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
// DB�� ������ ���̺��� ��� ���̸��� �����´�.
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
// DBName ������Ƽ�� Get �޼��� �̴�. ���� ������ DB �̸��� ��´�.
// ��, DB�̸��� �������� �ʾ��� �� ���� ��¥�� �ð��� �̿��Ͽ�
// ���� �����ϰ� �� ���� ���� �Ѵ�.
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
// ���� ������ DB�� �����ϴ� ��� ���̺� �̸����� ��´�.
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
// DBName ������Ƽ�� Set �޼��� �̴�.
// ����� DB �̸��� ���� �Ѵ�.
//-----------------------------------------------------------------+
procedure TAbsDBManager.SetDBName(const Value: String);
begin
  FDBName := Value;
end;

//-----------------------------------------------------------------+
// ���� �߻��� �� ������ ��� �ϱ� ���� ���δ�.
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
// �ؽ�Ʈ ������ ���� ���뿡 ������ �߰� �� �ش�.
// ���� ������ ��ο� ������ ���� ��� ���� ���� �Ѵ�.
// filePath: ������ �߰� �� �ؽ�Ʈ ������ ���.
// msg: �߰��� ����.
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
// ������ ��ο� �ؽ�Ʈ ������ �����.
// ���� �� ��ο� �ش�Ǵ� �θ� ������ ���ٸ� ������ �����.
// filePath: �ؽ�Ʈ ������ ���� ���.
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
// ������ ����� ������ �����.
// ���� ���� ������ ���ٸ� �װ͵� �Բ� �����. (��� ȣ�� ���)
// directory: ������ ���� ���./
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
// ������ ��θ� ���� �θ� ������ ��θ� ��´�.
// Directory: �θ� ������ ��θ� ��� ���� ��ü ���.
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
