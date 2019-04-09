unit DAW.Model.Device.New;

interface

uses
  System.SysUtils;

type
{$SCOPEDENUMS ON}

  TDawConnectionType = (Unknown, USB, WiFi);

  TdawDevice = class
  private
    FID: string;
    FName: string;
    FIP: string;
    FLastConnected: TDateTime;
    FIsConnected: Boolean;
    FConnectionType: TDawConnectionType;
    procedure SetIsConnected(const Value: Boolean);
    function GetLastConnected: TDateTime;
  public
    constructor Create(const AName, AId: string);
    function GetConnectionType: TDawConnectionType;
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

function TdawDevice.GetConnectionType: TDawConnectionType;
begin
  if ID.IsEmpty then
    Result := TDawConnectionType.Unknown
  else if ID = IP then
    Result := TDawConnectionType.WIFI
  else
    Result := TDawConnectionType.USB;
end;

function TdawDevice.GetLastConnected: TDateTime;
begin
  if GetConnectionType = TDawConnectionType.USB then
    FLastConnected := Now;
  Result := FLastConnected;
end;

procedure TdawDevice.SetIsConnected(const Value: Boolean);
begin
  FIsConnected := Value;
  if Value then
    FLastConnected := Now;
end;

end.

