unit Form_SearchOptionUnit;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Objects, FMX.Ani,
  FMX.ListBox, FMX.Layouts, Data.DB, IBDatabase, IBServices, FMX.Edit,
  System.UITypes, FMX.Grid, Datasnap.DBClient, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.DBLinks,
  Fmx.Bind.DBLinks, Data.Bind.DBScope, System.Rtti, System.Bindings.Outputs,
  FMX.ExtCtrls, FMX.Menus, Data.DBXFirebird, Data.SqlExpr, DBAccess, Uni,
  UniProvider, InterBaseUniProvider, MemDS,
  UIWrapper_StageEditorUnit, UIWrapper_LogSearchUnit, DBManager,
  SearchResult, FileManager, UIWappedPartUnit, StageOptionPartList,
  HashedOptionPart, SearchOption_Intf;

type
    TForm_SearchOption = class(TForm)
    Label1: TLabel;
    Rectangle1: TRectangle;
    Panel_SearchOption: TPanel;
    Expander_Group: TExpander;
    Expander_Column: TExpander;
    StyleBook1: TStyleBook;
    ListBox_Column: TListBox;
    Label2: TLabel;
    ComboBox_TimeUnit: TComboBox;
    Label3: TLabel;
    ComboBox_Function: TComboBox;
    Panel_SearchOptionTitle: TPanel;
    Expander_Datetime: TExpander;
    Expander_Round: TExpander;
    Label4: TLabel;
    ComboBox_DecPlace: TComboBox;
    Expander_Stage: TExpander;
    Layout_SearchOptionList: TLayout;
    Button_AllSelect: TButton;
    Button_Clear: TButton;
    CheckBox_Auto: TCheckBox;
    Layout2: TLayout;
    Edit1: TEdit;
    Label5: TLabel;
    Edit2: TEdit;
    Label6: TLabel;
    Edit3: TEdit;
    ListBox_LogData: TListBox;
    Panel_StageOption: TPanel;
    ScrollBox_StageOptionList: TScrollBox;
    Panel_LogData: TPanel;
    Layout_LogData: TLayout;
    Panel_LogDataTop: TPanel;
    ComboBox_LogTableName: TComboBox;
    ClearingEdit_Keyword: TClearingEdit;
    Button_LogSearch: TButton;
    Button_Search: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button_SearchClick(Sender: TObject);

  private
    FDBM: TAbsDBManager;
    FTableName: String;
    FSchOptPart: array[0..3] of TAbsUIWrappedPart;  //column, group, round, datetime
    FAutoStgOpt: THashedOptionPart;
    FStageOptionList: TStageOptionList;
    FStageEditor: TUIWrapper_StageEditor;
    FLogSearch: TUIWrapper_LogSearch;
  protected
    FSearchResultSet: TSearchResultSet;
    procedure Init;

    procedure OnLogSearch_LogDataSelected(Sender: TObject; logData: ILogData);
  public
    { Public declarations }

    function GetSearchResult: TSearchResultSet;
    function ShowModalWithInitItems(tablename: String; dbm: TAbsDBManager): TModalResult;
    function IsDateTimeSplit: Boolean;
  end;

var
  Form_SearchOption: TForm_SearchOption;
  isDrag: Boolean;
implementation

uses
  Frame_SchOpt_StageInfo, MsSqlDBManager,
  FireBirdDBManager, SearchOption,
  Const_SearchOptionUnit, ColumnsOptionPart, DatetimeOptionPart,
  RoundOptionPart, GroupOptionPart, StrUtils;

{$R *.fmx}


procedure TForm_SearchOption.Button_SearchClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FStageEditor.Count - 1 do
  begin
    FStageEditor.GetStageOption( i );
  end;

  self.ModalResult := mrOk;
end;

procedure TForm_SearchOption.FormCreate(Sender: TObject);
begin
  Init;
end;

function TForm_SearchOption.GetSearchResult: TSearchResultSet;
var
  schOption: TSearchOption;
  i: Integer;
begin
  schOption := TSearchOption.Create;
  schOption.SetStageOptionList( FStageOptionList );
  schOption.SetDBManager( FDBM );
  schOption.TableName := FTableName;

  for i := 0 to High( FSchOptPart ) do
  begin
    schOption.AddSearchOption( SOP_NAME_SEQ[ i + 1 ], FSchOptPart[ i ] );
  end;

  FschOptPart[ 0 ].SetValues( 'dbms', FDBM.GetDBMSName );
  FAutoStgOpt.SetValues( 'stage_auto.use',
    ifthen(  FStageOptionList.IsUse and
    ( CheckBox_Auto.Enabled and CheckBox_Auto.IsChecked ), 'true', 'false' ) );
  schOption.AddSearchOption( 'stage_auto', FAutoStgOpt );

  FSearchResultSet := TSearchResultSet.Create( schOption, FDBM );

  result := FSearchResultSet;
end;

