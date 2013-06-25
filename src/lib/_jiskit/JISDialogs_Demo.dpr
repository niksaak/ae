program JISDialogs_Demo;

                              {
  TOpenDialog ::
              :: ShiftJIS mod
  TSaveDialog ::
  
    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          19.06.09
                               }

uses
  Forms,
  JISDialogs_Demo_ in 'JISDialogs_Demo_.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
