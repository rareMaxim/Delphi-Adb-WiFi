unit DAW.Model.Devices;

interface

uses
  System.Generics.Collections,
  DAW.Model.Device.New;

type
  TdawDevices = class(TList<TdawDevice>)
  end;

implementation

end.

