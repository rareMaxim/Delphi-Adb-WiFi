unit DAW.Model.Device;

interface

type
  TdawDevice = class
  private
    FID: string;
    FName: string;
    FIP: string;
    FIsConnected: Boolean;
  public
    constructor Create(const AName, AID: string);
  published
    property ID: string read FID write FID;
    property Name: string read FName write FName;
    property IP: string read FIP write FIP;
    property IsConnected: Boolean read FIsConnected write FIsConnected;
  end;

implementation

{ TdawDevice }

constructor TdawDevice.Create(const AName, AID: string);
begin
  Self.FID := AID;
  Self.FName := AName;
end;

end.
