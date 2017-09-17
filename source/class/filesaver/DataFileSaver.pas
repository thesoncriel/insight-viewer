unit DataFileSaver;

interface

uses
  DB, Classes;

type

  IDataSetIterator = Interface(IInterface)
  ['{17D34503-AE5E-468F-85BE-1AFA95C4EE16}']
      function MoveNext(): Boolean;
      function CurData(): TDataSet;
      function CurName(): String;
      function Count(): Integer;
      procedure MoveFirst;
  End;


  TAbsFileSaver = class(TObject)
    public
      function SaveTo(data: TDataSet; filePath: String): Boolean; overload; virtual; abstract;
      function SaveTo(dataIter: IDataSetIterator; dirPath: String): Integer; overload; virtual; abstract;
  end;

  TCsvSaver = class(TAbsFileSaver)
    public
      function SaveTo(data: TDataSet; filePath: String): Boolean; overload;
      function SaveTo(dataIter: IDataSetIterator; dirPath: String): Integer; overload;
  end;



implementation

uses
  System.SysUtils, Windows;




{ TCsvSaver }

function TCsvSaver.SaveTo(data: TDataSet; filePath: String): Boolean;
begin
  result := true;
end;

function TCsvSaver.SaveTo(dataIter: IDataSetIterator; dirPath: String): Integer;
begin
  result := 0;
end;

end.
