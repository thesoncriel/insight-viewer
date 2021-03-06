unit ExcelSaver;

interface

uses
  DataFileSaver, Classes, DB, System.StrUtils;

const
  MAX_ROW_PER_FILE = 50;//65530;

type
  TExcelSaver = class(TAbsFileSaver)
    private
//      CXlsBof: array[0..5] of Word;
//      CXlsEof: array[0..1] of Word;
//      CXlsLabel: array[0..5] of Word;
//      CXlsNumber: array[0..4] of Word;
//      CXlsRk: array[0..4] of Word;

      FStream: TStream;
      FDataSet: TDataSet;
      FCurrPage: Integer;
    protected
      procedure XlsBeginStream(XlsStream: TStream; const BuildNumber: Word);
      procedure XlsEndStream(XlsStream: TStream);
      procedure XlsWriteCellRk(XlsStream: TStream; const ACol, ARow: Word; const AValue: Integer);
      procedure XlsWriteCellNumber(XlsStream: TStream; const ACol, ARow: Word; const AValue: Double);
      procedure XlsWriteCellLabel(XlsStream: TStream; const ACol, ARow: Word; const AValue: string);

      function WideStringToString(const ws: WideString; codePage: Word): AnsiString;
      function IsStringType( fieldType: TFieldType ): Boolean;
      function IsDoubleType( fieldType: TFieldType ): Boolean;
      function IsIntegerType( fieldType: TFieldType ): Boolean;
      function IsTimeType( fieldType: TFieldType ): Boolean;
      function GetFieldType( fieldType: TFieldType ): TFieldType;

      procedure AppendColumnName;
      procedure AppendStrField(colNum: Integer);
      procedure AppendDblField(colNum: Integer);
      procedure AppendIntField(colNum: Integer);
      procedure AppendTimeField(colNum: Integer);
    public
      constructor Create();
      function SaveTo(data: TDataSet; filePath: String): Boolean; overload; override;
      function SaveTo(dataIter: IDataSetIterator; filePath: String): Integer; overload; override;
      function SaveToMulti(data: TDataSet; filePath: String): Boolean;
  end;
implementation

uses
  Windows, System.Variants, SysUtils;

var
  CXlsBof: array[0..5] of Word = ($809, 8, 00, $10, 0, 0);
  CXlsEof: array[0..1] of Word = ($0A, 00);
  CXlsLabel: array[0..5] of Word = ($204, 0, 0, 0, 0, 0);
  CXlsNumber: array[0..4] of Word = ($203, 14, 0, 0, 0);
  CXlsRk: array[0..4] of Word = ($27E, 10, 0, 0, 0);

{ TExcelSaver }

function TExcelSaver.SaveTo(data: TDataSet; filePath: String): Boolean;
var
  bRet: Boolean;
  i: Integer;
  fieldType: TFieldType;
begin
  FCurrPage := 0;
  bRet := true;
  FDataSet := data;
  FStream := TFileStream.Create( filePath, fmCreate );
  try
    XlsBeginStream( FStream, 0 );
    AppendColumnName;

    for i := 0 to FDataSet.FieldCount - 1 do
    begin
      fieldType := GetFieldType( FDataSet.Fields[ i ].DataType );

      case fieldType of
        ftFloat:    AppendDblField( i );
        ftInteger:  AppendIntField( i );
        ftString:   AppendStrField( i );
        ftTime:     AppendTimeField( i );
      end;
    end;

//     for I := 0 to 99 do
//      for J := 0 to 99 do
//      begin
////        XlsWriteCellNumber(FStream, I, J, 34.34);
//       // XlsWriteCellRk(FStream, I, J, 3434);
////        XlsWriteCellLabel(FStream, I, J, Format('Cell: %d,%d', [I, J]));
//      end;
    XlsEndStream( FStream );
  except
    bRet := false;
  end;

  FStream.Free;
  result := bRet;
end;

