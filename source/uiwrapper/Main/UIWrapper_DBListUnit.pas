unit UIWrapper_DBListUnit;

interface

uses
  FMX.TabControl, FMX.TreeView, UIWrapper_DBTreeViewUnit, DBManager,
  SearchResult, DataFileSaver;

type
  TUIWrapper_DBList = class(TObject)
    private
      FTabControl: TTabControl;
      FTreeViews: array of TUIWrapper_DBTreeView;
      FSelectedDBName: String;

      FOnAfterSearch: TSearchResultEvent;
      FOnFoundLogMsgData: TBooleanEvent;
      procedure OnAfterSearch_Proc(Sender: TObject; schResult: IDataSetIterator);
      procedure OnFoundLogMsgData_Proc(Sender: TObject; val: Boolean);
    public
      constructor Create(tabCtrl: TTabControl; treeViews: array of TTreeView);
      destructor Destroy; override;
      procedure ChangeTab(index: Integer);
      procedure PassFileToTab(filePath: String);
      function GetSelectedDBName: String;
      procedure ShowSearchOption;
    published
      property OnAfterSearch: TSearchResultEvent read FOnAfterSearch write FOnAfterSearch;
      property OnFoundLogMsgData: TBooleanEvent read FOnFoundLogMsgData write FOnFoundLogMsgData;
  end;

implementation

uses
  SysUtils, FireBirdDBManager, MsSqlDBManager;

{ TUIWrapper_Main_DBList }

constructor TUIWrapper_DBList.Create(tabCtrl: TTabControl; treeViews: array of TTreeView);
var
  i: Integer;
  dbm: TAbsDBManager;
begin
  FTabControl := tabCtrl;
  SetLength( FTreeViews, Length( treeViews ) );

  FTreeViews[ 0 ] := TUIWrapper_DBTreeView.Create( treeViews[ 0 ] );
  FTreeViews[ 0 ].SetDBManager( TFireBirdDBManager.Create );
  FTreeViews[ 0 ].OnAfterSearch := OnAfterSearch_Proc;
  FTreeViews[ 0 ].OnFoundLogMsgData := OnFoundLogMsgData_Proc;

  FTreeViews[ 1 ] := TUIWrapper_DBTreeView.Create( treeViews[ 1 ] );
  FTreeViews[ 1 ].SetDBManager( TMsSqlDBManager.Create );
  FTreeViews[ 1 ].OnAfterSearch := OnAfterSearch_Proc;
  FTreeViews[ 1 ].OnFoundLogMsgData := OnFoundLogMsgData_Proc;
end;

destructor TUIWrapper_DBList.Destroy;
var
  i: Integer;
begin
  for i := 0 to High( FTreeViews ) do
  begin
    FTreeViews[ i ].Free;
  end;
end;

function TUIWrapper_DBList.GetSelectedDBName: String;
begin
  result := FSelectedDBName;
end;

procedure TUIWrapper_DBList.OnAfterSearch_Proc(Sender: TObject; schResult: IDataSetIterator);
begin
  if Assigned( OnAfterSearch ) = true then
  begin
    OnAfterSearch( Sender, schResult );
  end;
end;

procedure TUIWrapper_DBList.OnFoundLogMsgData_Proc(Sender: TObject;
  val: Boolean);
begin
  if Assigned( OnFoundLogMsgData ) = true then
  begin
    OnFoundLogMsgData( Sender, val );
  end;
end;

procedure TUIWrapper_DBList.PassFileToTab(filePath: String);
var
  sFileExt: String;
begin
  sFileExt := LowerCase( ExtractFileExt( filePath ) );

  if ( sFileExt = '.gdb' ) or ( sFileExt = '.fdb' ) then
  begin
    FTreeViews[ 0 ].AddDBFileInfo( filePath );
    ChangeTab( 0 );
  end
  else if sFileExt = '.bak' then
  begin
    FTreeViews[ 1 ].AddDBFileInfo( filePath );
    ChangeTab( 1 );
  end;

end;

procedure TUIWrapper_DBList.ShowSearchOption;
begin
  FTreeViews[ FTabControl.TabIndex ].ShowSearchOption;
end;

procedure TUIWrapper_DBList.ChangeTab(index: Integer);
begin
  FTabControl.TabIndex := index;
end;

end.

