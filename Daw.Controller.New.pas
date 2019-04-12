unit Daw.Controller.New;

interface

uses
  Daw.Adb,
  DAW.Adb.Parser,
  DAW.Utils.DosCMD,
  DAW.Model.Device.New,
  DAW.Model.Devices;

type
  TdawController = class
  private
    FLastDevices: TdawDevices;
    FAvaibleDevices: TdawDevices;
    FAdb: TdawAdb;
    FCmd: TDosCMD;
    FAdbParser: TdawAdbParser;
  public
    constructor Create;
    function GetDosCMD: TDosCMD;
    procedure Add(ADevice: TdawDevice);
    procedure Delete(ADevice: TdawDevice);
    procedure Connect(ADevice: TdawDevice);
    procedure Disconnect(ADevice: TdawDevice);
    procedure AddConnectedInAdb;
    destructor Destroy; override;
    property LastDevices: TdawDevices read FLastDevices write FLastDevices;
    property AvaibleDevices: TdawDevices read FAvaibleDevices write FAvaibleDevices;
  end;

implementation

uses
  Daw.Tools,
  System.SysUtils;
{ TdawController }

procedure TdawController.Add(ADevice: TdawDevice);
var
  x: Integer;
begin
  x := FLastDevices.IsDuplicat(ADevice);
  if x > -1 then
  begin
    FAdb.Upgrade(ADevice);
    FLastDevices[x] := ADevice;
  end
  else
  begin
    FAdb.Upgrade(ADevice);
    FLastDevices.Add(ADevice);
  end;
end;

procedure TdawController.AddConnectedInAdb;
var
  LFromAdb: TArray<TdawDevice>;
begin
  FAvaibleDevices.Clear;
  LFromAdb := FAdb.getDevicesConnectedByUSB;
  FAvaibleDevices.AddRange(LFromAdb);
end;

procedure TdawController.Connect(ADevice: TdawDevice);
begin
  FAdb.connectDevices([ADevice]);
end;

constructor TdawController.Create;
var
  LDevices: string;
begin
  FLastDevices := TdawDevices.Create();
  FAvaibleDevices := TdawDevices.Create();
  FAdbParser := TdawAdbParser.Create;
  FCmd := TDosCMD.Create('', TDawTools.AdbPath);
  FAdb := TdawAdb.Create(FCmd, FAdbParser);
  LDevices := TDawTools.LoadData('devices');
  if not LDevices.IsEmpty then
    FLastDevices.FromJSON(LDevices);
end;

procedure TdawController.Delete(ADevice: TdawDevice);
begin
  FLastDevices.Remove(ADevice);
end;

destructor TdawController.Destroy;
begin
  TDawTools.SaveData('devices', FLastDevices.ToJSON);
  FAvaibleDevices.Free;
  FLastDevices.Free;
  inherited;
end;

procedure TdawController.Disconnect(ADevice: TdawDevice);
begin
  FAdb.disconnectDevices([ADevice]);
end;

function TdawController.GetDosCMD: TDosCMD;
begin
  Result := FCmd;
end;

end.

