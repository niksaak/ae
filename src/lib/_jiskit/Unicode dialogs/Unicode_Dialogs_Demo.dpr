program Unicode_Dialogs_Demo;

                              {
  TOpenDialog ::
              :: Unicode  mod
  TSaveDialog ::

    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          19.08.09
                               }

uses
  Forms,
  Unicode_Dialogs_Demo_ in 'Unicode_Dialogs_Demo_.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
