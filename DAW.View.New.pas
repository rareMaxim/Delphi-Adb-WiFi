unit DAW.View.New;

interface

uses
  androidwifiadb,
  DAW.Utils.DosCmd,
  DAW.Adb.Parser,
  DAW.Tools,
  DAW.Model.Device,
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
    procedure UpdateGrid;
  end;

var
  ViewAdbDialogNew: TViewAdbDialogNew;

implementation

{$R *.fmx}

procedure TViewAdbDialogNew.Button1Click(Sender: TObject);
begin
  UpdateGrid;
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
        Value := LDevice.GetIsConnected.ToString(TUseBoolStrs.True);
      end;
  end;
end;

procedure TViewAdbDialogNew.Grid1SetValue(Sender: TObject;
  const ACol, ARow: Integer; const Value: TValue);
var
  LDevice: TdawDevice;
begin
  case ACol of
    2:
      begin
        LDevice := GetDeviceByRow(ARow);
        FAndroidWifiADB.connectDevice(LDevice);
      end;
  end;

end;

procedure TViewAdbDialogNew.Timer1Timer(Sender: TObject);
begin
  UpdateGrid;
end;

procedure TViewAdbDialogNew.UpdateGrid;
begin
  //
  FAndroidWifiADB.refreshDevicesList;
  Grid1.RowCount := FAndroidWifiADB.getDevices.Count;
end;

end.
