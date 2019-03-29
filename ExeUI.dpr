program ExeUI;

uses
  System.StartUpCopy,
  FMX.Forms,
  androidwifiadb in 'androidwifiadb.pas',
  DAW.Adb.Parser in 'DAW.Adb.Parser.pas',
  DAW.Adb in 'DAW.Adb.pas',
  DAW.Model.Device in 'DAW.Model.Device.pas',
  DAW.Tools in 'DAW.Tools.pas',
  DAW.Utils.DosCMD in 'DAW.Utils.DosCMD.pas',
  DAW.View.New in 'DAW.View.New.pas' {ViewAdbDialogNew},
  DAW.ViewADB in 'DAW.ViewADB.pas' {ViewAdbDialog};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewAdbDialogNew, ViewAdbDialogNew);
  Application.Run;
end.
