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
    FDevices: TdawDevices;
    FAdb: TdawAdb;
    FCmd: TDosCMD;
    FAdbParser: TdawAdbParser;
  public
    constructor Create;
    function GetDosCMD: TDosCMD;
    procedure Add(ADevice: TdawDevice);
    procedure Connect(ADevice: TdawDevice);
    procedure SaveToJSON(const AFileName: string);
    procedure LoadFromJSON(const AFileName: string);
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
begin
  FDevices := TdawDevices.Create();
  FAdbParser := TdawAdbParser.Create;
  FCmd := TDosCMD.Create('', TDawTools.AdbPath);
  FAdb := TdawAdb.Create(FCmd, FAdbParser);
  LoadFromJSON('C:\Users\maks4\Desktop\config.json');
end;

destructor TdawController.Destroy;
begin
  SaveToJSON('C:\Users\maks4\Desktop\config.json');
  FDevices.Free;
  inherited;
end;

function TdawController.GetDosCMD: TDosCMD;
begin
  Result := FCmd;
end;

procedure TdawController.LoadFromJSON(const AFileName: string);
var
  JS: TJsonSerializer;
  LJson: string;
  LDevices: TArray<TdawDevice>;
begin
  JS := TJsonSerializer.Create;
  try
    LJson := TFile.ReadAllText(AFileName);
    LDevices := JS.Deserialize<TArray<TdawDevice>>(LJson);
    FDevices.AddRange(LDevices);
  finally
    JS.Free;
  end;
end;

procedure TdawController.SaveToJSON(const AFileName: string);
var
  JS: TJsonSerializer;
  LJson: string;
  LDevices: TArray<TdawDevice>;
begin
  JS := TJsonSerializer.Create;
  try
    JS.Formatting := TJsonFormatting.Indented;
    LDevices := FDevices.ToArray;
    LJson := JS.Serialize(LDevices);
    TFile.WriteAllText(AFileName, LJson);
  finally
    JS.Free;
  end;
end;

end.

