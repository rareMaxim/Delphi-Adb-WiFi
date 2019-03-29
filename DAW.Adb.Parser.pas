unit DAW.Adb.Parser;

interface

uses
  DAW.Model.Device;

type
  TdawAdbParser = class
  private
    function parseDeviceName(const ALine: string): string;
  public
    function parseGetDevicesOutput(const AAdbDevicesOutput: string)
      : TArray<TdawDevice>;
    function parseGetDeviceIp(const AIpInfo: string): string;
    function parseAdbServiceTcpPort(getPropOutput: string): string;
  end;

implementation

uses
  DAW.Tools,
  System.SysUtils,
  System.Generics.Collections;

{ TdawAdbParser }

function TdawAdbParser.parseAdbServiceTcpPort(getPropOutput: string): string;

begin

end;

function TdawAdbParser.parseDeviceName(const ALine: string): string;
const
  MODEL_INDICATOR = 'model:';
  DEVICE_INDICATOR = 'device:';
var
  LData: TArray<string>;
begin
  LData := TDawTools.GetInTag(ALine, MODEL_INDICATOR, DEVICE_INDICATOR);
  if Length(LData) > 0 then
    Result := LData[0];
end;

function TdawAdbParser.parseGetDeviceIp(const AIpInfo: string): string;
const
  START_DEVICE_IP_INDICATOR = 'inet ';
  END_DEVICE_IP_INDICATOR = '/';
var
  LData: TArray<string>;
begin
  LData := TDawTools.GetInTag(AIpInfo, START_DEVICE_IP_INDICATOR,
    END_DEVICE_IP_INDICATOR);
  if Length(LData) > 0 then
    Result := LData[0];
end;

function TdawAdbParser.parseGetDevicesOutput(const AAdbDevicesOutput: string)
  : TArray<TdawDevice>;
var
  LDevices: TList<TdawDevice>;
  splittedOutput: TArray<string>;
  i: integer;
  line: string;
  deviceLine: TArray<string>;
  id: string;
  name: string;
  Device: TdawDevice;
begin
  // 'List of devices attached'#$D#$A'0123456789ABCDEF       device product:havoc_santoni model:Redmi_4X device:santoni transport_id:1'#$D#$A#$D#$A
  Result := nil;
  if AAdbDevicesOutput.contains('daemon') then
    Exit(nil);
  splittedOutput := AAdbDevicesOutput.Split([#$D#$A],
    TStringSplitOptions.ExcludeEmpty);
  if Length(splittedOutput) <= 1 then
    Exit(nil);
  LDevices := TList<TdawDevice>.Create();
  try
    for i := 1 to High(splittedOutput) do
    begin
      line := splittedOutput[i];
      deviceLine := line.Split([' '], TStringSplitOptions.ExcludeEmpty);
      id := deviceLine[0];
      if (id.contains('.')) then
        continue;
      name := parseDeviceName(line);
      Device := TdawDevice.Create(name, id);
      LDevices.add(Device);
    end;
    Result := LDevices.ToArray;
  finally
    LDevices.Free;
  end;
end;

end.
