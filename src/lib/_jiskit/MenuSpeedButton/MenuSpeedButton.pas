unit MenuSpeedButton;

interface

uses
  SysUtils, Classes, Controls, Buttons, Menus;

type
  TMenuSpeedButton = class (TSpeedButton)
  protected
    FMenu: TPopupMenu;
    FShowUnderControl: TControl;

    procedure Click; override;
    procedure Clicked;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property PopupMenu: TPopupMenu read FMenu write FMenu;
    property ShowUnderControl: TControl read FShowUnderControl write FShowUnderControl;
  end;

procedure Register;

implementation

constructor TMenuSpeedButton.Create;
begin               
  inherited;
   
  FMenu := NIL;
  FShowUnderControl := NIL
end;

// Coltrols.pas: 4695
procedure TMenuSpeedButton.Click;
begin
  if not (csDesigning in ComponentState) and (ActionLink <> nil) then
    ActionLink.Execute(Self)
  else
    Clicked
end;

procedure TMenuSpeedButton.Clicked;
begin
  if Assigned(OnClick) and ((Action = NIL) or (@OnClick <> @Action.OnExecute)) then
    OnClick(Self);

  if FMenu <> NIL then
    if ShowUnderControl = NIL then
      with ClientToScreen(Point(0, Height)) do
        FMenu.Popup(X, Y)
      else
        with ShowUnderControl, ClientToScreen(Point(0, Height)) do
          FMenu.Popup(X, Y)
end;

procedure Register;
begin
  RegisterComponents('JISKit', [TMenuSpeedButton]);
end;

end.
