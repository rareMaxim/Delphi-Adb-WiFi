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
  FMX.Memo,
  FMX.TabControl, FMX.Memo.Types;

type
  TForm2 = class(TForm)
    grdLastDevices: TGrid;
    dtclmnLastConnected: TDateColumn;
    lytToolbarLastConnected: TLayout;
    btnAdd: TButton;
    strngclmnDeviceName: TStringColumn;
    btnConnect: TButton;
    btnDisconnect: TButton;
    strngclmnIP: TStringColumn;
    strngclmnID: TStringColumn;
    mmoLog: TMemo;
    edtCmdEdit: TEdit;
    btnCmdExecute: TEditButton;
    btn1: TButton;
    btnDelete: TButton;
    grpLastConnectedDevices: TGroupBox;
    tbcMenu: TTabControl;
    tbtmGeneral: TTabItem;
    tbtmLog: TTabItem;
    grp1: TGroupBox;
    spl1: TSplitter;
    tmr1: TTimer;
    lyt1: TLayout;
    btn2: TButton;
    grdAvaibleDevices: TGrid;
    strngclmn1: TStringColumn;
    strngclmn3: TStringColumn;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure grdLastDevicesGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure grdLastDevicesSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
    procedure btnConnectClick(Sender: TObject);
    procedure btnCmdExecuteClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure grdAvaibleDevicesGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure btn2Click(Sender: TObject);
  private
    { Private declarations }
    FController: TdawController;
    procedure UpdateCount;
    function SelectedDevice(const IsLast: Boolean): TdawDevice;
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

procedure TForm2.btn2Click(Sender: TObject);
var
  LDevice: TdawDevice;
begin
  LDevice := SelectedDevice(False);
  FController.Add(LDevice);
  FController.Connect(LDevice);
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
  FController.Connect(SelectedDevice(True));
  UpdateCount;
end;

procedure TForm2.btnDeleteClick(Sender: TObject);
begin
  FController.Delete(SelectedDevice(True));
  UpdateCount;
end;

procedure TForm2.btnDisconnectClick(Sender: TObject);
begin
  FController.Disconnect(SelectedDevice(True));
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

procedure TForm2.grdAvaibleDevicesGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
var
  LColumnName: string;
begin
  LColumnName := grdAvaibleDevices.Columns[ACol].Name;
  if LColumnName = strngclmn1.Name then
  begin
    Value := FController.AvaibleDevices[ARow].Name;
  end
  else if LColumnName = strngclmn3.Name then
  begin
    Value := FController.AvaibleDevices[ARow].ID;
  end
end;

procedure TForm2.grdLastDevicesGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
var
  LColumnName: string;
begin
  LColumnName := grdLastDevices.Columns[ACol].Name;
  if LColumnName = strngclmnDeviceName.Name then
  begin
    Value := FController.LastDevices[ARow].Name;
  end
  else if LColumnName = dtclmnLastConnected.Name then
  begin
    Value := FController.LastDevices[ARow].LastConnected;
  end
  else if LColumnName = strngclmnIP.Name then
  begin
    Value := FController.LastDevices[ARow].IP;
  end
  else if LColumnName = strngclmnID.Name then
  begin
    Value := FController.LastDevices[ARow].ID;
  end
end;

procedure TForm2.grdLastDevicesSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
var
  LColumnName: string;
begin
  LColumnName := grdLastDevices.Columns[ACol].Name;
  if LColumnName = strngclmnDeviceName.Name then
  begin
    FController.LastDevices[ARow].Name := Value.AsString;
  end
  else if LColumnName = dtclmnLastConnected.Name then
  begin
    FController.LastDevices[ARow].LastConnected := Value.AsType<TDateTime>;
  end
  else if LColumnName = strngclmnIP.Name then
  begin
    FController.LastDevices[ARow].IP := Value.AsString;
  end
  else if LColumnName = strngclmnID.Name then
  begin
    FController.LastDevices[ARow].ID := Value.AsString;
  end
end;

function TForm2.SelectedDevice(const IsLast: Boolean): TdawDevice;
begin
  if IsLast then
    Result := FController.LastDevices[grdLastDevices.Selected]
  else
    Result := FController.AvaibleDevices[grdAvaibleDevices.Selected];
end;

procedure TForm2.tmr1Timer(Sender: TObject);
begin
  FController.AddConnectedInAdb;
  UpdateCount;
end;

procedure TForm2.UpdateCount;
begin
//  grdLastDevices.RowCount := 0;
  if grdLastDevices.RowCount <> FController.LastDevices.Count then
    grdLastDevices.RowCount := FController.LastDevices.Count;
 // grdAvaibleDevices.RowCount := 0;
  if grdAvaibleDevices.RowCount <> FController.AvaibleDevices.Count then
    grdAvaibleDevices.RowCount := FController.AvaibleDevices.Count;
end;

end.

