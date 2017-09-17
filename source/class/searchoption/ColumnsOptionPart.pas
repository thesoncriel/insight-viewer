unit ColumnsOptionPart;

interface

uses
  Classes, SearchOption_Intf, FMX.ListBox, FMX.Controls, UIWappedPartUnit;

type
  TColumnsOptionPart = class(TAbsUIWrappedPart)
    private
      FListBox: TListBox;
      FBtnAllSelect: TButton;
      FBtnClear: TButton;
    protected
      FDBMSName: String;
      //FColumns: TStringList;
      FDatetimeColumn: String;
      FNormalQuery: String;
      FGroupQuery: String;
      procedure SetTemplateQuery;
      function DistinctDatetime(cols: TStringList): TStringList;
      procedure BtnAllSel_OnClick(Sender: TObject);
      procedure BtnClear_OnClick(Sender: TObject);
      procedure SetAllSelect(val: Boolean);
    public
      //constructor Create(dbmsName: String); overload;
      constructor Create(owner: TExpander; listBox: TListBox; btnAllSel, btnClear: TButton );
      procedure SetDatetimeColumn(col: String);
      procedure SetColumns(cols: TStringList);
      function GetColumns: TStringList;
      function InsertPartToQuery(tagQuery, key: String; currIndex: Integer): String; override;
      function GetValues(key: String): String; override;
      procedure SetValues(key, val: String); override;
      function GetSelectedItems: TStringList;
  end;
implementation

uses
  SysUtils, QueryReader, Const_SearchOptionUnit, StrUtils;

{ TColumnsOptionPart }

procedure TColumnsOptionPart.BtnAllSel_OnClick(Sender: TObject);
begin
  SetAllSelect( true );
end;

procedure TColumnsOptionPart.BtnClear_OnClick(Sender: TObject);
begin
  SetAllSelect( false );
end;

constructor TColumnsOptionPart.Create(owner: TExpander; listBox: TListBox; btnAllSel, btnClear: TButton );
begin
  Init( owner );
  FListBox := listBox;
  FBtnAllSelect := btnAllSel;
  FBtnClear := btnClear;

  FBtnAllSelect.OnClick := BtnAllSel_OnClick;
  FBtnClear.OnClick := BtnClear_OnClick;

  FDBMSName := 'firebird';
  SetTemplateQuery;
end;


function TColumnsOptionPart.GetColumns: TStringList;
var
  sList: TStringList;
  i: Integer;
begin
  sList := TStringList.Create;
  sList.AddStrings( FListBox.Items );

  result := sList;
end;

function TColumnsOptionPart.GetSelectedItems: TStringList;
var
  sList: TStringList;
  i: Integer;
begin
  sList := TStringList.Create;

  for i := 0 to FListBox.Count - 1 do
  begin
    if FListBox.ListItems[ i ].IsChecked = true then
    begin
      sList.Add( FListBox.ListItems[ i ].Text );
    end;
  end;

  result := sList;
end;

function TColumnsOptionPart.GetValues(key: String): String;
begin
  if key = 'columns.datetime' then
  begin
    result := FDatetimeColumn;
  end
  else if FListBox.Items = Nil then
  begin
    exit;
  end;

  result := FListBox.Items[ StrToInt( key ) ];
end;

function TColumnsOptionPart.InsertPartToQuery(tagQuery, key: String;
  currIndex: Integer): String;
var
  sbQuery: TStringBuilder;
  sTempCols: String;
  sAppendedCols: String;
  i: Integer;
  sListCols: TStringList;
begin
  sbQuery := TStringBuilder.Create;
  sListCols := GetSelectedItems;

  if key = 'columns.normal' then
    sTempCols := FNormalQuery
  else if key = 'columns.group' then
    sTempCols := FGroupQuery;

  if key = 'columns.datetime' then
  begin
    result := StringReplace( tagQuery, '{' + IntToStr( currIndex ) + '}', FDatetimeColumn, [ rfReplaceAll, rfIgnoreCase ] );
    exit;
  end
  else
  begin
    for i := 0 to sListCols.Count - 1 do
    begin
      sbQuery.Append(
        StringReplace( sTempCols, '{0}', sListCols[ i ], [ rfReplaceAll, rfIgnoreCase ] ) );
    end;

    sAppendedCols := sbQuery.ToString;
  end;
  result := StringReplace( tagQuery, '{' + IntToStr( currIndex ) + '}', sAppendedCols, [ rfReplaceAll, rfIgnoreCase ] );
end;

procedure TColumnsOptionPart.SetAllSelect(val: Boolean);
var
  i: Integer;
begin
  for i := 0 to FListBox.Count - 1 do
  begin
    FListBox.ListItems[ i ].IsChecked := val;
  end;
end;

procedure TColumnsOptionPart.SetColumns(cols: TStringList);
begin
  //FColumns := cols;
  FListBox.Items.Clear;
  FListBox.Items.AddStrings( DistinctDatetime( cols ) );
end;

procedure TColumnsOptionPart.SetDatetimeColumn(col: String);
begin
  FDatetimeColumn := col;
end;

procedure TColumnsOptionPart.SetTemplateQuery;
var
  queryReader: TQueryReader;
begin
  queryReader := TQueryReader.Create( FDBMSName, 'insightviewer' );
  FNormalQuery := queryReader.GetQuery( 'template.column.normal' );
  FGroupQuery := queryReader.GetQuery( 'template.column.group' );
  queryReader.Free;
end;

procedure TColumnsOptionPart.SetValues(key, val: String);
var
  iKey: Integer;
begin
  if key = 'dbms' then
  begin
    FDBMSName := val;
    SetTemplateQuery;
    exit;
  end;

  if FListBox.Items = Nil then exit;

  iKey := StrToInt( key );

  if FListBox.Count <= iKey then exit;

  FListBox.Items.Add( val )
end;

function TColumnsOptionPart.DistinctDatetime(cols: TStringList): TStringList;
var
  i, j: Integer;
  isMatch: Boolean;
  sList: TStringList;
begin
  isMatch := false;
  sList := TStringList.Create;
  FDatetimeColumn := '';

  for i := 0 to cols.Count - 1 do
  begin
    for j := 0 to High( DATETIME_COLUMN_PATTERN ) do
    begin
      if ( ContainsStr( LowerCase( cols[ i ] ), DATETIME_COLUMN_PATTERN[ j ] ) = true ) then
      begin
        isMatch := true; break;
      end
      //else isMatch := isMatch or false;
      else isMatch := false;
    end;

    if ( FDatetimeColumn = '' ) and ( isMatch = true ) then
      FDatetimeColumn := cols[ i ]
    else if isMatch = false then
      sList.Add( cols[ i ] );
  end;

  result := sList;
end;

end.
