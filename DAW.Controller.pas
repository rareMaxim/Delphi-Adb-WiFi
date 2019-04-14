unit DAW.Controller;

interface

uses

  Types,
  Menus,
  Windows,
  Graphics,
  ImgList,
  Dialogs,
  DAW.View.Main,
  Classes;

type
  TDAWController = class(TInterfacedObject)
  private
    FMenuItem: TMenuItem;
    FDialog: TForm2;
    FIcon: TIcon;
    procedure HandleClickDelphinus(Sender: TObject);
    procedure InstallMenu();
    procedure UninstallMenu();
    function GetIndexOfConfigureTools(AToolsMenu: TMenuItem): Integer;
  public
    constructor Create();
    destructor Destroy(); override;
  end;

implementation

uses
  ToolsAPI;

const
  CToolsMenu = 'ToolsMenu';
  CConfigureTools = 'ToolsToolsItem'; // heard you like tools....

  { TDelphinusController }

constructor TDAWController.Create;
var
  LBitmap: TBitmap;
begin
  inherited;
  FIcon := TIcon.Create();
  FIcon.SetSize(16, 16);
  // FIcon.Handle := LoadImage(HInstance, Ico_Delphinus, IMAGE_ICON, 0, 0, 0);
  LBitmap := TBitmap.Create();
  try
    LBitmap.SetSize(24, 24);
    LBitmap.Canvas.Draw((24 - FIcon.Width) div 2,
      (24 - FIcon.Height) div 2, FIcon);
    // SplashScreenServices.AddPluginBitmap(CVersionedDelphinus, LBitmap.Handle);
  finally
    LBitmap.Free;
  end;
  InstallMenu();
  FDialog := TForm2.Create(nil);
end;

destructor TDAWController.Destroy;
begin
  UninstallMenu();
  FDialog.Free;
  FIcon.Free;
  inherited;
end;

function TDAWController.GetIndexOfConfigureTools(AToolsMenu: TMenuItem)
  : Integer;
var
  i: Integer;
begin
  Result := AToolsMenu.Count;
  for i := 0 to AToolsMenu.Count - 1 do
  begin
    if AToolsMenu.Items[i].Name = CConfigureTools then
      Exit(i);
  end;
end;

procedure TDAWController.HandleClickDelphinus(Sender: TObject);
begin
  FDialog.Show();
end;

procedure TDAWController.InstallMenu;
var
  LItem: TMenuItem;
  LService: INTAServices;
  i, LIndex: Integer;
  LImageList: TCustomImageList;
begin
  LService := BorlandIDEServices as INTAServices;
  for i := LService.MainMenu.Items.Count - 1 downto 0 do
  begin
    LItem := LService.MainMenu.Items[i];
    if LItem.Name = CToolsMenu then
    begin
      FMenuItem := TMenuItem.Create(LService.MainMenu);
      FMenuItem.Caption := 'Adb WiFi';
      FMenuItem.Name := 'DelphiAdbWiFiMenu';
      FMenuItem.OnClick := HandleClickDelphinus;
      LIndex := GetIndexOfConfigureTools(LItem);
      LItem.Insert(LIndex, FMenuItem);
      LImageList := LItem.GetImageList;
      if Assigned(LImageList) then
      begin
        FMenuItem.ImageIndex := LImageList.AddIcon(FIcon);
      end;
      Break;
    end;
  end;
end;

procedure TDAWController.UninstallMenu;
begin
  if Assigned(FMenuItem) then
  begin
    FMenuItem.Free;
  end;
end;

end.
