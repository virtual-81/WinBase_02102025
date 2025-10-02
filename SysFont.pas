unit SysFont;

// TODO: ����������� � ��������������� ������������ ��������� �������

interface

uses
    System.SysUtils, Winapi.Windows,
    System.Classes,
    Vcl.Graphics,
    Vcl.Controls,
    Winapi.Messages,
    Vcl.Forms;

type
    TSysFonts= class (TComponent)
    private
        fMessageFont: TFont;
        fCaptionFont: TFont;
        fSmallCaptionFont: TFont;
    fMenuFont: TFont;
    fStatusFont: TFont;
//      procedure SysFontChanged (Sender: TObject);
//      procedure WMWinIniChange (var Msg: TMessage); message WM_WININICHANGE;
//    procedure WMSysFontChanged (var Msg: TMessage); message WM_SYSFONTCHANGED;
    public
        constructor Create (AOwner: TComponent); override;
        destructor Destroy; override;
        property MessageFont: TFont read fMessageFont;
        property CaptionFont: TFont read fCaptionFont;
        property SmallCaptionFont: TFont read fSmallCaptionFont;
    property MenuFont: TFont read fMenuFont;
    property StatusFont: TFont read fStatusFont;
        procedure GetMetricSettings;
    procedure Update;
    end;

var
    SysFonts: TSysFonts;

implementation

procedure InitSysFonts;
begin
    SysFonts:= TSysFonts.Create (nil);
end;

procedure DestroySysFonts;
begin
    SysFonts.Free;
end;

{ TSysFont }

constructor TSysFonts.Create(AOwner: TComponent);
begin
    inherited;
    fMessageFont:= TFont.Create;
    fCaptionFont:= TFont.Create;
    fSmallCaptionFont:= TFont.Create;
  fMenuFont:= TFont.Create;
  fStatusFont:= TFont.Create;
  Update;
end;

destructor TSysFonts.Destroy;
begin
    fSmallCaptionFont.Free;
    fCaptionFont.Free;
    fMessageFont.Free;
  fMenuFont.Free;
  fStatusFont.Free;
    inherited;
end;

procedure TSysFonts.GetMetricSettings;
var
    NonClientMetrics: TNonClientMetrics;
begin
    NonClientMetrics.cbSize:= SizeOf (NonClientMetrics);
    if SystemParametersInfo (SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
        begin
            fMessageFont.Handle:= CreateFontIndirect (NonClientMetrics.lfMessageFont);
            fCaptionFont.Handle:= CreateFontIndirect (NonClientMetrics.lfCaptionFont);
            fSmallCaptionFont.Handle:= CreateFontIndirect (NonClientMetrics.lfSmCaptionFont);
      fMenuFont.Handle:= CreateFontIndirect (NonClientMetrics.lfMenuFont);
      fStatusFont.Handle:= CreateFontIndirect (NonClientMetrics.lfStatusFont);
        end
    else
        begin
            fMessageFont.Handle:= GetStockObject(SYSTEM_FONT);
            fMessageFont.Size:= 8;
            fCaptionFont.Handle:= GetStockObject(SYSTEM_FONT);
            fCaptionFont.Size:= 8;
            fSmallCaptionFont.Handle:= GetStockObject(SYSTEM_FONT);
            fSmallCaptionFont.Size:= 8;
      fMenuFont.Handle:= GetStockObject (SYSTEM_FONT);
      fMenuFont.Size:= 8;
      fStatusFont.Handle:= GetStockObject (SYSTEM_FONT);
      fStatusFont.Size:= 8;
        end;
    fMessageFont.Color:= clWindowText;
    fCaptionFont.Color:= clCaptionText;
    fSmallCaptionFont.Color:= clCaptionText;
  fMenuFont.Color:= clMenuText;
  fStatusFont.Color:= clWindowText;
end;

procedure TSysFonts.Update;
begin
    GetMetricSettings;
  Screen.ResetFonts;
end;

{procedure TSysFonts.SysFontChanged(Sender: TObject);
var
    i: integer;
    WParam: Longint;
    NonClientMetrics: TNonClientMetrics;
begin
    NonClientMetrics.cbSize:= SizeOf (NonClientMetrics);
    if Sender= fMessageFont then
    begin
        if SystemParametersInfo (SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
        fMessageFont.Handle:= CreateFontIndirect (NonClientMetrics.lfMessageFont);
        WParam:= 1;
    end
    else if Sender= fCaptionFont then
    begin
        if SystemParametersInfo (SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
            fCaptionFont.Handle:= CreateFontIndirect (NonClientMetrics.lfCaptionFont);
        WParam:= 2;
    end
    else if Sender= fSmallCaptionFont then
    begin
        if SystemParametersInfo (SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
            fSmallCaptionFont.Handle:= CreateFontIndirect (NonClientMetrics.lfSmCaptionFont);
        WParam:= 3;
    end
    else
    begin
      GetMetricSettings;
        WParam:= -1;
    end;
    for i:= 0 to Screen.FormCount-1 do
        Screen.Forms [i].Perform (CM_SYSFONTCHANGED,WParam,0);
end;}

{procedure TSysFonts.WMWinIniChange(var Msg: TMessage);
begin
    GetMetricSettings;
end;}

initialization
    InitSysFonts;

finalization
    DestroySysFonts;

end.