function TExcelSaver.SaveTo(dataIter: IDataSetIterator; filePath: String): Integer;
var
  iRet: Integer;
  bSaveResult: Boolean;
  sFilePath: String;
begin
  iRet := 0;

  while dataIter.MoveNext do
  begin
    sFilePath := StringReplace( filePath, '.xls', '_' + dataIter.CurName + '.xls', [ rfIgnoreCase ] );
    bSaveResult := SaveTo( dataIter.CurData, sFilePath );
    if bSaveResult = true then Inc( iRet );
  end;

  dataIter.MoveFirst;
  result := iRet;
end;

function TExcelSaver.SaveToMulti(data: TDataSet; filePath: String): Boolean;
var
  bRet: Boolean;
  i: Integer;
  fieldType: TFieldType;
  iFileCount: Integer;
  iFileMax: Integer;
begin
  bRet := true;
  FDataSet := data;
  iFileCount := 0;
  iFileMax := data.RecordCount div MAX_ROW_PER_FILE;

  for iFileCount := 0 to iFileMax do
  begin
    FStream := TFileStream.Create( StringReplace( filePath, '.xls', IntToStr( iFileCount ) + '.xls', [rfReplaceAll] ), fmCreate );
    try
      XlsBeginStream( FStream, 0 );
      AppendColumnName;

      for i := 0 to FDataSet.FieldCount - 1 do
      begin
        fieldType := GetFieldType( FDataSet.Fields[ i ].DataType );

        case fieldType of
          ftFloat:    AppendDblField( i );
          ftInteger:  AppendIntField( i );
          ftString:   AppendStrField( i );
          ftTime:     AppendTimeField( i );
        end;

        FDataSet.MoveBy( iFileCount * MAX_ROW_PER_FILE )
      end;

  //     for I := 0 to 99 do
  //      for J := 0 to 99 do
  //      begin
  ////        XlsWriteCellNumber(FStream, I, J, 34.34);
  //       // XlsWriteCellRk(FStream, I, J, 3434);
  ////        XlsWriteCellLabel(FStream, I, J, Format('Cell: %d,%d', [I, J]));
  //      end;
      XlsEndStream( FStream );
      FDataSet.MoveBy( ( iFileCount + 1 ) * MAX_ROW_PER_FILE )
    except
      bRet := false;
    end;
  end;

  FStream.Free;
  result := bRet;
end;

procedure TExcelSaver.AppendTimeField(colNum: Integer);
var
  iRow: Integer;
  field: TField;
  sValue: String;
begin
  iRow := 1;
  field := FDataSet.Fields[ colNum ];

  while FDataSet.Eof = false do
  begin
    sValue := VarToStr( field.Value );
    sValue := ReplaceStr( sValue, '����', 'AM' );
    sValue := ReplaceStr( sValue, '����', 'PM' );
    XlsWriteCellLabel( FStream, colNum, iRow, sValue );
    FDataSet.Next;
    Inc( iRow );
  end;

  FDataSet.First;
end;

procedure TExcelSaver.AppendColumnName;
var
  i: Integer;
begin
  for i := 0 to FDataSet.FieldCount - 1 do
  begin
    XlsWriteCellLabel( Fstream, i, 0, FDataSet.Fields[ i ].FieldName );
  end;
end;

procedure TExcelSaver.AppendDblField(colNum: Integer);
var
  iRow: Integer;
  field: TField;
begin
  iRow := 1;
  field := FDataSet.Fields[ colNum ];

  while FDataSet.Eof = false do
  begin
    XlsWriteCellNumber( FStream, colNum, iRow, field.Value );
    FDataSet.Next;
    Inc( iRow );
  end;

  FDataSet.First;
end;

procedure TExcelSaver.AppendIntField(colNum: Integer);
var
  iRow: Integer;
  field: TField;
begin
  iRow := 1;
  field := FDataSet.Fields[ colNum ];

  while FDataSet.Eof = false do
  begin
    XlsWriteCellRk( FStream, colNum, iRow, field.Value );
    FDataSet.Next;
    Inc( iRow );
  end;

  FDataSet.First;
