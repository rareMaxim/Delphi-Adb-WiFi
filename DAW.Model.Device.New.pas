unit DAW.Model.Device.New;

interface

uses
  System.SysUtils;

type
{$SCOPEDENUMS ON}

  TdawDevice = class
  private
    FID: string;
    FName: string;
    FIP: string;
    FLastConnected: TDateTime;
    FIsConnected: Boolean;
    procedure SetIsConnected(const Value: Boolean);
    function GetLastConnected: TDateTime;
  public
    constructor Create(const AName, AId: string);
  published
    property ID: string read FID write FID;
    property Name: string read FName write FName;
    property IP: string read FIP write FIP;
    property LastConnected: TDateTime read GetLastConnected write FLastConnected;
    property IsConnected: Boolean read FIsConnected write SetIsConnected;
  end;

implementation

{ TdawDevice }

constructor TdawDevice.Create(const AName, AId: string);
begin
  FID := AId;
  FName := AName;
end;

function TdawDevice.GetLastConnected: TDateTime;
begin
  Result := FLastConnected;
end;

procedure TdawDevice.SetIsConnected(const Value: Boolean);
begin
  FIsConnected := Value;
  if Value then
    FLastConnected := Now;
end;

end.

