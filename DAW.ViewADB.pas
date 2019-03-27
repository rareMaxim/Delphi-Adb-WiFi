unit DAW.ViewADB;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.ScrollBox,
  FMX.Memo;

type
  TViewAdbDialog = class(TForm)
    lytAdbExe: TLayout;
    lblAdbExe: TLabel;
    edtAdbExe: TEdit;
    lytDeviceIp: TLayout;
    lblDeviceIp: TLabel;
    edtDeviceIp: TEdit;
    grpLog: TGroupBox;
    mmoLog: TMemo;
    btnConnect: TEditButton;
    btnBrowse: TEditButton;
    lytExec: TLayout;
    lblExec: TLabel;
    edtExec: TEdit;
    btnExec: TEditButton;
    procedure btnConnectClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnExecClick(Sender: TObject);
  private
    { Private declarations }
    FDir: string;
  public
    { Public declarations }
    procedure Log(const AData: string);
    class function GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;
    function SetupDir: Boolean;
    procedure CheckResult(const Msg: string);
    procedure ADBExecute(const ACmd: string);
  end;

var
  ViewAdbDialog: TViewAdbDialog;

implementation

uses
  DAW.Tools,
  Winapi.Windows;

{$R *.fmx}
{ TViewAdbDialog }

procedure TViewAdbDialog.ADBExecute(const ACmd: string);
begin
  CheckResult(GetDosOutput(ACmd, FDir));
end;

procedure TViewAdbDialog.btnBrowseClick(Sender: TObject);
var
  OD: TOpenDialog;
begin
  OD := TOpenDialog.Create(nil);
  try
    OD.DefaultExt := 'adb.exe';
    if OD.Execute then
      edtAdbExe.Text := OD.FileName;
    SetupDir;
  finally
    OD.Free;
  end;
end;

procedure TViewAdbDialog.btnConnectClick(Sender: TObject);
begin
  if SetupDir then
  begin
    CheckResult(GetDosOutput('adb kill-server', FDir));
    CheckResult(GetDosOutput('adb tcpip 5555', FDir));
    CheckResult(GetDosOutput('adb connect ' + edtDeviceIp.Text, FDir));
  end;
end;

procedure TViewAdbDialog.btnExecClick(Sender: TObject);
begin
  ADBExecute(edtExec.Text);
end;

procedure TViewAdbDialog.CheckResult(const Msg: string);
begin
  if Msg.Contains('adb: usage: adb connect <host>[:<port>]') then
  begin
    Log('Unsupperted format IP. Check settings');
  end
  else if Msg.Contains('error: no devices/emulators found') then
  begin

  end
  else
    Log(Msg);
end;

procedure TViewAdbDialog.FormCreate(Sender: TObject);
begin
  edtAdbExe.Text := TDawTools.AdbExe;
end;

class function TViewAdbDialog.GetDosOutput(CommandLine, Work: string): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array [0 .. 255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
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
    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine), nil, nil, True, 0, nil,
      PChar(WorkDir), SI, PI);
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
end;

procedure TViewAdbDialog.Log(const AData: string);
begin
  mmoLog.Lines.Add(AData);
end;

function TViewAdbDialog.SetupDir: Boolean;
begin
  FDir := ExtractFilePath(edtAdbExe.Text);
  if (DirectoryExists(FDir) and FileExists(edtAdbExe.Text)) then
  begin
    Result := True;
  end
  else
  begin
    Log('bad path, adb not found');
    Result := False;
  end;
end;

end.
