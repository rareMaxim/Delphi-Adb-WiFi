unit DAW.Tools;

interface

uses
  System.Win.Registry;

type
  TDawTools = class
  private
    class var FAdbExe: string;
    class function ReadFromRegAdbExe: string;
  public
    class function CompilerVersionToProduct(const AVer: single): integer;
    class function AdbExe: string;
    class function AdbPath: string;
  end;

implementation

uses
  Winapi.Windows,

  System.SysUtils;

{ TDawTools }

class function TDawTools.AdbExe: string;
begin
  if not FileExists(FAdbExe) then
    FAdbExe := ReadFromRegAdbExe;
  Result := FAdbExe;
end;

class function TDawTools.AdbPath: string;
begin
  Result := ExtractFilePath(AdbExe);
end;

class function TDawTools.CompilerVersionToProduct(const AVer: single): integer;
begin
  if AVer < 30.0 then
    raise Exception.Create('Unsupported IDE version.');
  Result := Round(AVer) - 13;
end;

class function TDawTools.ReadFromRegAdbExe: string;
const
  REG_KEY = '\Software\Embarcadero\BDS\%d.0\PlatformSDKs\';
var
  Reg: TRegistry;
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

end.
