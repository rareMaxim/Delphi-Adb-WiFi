unit DAW.Adb;

interface

uses
  DAW.Model.Device,
  DAW.Utils.DosCMD,
  DAW.Adb.Parser;

type
  TdawAdb = class
  private const
    TCPIP_PORT = '5555';
  private
    FCommandLine: TDosCMD;
    FAdbParser: TdawAdbParser;
    function connectDeviceByIp(ADevice: TdawDevice): Boolean;
    function connectDevice(deviceIp: string): Boolean;
    function DisconnectDevice(ADeviceIp: string): Boolean;
    procedure enableTCPCommand();
    function checkTCPCommandExecuted: Boolean;
  public
    constructor Create(ACommandLine: TDosCMD; AAdbParser: TdawAdbParser);
    function IsInstalled: Boolean;
    function getDevicesConnectedByUSB: TArray<TdawDevice>;
    function connectDevices(ADevices: TArray<TdawDevice>): TArray<TdawDevice>;
    function disconnectDevices(ADevices: TArray<TdawDevice>)
      : TArray<TdawDevice>;

    function getDeviceIp(ADevice: TdawDevice): string;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  DAW.Tools;
{ TdawAdb }

function TdawAdb.checkTCPCommandExecuted: Boolean;
var
  getPropCommand: string;
  getPropOutput: string;
  adbTcpPort: string;
begin
  getPropCommand := 'adb shell getprop | grep adb';
  getPropOutput := FCommandLine.Execute(getPropCommand);
  adbTcpPort := FAdbParser.parseAdbServiceTcpPort(getPropOutput);
  Result := TCPIP_PORT.equals(adbTcpPort);
end;

function TdawAdb.connectDevice(deviceIp: string): Boolean;
var
  enableTCPCommand: string;
  connectDeviceCommand: string;
  connectOutput: string;
begin
  enableTCPCommand := 'adb tcpip 5555';
  FCommandLine.Execute(enableTCPCommand);
  connectDeviceCommand := 'adb connect ' + deviceIp;
  connectOutput := FCommandLine.Execute(connectDeviceCommand);
  Result := connectOutput.contains('connected');
end;

function TdawAdb.connectDeviceByIp(ADevice: TdawDevice): Boolean;
var
  deviceIp: string;
begin
  deviceIp := getDeviceIp(ADevice);
  if deviceIp.isEmpty() then
    Result := false
  else
    Result := connectDevice(deviceIp);
end;

function TdawAdb.connectDevices(ADevices: TArray<TdawDevice>)
  : TArray<TdawDevice>;
var
  LDevice: TdawDevice;
  LConnected: Boolean;
begin
  for LDevice in ADevices do
  begin
    LConnected := connectDeviceByIp(LDevice);
    LDevice.setIsConnected(LConnected);
  end;
  Result := ADevices;
end;

constructor TdawAdb.Create(ACommandLine: TDosCMD; AAdbParser: TdawAdbParser);
begin
  FCommandLine := ACommandLine;
  FAdbParser := AAdbParser;
end;

function TdawAdb.DisconnectDevice(ADeviceIp: string): Boolean;
var
  connectDeviceCommand: string;
begin
  enableTCPCommand();
  connectDeviceCommand := 'adb disconnect ' + ADeviceIp;
  Result := FCommandLine.Execute(connectDeviceCommand).isEmpty();
end;

function TdawAdb.disconnectDevices(ADevices: TArray<TdawDevice>)
  : TArray<TdawDevice>;
var
  LDevice: TdawDevice;
  LDisconnected: Boolean;
begin
  for LDevice in ADevices do
  begin
    LDisconnected := DisconnectDevice(LDevice.IP);
    LDevice.IsConnected := LDisconnected;
  end;
  Result := ADevices;
end;

procedure TdawAdb.enableTCPCommand;
var
  LEnableTCPCommand: string;
begin
  if not checkTCPCommandExecuted() then
  begin
    LEnableTCPCommand := ('adb tcpip ' + TCPIP_PORT);
    FCommandLine.Execute(LEnableTCPCommand);
  end;
end;

function TdawAdb.getDeviceIp(ADevice: TdawDevice): string;
var
  getDeviceIpCommand: string;
  ipInfoOutput: string;
begin
  getDeviceIpCommand := 'adb -s ' + ADevice.ID +
    ' shell ip -f inet addr show wlan0';
  ipInfoOutput := FCommandLine.Execute(getDeviceIpCommand);
  Result := FAdbParser.parseGetDeviceIp(ipInfoOutput);
end;

function TdawAdb.getDevicesConnectedByUSB: TArray<TdawDevice>;
var
  adbDevicesOutput: string;
begin
  adbDevicesOutput := FCommandLine.Execute('adb devices -l');
  Result := FAdbParser.parseGetDevicesOutput(adbDevicesOutput);
end;

function TdawAdb.IsInstalled: Boolean;
begin
  Result := TFile.Exists(TDawTools.AdbExe);
end;

end.
