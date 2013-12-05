unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Process_control, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    pc : TProcessControl;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var list : TStringList;
    i : longword;
begin
  if pc = nil then pc := TProcessControl.Create;
  pc.Refresh;
  list := TStringList.Create;
  pc.GetProcessList(list);
  for i := 0 to list.Count-1 do
  begin
    ListBox1.Items.Add(list[i]);
  end;
  list.Destroy;
end;

procedure TForm1.Button2Click(Sender: TObject);
var stream : TStream;
    i : longword;
begin
  for i := 0 to ListBox1.Count-1 do
  begin
    if ListBox1.Selected[i] then
    begin
      pc.ReadMemory(i,$401000,$1000,stream);
      Break;
    end;
  end;
end;

end.