end;

procedure TExcelSaver.AppendStrField(colNum: Integer);
var
  iRow: Integer;
  field: TField;
begin
  iRow := 1;
  field := FDataSet.Fields[ colNum ];

  while FDataSet.Eof = false do
  begin
    XlsWriteCellLabel( FStream, colNum, iRow, field.Value );
    FDataSet.Next;
    Inc( iRow );
  end;

  FDataSet.First;
end;

constructor TExcelSaver.Create;
begin
  inherited;

end;

function TExcelSaver.GetFieldType(fieldType: TFieldType): TFieldType;
begin
       if IsDoubleType( fieldType )   = true then result := ftFloat
  else if IsIntegerType( fieldType )  = true then result := ftInteger
  else if IsStringType( fieldType )   = true then result := ftString
  else if IsTimeType( fieldType )     = true then result := ftTime
  else                                            result := ftString;

end;

function TExcelSaver.IsDoubleType(fieldType: TFieldType): Boolean;
begin
  result := ( fieldType = ftFloat ) or
            ( fieldType = ftSingle );
end;

function TExcelSaver.IsIntegerType(fieldType: TFieldType): Boolean;
begin
  result := ( fieldType = ftSmallint ) or
            ( fieldType = ftInteger ) or
            ( fieldType = ftWord ) or
            ( fieldType = ftBytes ) or
            ( fieldType = ftLargeint );
end;

function TExcelSaver.IsStringType(fieldType: TFieldType): Boolean;
begin
  result := ( fieldType = ftDate ) or
            ( fieldType = ftString ) or
            ( fieldType = ftMemo );
end;

function TExcelSaver.IsTimeType(fieldType: TFieldType): Boolean;
begin
  result := ( fieldType = ftDateTime ) or
            ( fieldType = ftTime ) or
            ( fieldType = ftTimeStamp );
end;



procedure TExcelSaver.XlsBeginStream(XlsStream: TStream; const BuildNumber: Word);
begin
  CXlsBof[4] := BuildNumber;
  XlsStream.WriteBuffer(CXlsBof, SizeOf(CXlsBof));
end;

procedure TExcelSaver.XlsEndStream(XlsStream: TStream);
begin
  XlsStream.WriteBuffer(CXlsEof, SizeOf(CXlsEof));
end;

procedure TExcelSaver.XlsWriteCellRk(XlsStream: TStream; const ACol, ARow: Word; const AValue: Integer);
var
  V: Integer;
begin
  CXlsRk[2] := ARow;
  CXlsRk[3] := ACol;
  XlsStream.WriteBuffer(CXlsRk, SizeOf(CXlsRk));
  V := (AValue shl 2) or 2;
  XlsStream.WriteBuffer(V, 4);
end;

procedure TExcelSaver.XlsWriteCellNumber(XlsStream: TStream; const ACol, ARow: Word; const AValue: Double);
begin
  CXlsNumber[2] := ARow;
  CXlsNumber[3] := ACol;
  XlsStream.WriteBuffer(CXlsNumber, SizeOf(CXlsNumber));
  XlsStream.WriteBuffer(AValue, 8);
end;

procedure TExcelSaver.XlsWriteCellLabel(XlsStream: TStream; const ACol, ARow: Word; const AValue: string);
var
  L: Word;
begin
  L := Length(AValue);
  CXlsLabel[1] := 8 + L;
  CXlsLabel[2] := ARow;
  CXlsLabel[3] := ACol;
  CXlsLabel[5] := L;
  XlsStream.WriteBuffer(CXlsLabel, SizeOf(CXlsLabel));
  XlsStream.WriteBuffer(Pointer( WideStringToString(AValue, CP_OEMCP) )^, L);
end;


function TExcelSaver.WideStringToString(const ws: WideString; codePage: Word): AnsiString;
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

end.
