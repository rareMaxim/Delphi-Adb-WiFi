unit DAW.Model.Devices;

interface

uses
  System.Generics.Collections,
  DAW.Model.Device.New;

type
  TdawDevices = class(TList<TdawDevice>)
  private
    function Compare(const ALeft, ARight: string): Boolean;
  public
    function IsDuplicat(const ADevice: TdawDevice): Integer;
    function ToJSON: string;
    procedure FromJSON(const AData: string);
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.JSON.Types,
  System.JSON.Serializers;
{ TdawDevices }

function TdawDevices.Compare(const ALeft, ARight: string): Boolean;
begin
  Result := not (ALeft.IsEmpty and ARight.IsEmpty);
  if Result then
    Result := ALeft = ARight;
end;

procedure TdawDevices.FromJSON(const AData: string);
var
  JS: TJsonSerializer;
  LDevices: TArray<TdawDevice>;
begin
  JS := TJsonSerializer.Create;
  try
    LDevices := JS.Deserialize<TArray<TdawDevice>>(AData);
    AddRange(LDevices);
  finally
    JS.Free;
  end;
end;

function TdawDevices.IsDuplicat(const ADevice: TdawDevice): Integer;
var
  I: Integer;
  LD: TdawDevice;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    LD := Items[I];
    if Compare(Items[I].ID, ADevice.ID) or Compare(Items[I].IP, ADevice.IP) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TdawDevices.ToJSON: string;
var
  JS: TJsonSerializer;
  LDevices: TArray<TdawDevice>;
begin
  JS := TJsonSerializer.Create;
  try
    JS.Formatting := TJsonFormatting.Indented;
    LDevices := Self.ToArray;
    Result := JS.Serialize(LDevices);
  finally
    JS.Free;
  end;

end;

end.

