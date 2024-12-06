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
    function Execute(const ACommandLine: string; const Args: array of const): string; overload;
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
  SecurityAttributes: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  StdOutRead, StdOutWrite: THandle;
  WasOK: Boolean;
  Buffer: array [0 .. 1023] of AnsiChar;
  BytesRead: DWORD;
  Handle: Boolean;
begin
  Result := '';
  with SecurityAttributes do
  begin
    nLength := SizeOf(SecurityAttributes);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutRead, StdOutWrite, @SecurityAttributes, 0);
  try
    with StartupInfo do
    begin
      FillChar(StartupInfo, SizeOf(StartupInfo), 0);
      cb := SizeOf(StartupInfo);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutWrite;
      hStdError := StdOutWrite;
    end;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + FCommandLine), nil, nil, True, 0, nil, PChar(FWorkDir), StartupInfo,
      ProcessInfo);
    CloseHandle(StdOutWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            Result := Result + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      finally
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(ProcessInfo.hProcess);
      end;
  finally
    CloseHandle(StdOutRead);
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

function TDosCMD.Execute(const ACommandLine: string; const Args: array of const): string;
begin
  Result := Execute(Format(ACommandLine, Args));
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
