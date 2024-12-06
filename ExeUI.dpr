program ExeUI;

uses
  System.StartUpCopy,
  FMX.Forms,
  androidwifiadb in 'androidwifiadb.pas',
  DAW.Adb.Parser in 'DAW.Adb.Parser.pas',
  DAW.Adb in 'DAW.Adb.pas',
  DAW.Tools in 'DAW.Tools.pas',
  DAW.Utils.DosCMD in 'DAW.Utils.DosCMD.pas',
  DAW.View.New in 'DAW.View.New.pas' {ViewAdbDialogNew},
  DAW.ViewADB in 'DAW.ViewADB.pas' {ViewAdbDialog},
  DAW.Model.Devices in 'DAW.Model.Devices.pas',
  DAW.Model.Device.New in 'DAW.Model.Device.New.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewAdbDialogNew, ViewAdbDialogNew);
  Application.Run;
end.
