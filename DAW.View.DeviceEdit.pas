unit DAW.View.DeviceEdit;

interface

uses
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
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Layouts,
  FMX.Controls.Presentation;

type
  TViewDeviceEdit = class(TForm)
    lblName: TLabel;
    lytName: TLayout;
    edtName: TEdit;
    lytIP: TLayout;
    lblIP: TLabel;
    edtIP: TEdit;
    lytDialogActions: TLayout;
    btnOk: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
    procedure FillUI(ADevice: TdawDevice);
    procedure UItoModel(var ADevice: TdawDevice);
  public
    { Public declarations }
    class function Edit(var ADevice: TdawDevice): Boolean;
  end;

var
  ViewDeviceEdit: TViewDeviceEdit;

implementation

{$R *.fmx}

{ TViewDeviceEdit }

class function TViewDeviceEdit.Edit(var ADevice: TdawDevice): Boolean;
var
  LForm: TViewDeviceEdit;
  LModalResult: TModalResult;
begin
  LForm := TViewDeviceEdit.Create(nil);
  try
    LForm.FillUI(ADevice);
    LModalResult := LForm.ShowModal;
    Result := IsPositiveResult(LModalResult);
    if Result then
    begin
      LForm.UItoModel(ADevice);
    end;
  finally
    LForm.Free;
  end;
end;

procedure TViewDeviceEdit.FillUI(ADevice: TdawDevice);
begin
  edtName.Text := ADevice.Name;
  edtIP.Text := ADevice.IP;
end;

procedure TViewDeviceEdit.UItoModel(var ADevice: TdawDevice);
begin
  ADevice.Name := edtName.Text;
  ADevice.IP := edtIP.Text;
end;

end.

