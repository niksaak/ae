program JReconvertor_Demo;

                              {

  JReconvertor encodings unit


    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          20.06.09
                              }

uses
  Forms,
  JReconvertor_Demo_ in 'JReconvertor_Demo_.pas' {Form1},
  JReconvertor in 'JReconvertor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.