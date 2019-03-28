unit DAW.Adb.Parser;

interface

uses
  DAW.Model.Device;

type
  TdawAdbParser = class
    function parseGetDevicesOutput(const AAdbDevicesOutput: string)
      : TArray<TdawDevice>;
    function parseGetDeviceIp(const AIpInfo: string): string;
    function parseAdbServiceTcpPort(getPropOutput: string): string;
  end;

implementation

{ TdawAdbParser }

function TdawAdbParser.parseAdbServiceTcpPort(getPropOutput: string): string;
begin
  Result := getPropOutput;
end;

function TdawAdbParser.parseGetDeviceIp(const AIpInfo: string): string;
begin
  Result := AIpInfo;
end;

function TdawAdbParser.parseGetDevicesOutput(const AAdbDevicesOutput: string)
  : TArray<TdawDevice>;
begin
  Result := nil;
end;

end.
