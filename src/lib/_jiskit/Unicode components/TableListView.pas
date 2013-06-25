unit TableListView;

interface

uses
  Windows, Messages, Forms, Classes, Controls, ComCtrls, Menus;

type
  TTableListView = class (TListView)
  protected                   
    FColumnRightClicked: Boolean;
    FColumnPopup: TPopupMenu;

    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure ColRightClick(Column: TListColumn; Point: TPoint); override;
    procedure UpdateMenuColumns;
    procedure ColumnPopupClicked(Sender: TObject);

    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure Register;

implementation

constructor TTableListView.Create;
begin                                    
  FColumnRightClicked := False;            
  FColumnPopup := TPopupMenu.Create(Self);

  inherited
end;

destructor TTableListView.Destroy;
begin
  FColumnPopup.Free;
  inherited
end;

// ComCtrl.pas: 15559
procedure TTableListView.CMHintShow(var Message: TMessage);
var
  Item: TListItem;
  ItemRect: TRect;
  InfoTip: string;
begin
  if Assigned(OnInfoTip) then
    with TCMHintShow(Message) do
    begin
      Item := GetItemAt(2, HintInfo.CursorPos.Y);
      if Item <> nil then
      begin
        InfoTip := Item.Caption;
        DoInfoTip(Item, InfoTip);
        ItemRect := Item.DisplayRect(drBounds);
        ItemRect.TopLeft := ClientToScreen(ItemRect.TopLeft);
        ItemRect.BottomRight := ClientToScreen(ItemRect.BottomRight);
        with HintInfo^ do
        begin
          HintInfo.CursorRect := ItemRect;
          HintInfo.HintStr := InfoTip;
          HintPos := Point(ClientToScreen(CursorPos).X + 16, ItemRect.Top);
          HintInfo.HintMaxWidth := ClientWidth;
          Message.Result := 0;
        end
      end;
    end
  else
    inherited;
end;

procedure TTableListView.MouseMove;
var
  HoveredItem: TListItem;
begin
  if HotTrack then
  begin
    HoveredItem := GetItemAt(2, Y);
    if HoveredItem <> NIL then
    begin
      HoveredItem.Selected := True;
      HoveredItem.Focused := True;
      ItemIndex := HoveredItem.Index
    end
  end;

  inherited
end;

procedure TTableListView.ColRightClick;
begin
  if Columns.Count <> 0 then
  begin
    UpdateMenuColumns;
    with ClientToScreen(Point) do
      FColumnPopup.Popup(X, Y);
    FColumnRightClicked := True
  end
end;

procedure TTableListView.UpdateMenuColumns;
var
  I: Byte;
  Item: TMenuItem;
begin
  with FColumnPopup.Items do
  begin
    Clear;
    
    for I := 0 to Columns.Count - 1 do
    begin
      Item := TMenuItem.Create(FColumnPopup);

      Item.Caption := Columns[I].Caption;
      Item.AutoCheck := True;
      Item.Checked := Columns[I].Width <> 0;
      Item.OnClick := ColumnPopupClicked;

      Add(Item)
    end
  end
end;

procedure TTableListView.ColumnPopupClicked;
begin
  with Columns[ FColumnPopup.Items.IndexOf(TMenuItem(Sender)) ] do
    if Width = 0 then
      Width := Tag
      else
      begin
        Tag := Width;
        Width := 0
      end
end;

procedure TTableListView.DoContextPopup;
begin
  { right click on a column as well triggers context menu popup so we disable it. }
  Handled := FColumnRightClicked;
  if Handled then
    FColumnRightClicked := False
    else
      inherited
end;

procedure Register;
begin
  RegisterComponents('Miscellaneous', [TTableListView]);
end;

end.
