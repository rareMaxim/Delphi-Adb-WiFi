unit DAW.Main;

interface

uses
  ToolsAPI,
  Menus,
  DAW.Controller;

procedure Register;

implementation

var
  GController: IInterface = nil;

procedure Register;
begin

end;

initialization
  GController := TDAWController.Create();

finalization
  GController := nil;

end.

