unit DAW.Tools;

interface

uses
  System.Win.Registry;

type
  TDawTools = class
    class function CompilerVersionToProduct(const AVer: single): integer;
    class function AdbExe: string;
  end;

implementation

uses
  Winapi.Windows,

  System.SysUtils;

{ TDawTools }

class function TDawTools.AdbExe: string;
const
  REG_KEY = '\Software\Embarcadero\BDS\%d.0\PlatformSDKs\';
var
  Reg: TRegistry;
  SDK_Andr: string;
  tmpVer: integer;
  tmpSdk: string;
begin
  Result := 'Cant find path :(';
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    tmpVer := CompilerVersionToProduct(CompilerVersion);
    if Reg.OpenKeyReadOnly(Format(REG_KEY, [tmpVer])) then
    begin
      tmpSdk := Reg.ReadString('Default_Android');
      if Reg.OpenKeyReadOnly(tmpSdk) then
      begin
        Result := Reg.ReadString('SDKAdbPath');
      end;
    end;
  finally
    Reg.Free;
  end;
end;

class function TDawTools.CompilerVersionToProduct(const AVer: single): integer;
begin
  if AVer < 30.0 then
    raise Exception.Create('Unsupported IDE version.');
  Result := Round(AVer) - 13;
end;

end.
