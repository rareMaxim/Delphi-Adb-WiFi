unit DAW.Tools;

interface

uses
  System.Win.Registry;

type
  TDawTools = class
  private
    class var
      FAdbExe: string;
    class function ReadFromRegAdbExe: string;
  public
    class function CompilerVersionToProduct(const AVer: Single): Integer;
    class function AdbExe: string;
    class function AdbPath: string;
    class function GetInTag(AInput, AStartTag, AEndTag: string): TArray<string>;
    class procedure SaveData(const AName, AValue: string);
    class function LoadData(const AName: string): string;
  end;

implementation

uses
  Winapi.Windows,
  System.Generics.Collections,
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

class function TDawTools.CompilerVersionToProduct(const AVer: Single): Integer;
begin
  if AVer < 30.0 then
    raise Exception.Create('Unsupported IDE version.');
  Result := Round(AVer) - 13;
end;

class function TDawTools.GetInTag(AInput, AStartTag, AEndTag: string): TArray<string>;
var
  LData: TList<string>;
  LInpCash: string;
var
  start: Integer;
  count: Integer;
  ForAdd: string;
begin
  LInpCash := AInput;
  LData := TList<string>.Create;
  try
    while not LInpCash.IsEmpty do
    begin
      start := LInpCash.indexOf(AStartTag); // + ;
      if start < 0 then
        Break;
      Inc(start, AStartTag.Length);
      LInpCash := LInpCash.Substring(start);
      count := LInpCash.indexOf(AEndTag);
      if (count < 0) then
        count := LInpCash.Length;
      ForAdd := LInpCash.Substring(0, count);
      LData.Add(ForAdd);
      LInpCash := LInpCash.Substring(count);
    end;
    Result := LData.ToArray;
  finally
    LData.Free;
  end;
end;

class function TDawTools.LoadData(const AName: string): string;
const
  REG_KEY = '\Software\rareMax\DAW\';
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(REG_KEY, False) then
      Result := Reg.ReadString(AName);
  finally
    Reg.Free;
  end;
end;

class function TDawTools.ReadFromRegAdbExe: string;
const
  REG_KEY = '\Software\Embarcadero\BDS\%d.0\PlatformSDKs\';
var
  Reg: TRegistry;
  tmpVer: Integer;
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

class procedure TDawTools.SaveData(const AName, AValue: string);
const
  REG_KEY = '\Software\rareMax\DAW\';
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(REG_KEY, True) then
      Reg.WriteString(AName, AValue);
  finally
    Reg.Free;
  end;
end;

end.

