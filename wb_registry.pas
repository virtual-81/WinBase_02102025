{$A-,J+}
unit wb_registry;

interface

uses
  Vcl.ComCtrls,
  Winapi.Windows,
  MyStrings,
  System.SysUtils,
  System.Win.Registry;

procedure SaveHeaderControlToRegistry (const AName: string; HC: THeaderControl);
procedure LoadHeaderControlFromRegistry (const AName: string; HC: THeaderControl);
procedure SaveValueToRegistry (const AName: string; Value: integer);
procedure LoadValueFromRegistry (const AName: string; out Value: integer; ADefault: integer);
procedure SaveStrToRegistry (const AName: string; AValue: string);
procedure LoadStrFromRegistry (const AName: string; out AValue: string; ADefault: string);

const
  REG_PATH= '\Software\007Soft\WinBASE';

implementation

procedure SaveHeaderControlToRegistry (const AName: string; HC: THeaderControl);
var
  s: string;
  i: integer;
  Reg: TRegistry;
begin
  s:= '';
  for i:= 0 to HC.Sections.Count-1 do
    begin
      if i> 0 then
        s:= s+',';
      s:= s+IntToStr (HC.Sections [i].Width);
    end;
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH, true) then
      begin
        Reg.WriteString (AName,s);
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure LoadHeaderControlFromRegistry (const AName: string; HC: THeaderControl);
var
  Reg: TRegistry;
  i: integer;
  s: string;
  w,n: integer;
begin
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH, true) then
      begin
        if Reg.ValueExists (AName) then
          begin
            s:= Reg.ReadString (AName);
            for i:= 1 to substrcount (s,',') do
              begin
                val (substr (s,',',i),w,n);
                if i-1< HC.Sections.Count then
                  HC.Sections [i-1].Width:= w;
              end;
          end;
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure SaveValueToRegistry (const AName: string; Value: integer);
var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH, true) then
      begin
        Reg.WriteInteger (AName,Value);
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure LoadValueFromRegistry (const AName: string; out Value: integer; ADefault: integer);
var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH, true) then
      begin
        if Reg.ValueExists (AName) then
          Value:= Reg.ReadInteger (AName)
        else
          Value:= ADefault;
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure SaveStrToRegistry (const AName: string; AValue: string);
var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH, true) then
      begin
        Reg.WriteString (AName,AValue);
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure LoadStrFromRegistry (const AName: string; out AValue: string; ADefault: string);
var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH, true) then
      begin
        if Reg.ValueExists (AName) then
          AValue:= Reg.ReadString (AName)
        else
          AValue:= ADefault;
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

end.
