unit DAW.View.Main;

interface

uses
  DAW.Controller.New,
  DAW.Model.Device.New,
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
  System.Rtti,
  FMX.Grid.Style,
  FMX.Grid,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Edit,
  FMX.Memo;

type
  TForm2 = class(TForm)
    grdDevices: TGrid;
    dtclmnLastConnected: TDateColumn;
    lytToolbar: TLayout;
    btnAdd: TButton;
    strngclmnDeviceName: TStringColumn;
    btnConnect: TButton;
    btnDisconnect: TButton;
    strngclmnIP: TStringColumn;
    strngclmnID: TStringColumn;
    mmoLog: TMemo;
    edtCmdEdit: TEdit;
    btnCmdExecute: TEditButton;
    strngclmnType: TStringColumn;
    btn1: TButton;
    btnDelete: TButton;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure grdDevicesGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure grdDevicesSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
    procedure btnConnectClick(Sender: TObject);
    procedure btnCmdExecuteClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
  private
    { Private declarations }
    FController: TdawController;
    procedure UpdateCount;
    function SelectedDevice: TdawDevice;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses
  DAW.View.DeviceEdit;
{$R *.fmx}

procedure TForm2.btn1Click(Sender: TObject);
begin
  FController.AddConnectedInAdb;
  UpdateCount;
end;

procedure TForm2.btnAddClick(Sender: TObject);
var
  LDevice: TdawDevice;
begin
  LDevice := TdawDevice.Create('', '');
  try
    if TViewDeviceEdit.Edit(LDevice) then
      FController.Add(LDevice);
  finally
  //  LDevice.Free;
  end;
  UpdateCount;
end;

procedure TForm2.btnCmdExecuteClick(Sender: TObject);
begin
  mmoLog.Lines.Add(FController.GetDosCMD.Execute(edtCmdEdit.Text))
end;

procedure TForm2.btnConnectClick(Sender: TObject);
begin
  FController.Connect(SelectedDevice);
  UpdateCount;
end;

procedure TForm2.btnDeleteClick(Sender: TObject);
begin
  FController.Delete(SelectedDevice);
  UpdateCount;
end;

procedure TForm2.btnDisconnectClick(Sender: TObject);
begin
  FController.Disconnect(SelectedDevice);
  UpdateCount;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  FController := TdawController.Create;
  FController.GetDosCMD.OnExecute :=
    procedure(AData: string)
    begin
      mmoLog.Lines.Add(AData);
      UpdateCount;
    end;
 // FController.Devices.AddRange(f);
  UpdateCount;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FController);
end;

procedure TForm2.grdDevicesGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
var
  LColumnName: string;
begin
  LColumnName := grdDevices.Columns[ACol].Name;
  if LColumnName = strngclmnDeviceName.Name then
  begin
    Value := FController.Devices[ARow].Name;
  end
  else if LColumnName = dtclmnLastConnected.Name then
  begin
    Value := FController.Devices[ARow].LastConnected;
  end
  else if LColumnName = strngclmnIP.Name then
  begin
    Value := FController.Devices[ARow].IP;
  end
  else if LColumnName = strngclmnID.Name then
  begin
    Value := FController.Devices[ARow].ID;
  end
  else if LColumnName = strngclmnType.Name then
  begin
    Value := TRttiEnumerationType.GetName(FController.Devices[ARow].GetConnectionType);
  end
end;

procedure TForm2.grdDevicesSetValue(Sender: TObject; const ACol, ARow: Integer;
  const Value: TValue);
var
  LColumnName: string;
begin
  LColumnName := grdDevices.Columns[ACol].Name;
  if LColumnName = strngclmnDeviceName.Name then
  begin
    FController.Devices[ARow].Name := Value.AsString;
  end
  else if LColumnName = dtclmnLastConnected.Name then
  begin
    FController.Devices[ARow].LastConnected := Value.AsType<TDateTime>;
  end
  else if LColumnName = strngclmnIP.Name then
  begin
    FController.Devices[ARow].IP := Value.AsString;
  end
  else if LColumnName = strngclmnID.Name then
  begin
    FController.Devices[ARow].ID := Value.AsString;
  end
  else if LColumnName = strngclmnType.Name then
  begin
    // readonly
  end
end;

function TForm2.SelectedDevice: TdawDevice;
begin
  Result := FController.Devices[grdDevices.Selected];
end;

procedure TForm2.UpdateCount;
begin
  grdDevices.RowCount := 0;
  grdDevices.RowCount := FController.Devices.Count;
end;

end.

