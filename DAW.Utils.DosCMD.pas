unit DAW.Utils.DosCMD;

interface

uses
  System.SysUtils;

type
  TDosCMD = class
  private
    FWorkDir: string;
    FCommandLine: string;
    FOnExecute: TProc<string>;
    procedure DoOnExecute(const AData: string);
  public
    function Execute: string; overload;
    function Execute(const ACommandLine: string): string; overload;
    function Execute(const ACommandLine, AWork: string): string; overload;
    constructor Create(const ACommandLine, AWorkDir: string);
    property WorkDir: string read FWorkDir write FWorkDir;
    property CommandLine: string read FCommandLine write FCommandLine;
    property OnExecute: TProc<string> read FOnExecute write FOnExecute;
  end;

implementation

uses
  Winapi.Windows;

{ TDosCMD }

function TDosCMD.Execute: string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  Handle: Boolean;
begin
  Result := '';
  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + FCommandLine), nil, nil,
      True, 0, nil, PChar(FWorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if Handle then
    try
      repeat
        WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
        if BytesRead > 0 then
        begin
          Buffer[BytesRead] := #0;
          Result := Result + Buffer;
        end;
      until not WasOK or (BytesRead = 0);
      WaitForSingleObject(PI.hProcess, INFINITE);
    finally
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);
    end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
  DoOnExecute(Result);
end;

constructor TDosCMD.Create(const ACommandLine, AWorkDir: string);
begin
  FWorkDir := AWorkDir;
  FCommandLine := ACommandLine;
end;

procedure TDosCMD.DoOnExecute(const AData: string);
begin
  if Assigned(OnExecute) then
    OnExecute(AData);
end;

function TDosCMD.Execute(const ACommandLine, AWork: string): string;
begin
  FWorkDir := AWork;
  FCommandLine := ACommandLine;
  Result := Execute;
end;

function TDosCMD.Execute(const ACommandLine: string): string;
begin
  FCommandLine := ACommandLine;
  Result := Execute;
end;

end.

