unit Daw.Controller.New;

interface

uses
  Daw.Adb,
  Daw.Adb.Parser,
  Daw.Utils.DosCMD,
  Daw.Model.Device.New,
  Daw.Model.Devices;

type
  TdawController = class
  private
    FDevices: TdawDevices;
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
    property Devices: TdawDevices read FDevices write FDevices;
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
  x := FDevices.IsDuplicat(ADevice);
  if x > -1 then
  begin
    FAdb.Upgrade(ADevice);
    FDevices[x] := ADevice;
  end
  else
  begin
    FAdb.Upgrade(ADevice);
    FDevices.Add(ADevice);
  end;
end;

procedure TdawController.AddConnectedInAdb;
var
  LFromAdb: TArray<TdawDevice>;
  LDevice: TdawDevice;
  LFinded: TdawDevice;
begin
  LFromAdb := FAdb.getDevicesConnectedByUSB;
  for LDevice in LFromAdb do
  begin
    Add(LDevice);
  end;
end;

procedure TdawController.Connect(ADevice: TdawDevice);
begin
  FAdb.connectDevices([ADevice]);
end;

constructor TdawController.Create;
var
  LDevices: string;
begin
  FDevices := TdawDevices.Create();
  FAdbParser := TdawAdbParser.Create;
  FCmd := TDosCMD.Create('', TDawTools.AdbPath);
  FAdb := TdawAdb.Create(FCmd, FAdbParser);
  LDevices := TDawTools.LoadData('devices');
  if not LDevices.IsEmpty then
    FDevices.FromJSON(LDevices);
end;

procedure TdawController.Delete(ADevice: TdawDevice);
begin
  FDevices.Remove(ADevice);
end;

destructor TdawController.Destroy;
begin
  TDawTools.SaveData('devices', FDevices.ToJSON);
  FDevices.Free;
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

