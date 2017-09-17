unit UIWrapper_StageGridUnit;

interface

uses
  FMX.TabControl, FMX.Grid, FMX.Types, Classes, DB, Data.Bind.DBScope,
  Fmx.Bind.DBLinks;
type
  TUIWrapper_StageGrid = class(TTabItem)
    private
      FGrid: TStringGrid;
      FBind: TBindScopeDB;
      FDataSource: TDataSource;
      FLiveBind: TBindDBGridLink;
    public
      constructor Create(owner: TComponent); override;
      destructor Destroy; override;
      procedure SetTitle(title: String);
      procedure SetData(data: TDataSet);
      function GetData: TDataSet;
      procedure Clear;
      procedure AutoColumnSize;
  end;
implementation

uses
  Windows, FMX.Dialogs, System.SysUtils;

{ TUIWrapper_StageGrid }

procedure TUIWrapper_StageGrid.Clear;
begin
  if FDataSource.DataSet <> nil then FDataSource.DataSet.Free;
end;

constructor TUIWrapper_StageGrid.Create(owner: TComponent);
begin
  inherited;
  FGrid := TStringGrid.Create( nil );
  FDataSource := TDataSource.Create( nil );
  FBind := TBindScopeDB.Create( nil );
  FLiveBind := TBindDBGridLink.Create( nil );

  FGrid.Align := TAlignLayout.alClient;
  FGrid.AlternatingRowBackground := true;
  FBind.DataSource := FDataSource;
  FLiveBind.DataSource := FBind;
  FLiveBind.GridControl := FGrid;

  self.AddObject( FGrid );
  self.Width := 120;
end;

destructor TUIWrapper_StageGrid.Destroy;
begin
  Clear;
  FDataSource.Free;
  FBind.Free;
  FLiveBind.Free;
  FGrid.Free;
  inherited;
end;

function TUIWrapper_StageGrid.GetData: TDataSet;
begin
  result := FDataSource.DataSet;
end;

procedure TUIWrapper_StageGrid.SetData(data: TDataSet);
begin
  FDataSource.DataSet := data;
end;

procedure TUIWrapper_StageGrid.SetTitle(title: String);
begin
  self.Text := title;
end;

procedure TUIWrapper_StageGrid.AutoColumnSize;
var
  I: Integer;
  J: Integer;
  maxCol: Array of Integer;
  w: Integer;
begin
  SetLength( maxCol, FGrid.ColumnCount );
  for I := 0 to High( maxCol ) do
  begin
    maxCol[ I ] := 0;
  end;

  for I := 0 to FGrid.RowCount - 1 do
  begin
    for J := 0 to FGrid.ColumnCount - 1 do
    begin
      w := Round( FGrid.Canvas.TextWidth( FGrid.Cells[ J, I ] ) );
      if w > maxCol[ J ] then maxCol[ J ] := w;

    end;
  end;

  for I := 0 to High( maxCol ) do
  begin
    FGrid.Columns[ I ].Width := maxCol[ I ] + 12;
  end;
end;

end.