procedure TForm_SearchOption.Init;
begin
  FLogSearch        := TUIWrapper_LogSearch.Create( ComboBox_LogTableName, ClearingEdit_Keyword, Button_LogSearch, ListBox_LogData );
  FStageEditor      := TUIWrapper_StageEditor.Create( ScrollBox_StageOptionList, FLogSearch );

  FschOptPart[ 0 ]  := TColumnsOptionPart.Create( Expander_Column, ListBox_Column, Button_AllSelect, Button_Clear );
  FSchOptPart[ 1 ]  := TGroupOptionPart.Create( Expander_Group, ComboBox_TimeUnit, ComboBox_Function );
  FSchOptPart[ 2 ]  := TRoundOptionPart.Create( Expander_Round, ComboBox_DecPlace );
  FSchOptPart[ 3 ]  := TDatetimeOptionPart.Create( Expander_Datetime );
  FStageOptionList  := TStageOptionList.Create( Expander_Stage, CheckBox_Auto, FStageEditor );

  FAutoStgOpt       := THashedOptionPart.Create;
  FAutoStgOpt.SetValues( 'stage_auto.use', 'false' );
  FAutoStgOpt.SetValues( 'stage_auto.stagenum', '0' );
  FAutoStgOpt.SetValues( 'stage_auto.tablename', 'DATALOG' );
  FAutoStgOpt.SetValues( 'stage_auto.stagecol', 'STAGE' );
  FAutoStgOpt.SetValues( 'stage_auto.datecol', 'DATETIME' );

  FLogSearch.OnLogDataSelected := OnLogSearch_LogDataSelected;
end;

function TForm_SearchOption.IsDateTimeSplit: Boolean;
begin
  result := Expander_Datetime.IsChecked;
end;

procedure TForm_SearchOption.OnLogSearch_LogDataSelected(Sender: TObject;
  logData: ILogData);
begin
  FStageEditor.AddLogData( logData );
end;

function TForm_SearchOption.ShowModalWithInitItems(tablename: String;
  dbm: TAbsDBManager): TModalResult;
var
  bIsDeferDBM: Boolean;
begin
  bIsDeferDBM :=  ( FDBM = nil ) or
                  ( FDBM.GetDBMSName <> dbm.GetDBMSName ) or
                  ( FDBM.DBName <> dbm.DBName );

  if bIsDeferDBM = true then
  begin
    FDBM := dbm;
    FLogSearch.SetDBManager( dbm );
    FStageOptionList.SetValues( 'autodetect', dbm.GetDBMSName );
    FLogSearch.Clear;
  end;

  if ( bIsDeferDBM = true ) or ( FTableName <> tableName ) then
  begin
    FTableName := tableName;
    ( FSchOptPart[ 0 ] as TColumnsOptionPart ).SetColumns( dbm.GetColumnNames( tableName ) );
  end;

  Button_Search.ModalResult := mrNone;

  result := self.ShowModal;
end;

procedure TForm_SearchOption.Button1Click(Sender: TObject);
//  var
//  UIWrapper_columns: TUIWrapper_AbsSearchOptionPart;
//  UIWrapper_round: TUIWrapper_AbsSearchOptionPart;
//  UIWrapper_group: TUIWrapper_AbsSearchOptionPart;
//  UIWrapper_stageedit: TUIWrapper_StageEditor;
//  UIWrapper_search: TUIWrapper_LogSearch;
//  frame: TFrame_SchOpt_StageInfo;
//  dbm: TAbsDBManager;
//  col: TColumn;
//  data: TDataSet;
//  i: Integer;
//  sDate: String;
begin
//  dbm := TFireBirdDBManager.Create;//TMsSqlDBManager.Create;
//  dbm.DBName := 'D:\dsr db sample\INSIGHTLOG.GDB';//'d:\theson.fdb';//'theson';
//  dbm.Open;
//  UIWrapper_columns := TUIWrapper_SchOpt_Column.Create( Expander_Column, ListBox_Column, Button_AllSelect, Button_Clear );
//  UIWrapper_round := TUIWrapper_SchOpt_Round.Create( Expander_Round, ComboBox_DecPlace );
//  UIWrapper_group := TUIWrapper_SchOpt_Group.Create( Expander_Group, ComboBox_TimeUnit, ComboBox_Function );
//  UIWrapper_stageedit := TUIWrapper_StageEditor.Create( ScrollBox_StageOptionList );
//  UIWrapper_search := TUIWrapper_LogSearch.Create( ComboBox_LogTableName, ClearingEdit_Keyword, Button_LogSearch, ListBox_LogData );

  //UIWrapper_search.

//  data := dbm.ExecuteQuery('select * from eventlog;');;//dbm.ExecuteQuery('select * from journal;');

  //ShowMessage( data.Fields[ 0 ].AsString );
  //DataSource1.DataSet := data;
//  ListBox_LogData.Clear;
//
//  for i := 0 to data.RecordCount - 1 do
//  begin
//    DateTimeToString( sDate, 'yyyy-MM-dd HH:mm:ss', data.Fields[0].AsDateTime );
//    ListBox_LogData.Items.Add( sDate + ' | ' + data.Fields[1].AsString);
//    data.Next;
//  end;
//                        (ListBox1 as TListBox).AllowDrag := true;
//  col := TColumn.Create(nil);
//  col.Width := 50;
//  col.Parent := StringGrid1;
  //StringGrid1.
end;






end.
