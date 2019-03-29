unit androidwifiadb;

interface

uses
  DAW.Model.Device,
  System.Generics.Collections,
  DAW.Adb;

type
  IdawView = interface
    ['{1900284A-C00D-423E-9488-C7D32C06919C}']
    procedure showNoConnectedDevicesNotification();
    procedure showConnectedDeviceNotification(ADevice: TdawDevice);
    procedure showDisconnectedDeviceNotification(ADevice: TdawDevice);
    procedure showErrorConnectingDeviceNotification(ADevice: TdawDevice);
    procedure showErrorDisconnectingDeviceNotification(ADevice: TdawDevice);
    procedure showADBNotInstalledNotification();
  end;

  TAlertService = class(TInterfacedObject, IdawView)
    procedure showNoConnectedDevicesNotification();
    procedure showConnectedDeviceNotification(ADevice: TdawDevice);
    procedure showDisconnectedDeviceNotification(ADevice: TdawDevice);
    procedure showErrorConnectingDeviceNotification(ADevice: TdawDevice);
    procedure showErrorDisconnectingDeviceNotification(ADevice: TdawDevice);
    procedure showADBNotInstalledNotification();
  end;

  TAndroidWiFiADB = class
  private
    FAdb: TdawAdb;
    FView: IdawView;
    FDevices: TList<TdawDevice>;
    function checkDeviceExistance(connectedDevice: TdawDevice): boolean;
    procedure showConnectionResultNotification(Adevices: TArray<TdawDevice>);
    procedure showDisconnectionResultNotification(Adevices: TArray<TdawDevice>);
  public
    procedure removeNotConnectedDevices;
    function isADBInstalled: boolean;
    function refreshDevicesList: boolean;
    procedure connectDevices;
    procedure connectDevice(Device: TdawDevice);
    procedure disconnectDevice(Device: TdawDevice);
    constructor Create(AAdb: TdawAdb; AView: IdawView);
    destructor Destroy; override;
    function getDevices: TList<TdawDevice>;
  end;

implementation

uses System.SysUtils;
{ TAndroidWiFiADB }

function TAndroidWiFiADB.checkDeviceExistance(connectedDevice
  : TdawDevice): boolean;
var
  LDevice: TdawDevice;
begin
  Result := False;
  for LDevice in FDevices do
    if connectedDevice.ID.Equals(LDevice.ID) then
      Exit(True);
end;

procedure TAndroidWiFiADB.connectDevice(Device: TdawDevice);
var
  connectedDevices: TList<TdawDevice>;
  LDevice: TdawDevice;
begin
  if not(isADBInstalled()) then
  begin
    FView.showADBNotInstalledNotification();
    Exit;
  end;
  connectedDevices := TList<TdawDevice>.Create;
  try
    connectedDevices.AddRange(FAdb.connectDevices([Device]));
    for LDevice in connectedDevices do
      FDevices.Add(LDevice);
    showConnectionResultNotification(connectedDevices.ToArray);
  finally
    connectedDevices.Free;
  end;

end;

procedure TAndroidWiFiADB.connectDevices;
begin
  if not isADBInstalled() then
  begin
    FView.showADBNotInstalledNotification();
    Exit;
  end;
  FDevices.clear();
  FDevices.AddRange(FAdb.getDevicesConnectedByUSB());
  if (FDevices.Count = 0) then
  begin
    FView.showNoConnectedDevicesNotification();
    Exit;
  end;

  FDevices.AddRange(FAdb.connectDevices(FDevices.ToArray));
  showConnectionResultNotification(FDevices.ToArray);
end;

constructor TAndroidWiFiADB.Create(AAdb: TdawAdb; AView: IdawView);
begin
  FDevices := TList<TdawDevice>.Create;
  FAdb := AAdb;
  FView := AView;
end;

destructor TAndroidWiFiADB.Destroy;
begin
  FDevices.Free;
  inherited;
end;

procedure TAndroidWiFiADB.disconnectDevice(Device: TdawDevice);
var
  disconnectedDevices: TList<TdawDevice>;
  LDevice: TdawDevice;
begin
  if not(isADBInstalled()) then
  begin
    FView.showADBNotInstalledNotification();
    Exit;
  end;
  disconnectedDevices := TList<TdawDevice>.Create;
  try
    disconnectedDevices.AddRange(FAdb.disconnectDevices([Device]));
    for LDevice in disconnectedDevices do
      FDevices.Add(LDevice);
    showDisconnectionResultNotification(disconnectedDevices.ToArray);
  finally
    disconnectedDevices.Free;
  end;
end;

function TAndroidWiFiADB.getDevices: TList<TdawDevice>;
begin
  Result := FDevices;
end;

function TAndroidWiFiADB.isADBInstalled: boolean;
begin
  Result := FAdb.IsInstalled;
end;

function TAndroidWiFiADB.refreshDevicesList: boolean;
var
  Lconnected: TArray<TdawDevice>;
  LconnectedDevice: TdawDevice;
begin
  if not isADBInstalled() then
  begin
    Exit(False);
  end;
  removeNotConnectedDevices();
  Lconnected := FAdb.getDevicesConnectedByUSB();
  for LconnectedDevice in Lconnected do
  begin
    if not checkDeviceExistance(LconnectedDevice) then
    begin
      LconnectedDevice.setIp(FAdb.getDeviceIp(LconnectedDevice));
      FDevices.Add(LconnectedDevice);
    end
    else
    begin
      FDevices.Add(LconnectedDevice);
    end;
  end;
  Result := True;
end;

procedure TAndroidWiFiADB.removeNotConnectedDevices;
var
  connectedDevices: TList<TdawDevice>;
  LDevice: TdawDevice;
begin
  connectedDevices := TList<TdawDevice>.Create();
  try
    for LDevice in FDevices do
    begin
      if LDevice.IsConnected then
        connectedDevices.Add(LDevice);
    end;
    FDevices.clear();
    FDevices.AddRange(connectedDevices);
  finally
    connectedDevices.Free;
  end;
end;

procedure TAndroidWiFiADB.showConnectionResultNotification
  (Adevices: TArray<TdawDevice>);
var
  LDevice: TdawDevice;
begin
  for LDevice in Adevices do
  begin
    if LDevice.IsConnected then
      FView.showConnectedDeviceNotification(LDevice)
    else
      FView.showErrorConnectingDeviceNotification(LDevice);
  end;
end;

procedure TAndroidWiFiADB.showDisconnectionResultNotification
  (Adevices: TArray<TdawDevice>);
var
  LDevice: TdawDevice;
begin
  for LDevice in Adevices do
  begin
    if not LDevice.IsConnected then
      FView.showDisconnectedDeviceNotification(LDevice)
    else
      FView.showErrorDisconnectingDeviceNotification(LDevice);
  end;

end;

{ TAlertService }

procedure TAlertService.showADBNotInstalledNotification;
begin

end;

procedure TAlertService.showConnectedDeviceNotification(ADevice: TdawDevice);
begin

end;

procedure TAlertService.showDisconnectedDeviceNotification(ADevice: TdawDevice);
begin

end;

procedure TAlertService.showErrorConnectingDeviceNotification(
  ADevice: TdawDevice);
begin

end;

procedure TAlertService.showErrorDisconnectingDeviceNotification(
  ADevice: TdawDevice);
begin

end;

procedure TAlertService.showNoConnectedDevicesNotification;
begin

end;

end.
