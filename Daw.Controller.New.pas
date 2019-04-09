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
    procedure Connect(ADevice: TdawDevice);
    procedure Disconnect(ADevice: TdawDevice);
    function ToJSON: string;
    procedure FromJSON(const AData: string);
    destructor Destroy; override;
    property Devices: TdawDevices read FDevices write FDevices;
  end;

implementation

uses
  Daw.Tools,
  System.SysUtils,
  System.IOUtils,
  System.JSON.Types,
  System.JSON.Serializers;
{ TdawController }

procedure TdawController.Add(ADevice: TdawDevice);
begin
  FDevices.Add(ADevice);
end;

procedure TdawController.Connect(ADevice: TdawDevice);
begin
  FAdb.connectDevices([ADevice]);
end;

constructor TdawController.Create;
var
  LData: string;
begin
  FDevices := TdawDevices.Create();
  FAdbParser := TdawAdbParser.Create;
  FCmd := TDosCMD.Create('', TDawTools.AdbPath);
  FAdb := TdawAdb.Create(FCmd, FAdbParser);
  LData := TDawTools.LoadData('config');
  if not LData.IsEmpty then
    FromJSON(LData);
end;

destructor TdawController.Destroy;
begin
  TDawTools.SaveData('config', ToJSON);
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

procedure TdawController.FromJSON(const AData: string);
var
  JS: TJsonSerializer;
  LDevices: TArray<TdawDevice>;
begin
  JS := TJsonSerializer.Create;
  try
    LDevices := JS.Deserialize<TArray<TdawDevice>>(AData);
    FDevices.AddRange(LDevices);
  finally
    JS.Free;
  end;
end;

function TdawController.ToJSON: string;
var
  JS: TJsonSerializer;
  LDevices: TArray<TdawDevice>;
begin
  JS := TJsonSerializer.Create;
  try
    JS.Formatting := TJsonFormatting.Indented;
    LDevices := FDevices.ToArray;
    Result := JS.Serialize(LDevices);
  finally
    JS.Free;
  end;
end;

end.

