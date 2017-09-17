unit SimpleResult;

interface

uses
  DataFileSaver, Data.DB, DBManager;

type
  TSimpleResult = class(TInterfacedObject, IDataSetIterator)
    private
      FData: TDataSet;
      FTableName: String;
      FIterPointer: Integer;
    public
      constructor Create(tableName: String; dbm: TAbsDBManager);
      function MoveNext(): Boolean;
      function CurData(): TDataSet;
      function CurName(): String;
      function Count(): Integer;
      procedure MoveFirst;
  end;

implementation

{ TSimpleResult }

function TSimpleResult.Count: Integer;
begin
  result := 1;
end;

constructor TSimpleResult.Create(tableName: String; dbm: TAbsDBManager);
begin
  FTableName := tableName;
  FData := dbm.ExecuteQuery( 'select * from ' + tableName + ';' );
  MoveFirst;
end;

function TSimpleResult.CurData: TDataSet;
begin
  result := FData;
end;

function TSimpleResult.CurName: String;
begin
  result := FTableName;
end;

procedure TSimpleResult.MoveFirst;
begin
  FIterPointer := -1;
end;

function TSimpleResult.MoveNext: Boolean;
var
  bRet: Boolean;
begin
  bRet := ( FIterPointer < 0 );
  Inc( FIterPointer );
  result := bRet;
end;

end.
