program DelphiAdbWifiExe;

uses
  System.StartUpCopy,
  FMX.Forms,
  DAW.View.Main in 'DAW.View.Main.pas' {Form2},
  DAW.Model.Device.New in 'DAW.Model.Device.New.pas',
  Daw.Controller.New in 'Daw.Controller.New.pas',
  DAW.Model.Devices in 'DAW.Model.Devices.pas',
  DAW.View.DeviceEdit in 'DAW.View.DeviceEdit.pas' {ViewDeviceEdit},
  DAW.Adb.Parser in 'DAW.Adb.Parser.pas',
  DAW.Adb in 'DAW.Adb.pas',
  DAW.Tools in 'DAW.Tools.pas',
  DAW.Utils.DosCMD in 'DAW.Utils.DosCMD.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TViewDeviceEdit, ViewDeviceEdit);
  Application.Run;
end.
