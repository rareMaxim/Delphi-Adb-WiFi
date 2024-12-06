unit DAW.View.New;

interface

uses
  androidwifiadb,
  DAW.Utils.DosCmd,
  DAW.Adb.Parser,
  DAW.Tools,
  DAW.Model.Device.New,
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.Controls.Presentation, FMX.ScrollBox, DAW.Adb,
  FMX.StdCtrls;

type
  TViewAdbDialogNew = class(TForm)
    Grid1: TGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    CheckColumn1: TCheckColumn;
    Timer1: TTimer;
    Button1: TButton;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Grid1GetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure Timer1Timer(Sender: TObject);
    procedure Grid1SetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
  private
    { Private declarations }
    FAdb: TdawAdb;
    FCmd: TDosCMD;
    FAdbParser: TdawAdbParser;
    FAndroidWifiADB: TAndroidWiFiADB;
    function GetDeviceByRow(const ARow: Integer): TdawDevice;
  public
    { Public declarations }
    procedure createToolWindowContent;
    procedure ConnectDevice(ADevice: TdawDevice);
    procedure DisconnectDevice(ADevice: TdawDevice);
    procedure SetupUI;
    procedure monitorDevices;
    procedure updateUi;
  end;

var
  ViewAdbDialogNew: TViewAdbDialogNew;

implementation

{$R *.fmx}

procedure TViewAdbDialogNew.Button1Click(Sender: TObject);
begin
  monitorDevices;
end;

procedure TViewAdbDialogNew.ConnectDevice(ADevice: TdawDevice);
begin
  FAndroidWifiADB.ConnectDevice(ADevice);
  updateUi();
end;

procedure TViewAdbDialogNew.createToolWindowContent;
begin
  SetupUI();
  monitorDevices();
end;

procedure TViewAdbDialogNew.DisconnectDevice(ADevice: TdawDevice);
begin
  FAndroidWifiADB.DisconnectDevice(ADevice);
  updateUi();
end;

procedure TViewAdbDialogNew.FormCreate(Sender: TObject);
begin
  FCmd := TDosCMD.Create('', TDawTools.AdbPath);
  FAdbParser := TdawAdbParser.Create;
  FAdb := TdawAdb.Create(FCmd, FAdbParser);
  FAndroidWifiADB := TAndroidWiFiADB.Create(FAdb, TAlertService.Create);
end;

procedure TViewAdbDialogNew.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCmd);
  FreeAndNil(FAdbParser);
  FreeAndNil(FAdb);
  FreeAndNil(FAndroidWifiADB);
end;

function TViewAdbDialogNew.GetDeviceByRow(const ARow: Integer): TdawDevice;
begin
  Result := FAndroidWifiADB.getDevices[ARow];
end;

procedure TViewAdbDialogNew.Grid1GetValue(Sender: TObject;
  const ACol, ARow: Integer; var Value: TValue);
var
  LDevice: TdawDevice;
begin
  LDevice := GetDeviceByRow(ARow);
  case ACol of
    0:
      Value := LDevice.Name;
    1:
      Value := LDevice.IP;
    2, 3:
      begin
        Value := LDevice.IsConnected.ToString(TUseBoolStrs.True);
      end;
    4:
      Value := LDevice.ID;
  end;
end;

procedure TViewAdbDialogNew.Grid1SetValue(Sender: TObject;
  const ACol, ARow: Integer; const Value: TValue);
var
  LDevice: TdawDevice;
  LIsConnect: Boolean;
begin
  case ACol of
    2:
      begin
        LDevice := GetDeviceByRow(ARow);
        LIsConnect := Value.AsBoolean;
        if LIsConnect then
          ConnectDevice(LDevice)
        else
          DisconnectDevice(LDevice);
      end;
  end;

end;

procedure TViewAdbDialogNew.monitorDevices;
var
  refreshRequired: Boolean;
begin
  refreshRequired := FAndroidWifiADB.refreshDevicesList();
  if (refreshRequired) then
    updateUi();
end;

procedure TViewAdbDialogNew.SetupUI;
begin
  // cardLayoutDevices.createAndShowGUI();
end;

procedure TViewAdbDialogNew.Timer1Timer(Sender: TObject);
begin
  monitorDevices;
end;

procedure TViewAdbDialogNew.updateUi;
begin
  Grid1.RowCount := FAndroidWifiADB.getDevices.Count;
end;

end.
