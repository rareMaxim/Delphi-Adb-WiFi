unit DAW.Model.Device.New;

interface

uses
  System.SysUtils;

type
  TdawDevice = class
  private
    FID: string;
    FName: string;
    FIP: string;
    FLastConnected: TDateTime;
    FIsConnected: Boolean;
    procedure SetIsConnected(const Value: Boolean);
  published
    property ID: string read FID write FID;
    property Name: string read FName write FName;
    property IP: string read FIP write FIP;
    property LastConnected: TDateTime read FLastConnected write FLastConnected;
    property IsConnected: Boolean read FIsConnected write SetIsConnected;
  end;

implementation

{ TdawDevice }

procedure TdawDevice.SetIsConnected(const Value: Boolean);
begin
  FIsConnected := Value;
  FLastConnected := Now;
end;

end.

