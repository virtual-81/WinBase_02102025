unit wbd2ftp_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, FTP, Vcl.StdCtrls, Data;

const
  WM_FTP_OK= WM_USER+1;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fc: TMFTP;
    fFileIndex: integer;
    fCurrentFile: string;
    fRetries: integer;
    procedure OnLoggedIn (Sender: TObject);
    procedure OnFtpNeedInfo (Sender: TObject; need: TMFtpInfoNeeded; var Value: String);
    procedure OnDirectoryChanged (Sender: TObject);
    procedure OnFileStored (Sender: TObject);
    procedure OnFtpError (Sender: TObject; error: FtpError; addinfo: String);
    procedure OnStorProcess (Sender: TObject);
    procedure WMFtpOk (var M: TMessage); message WM_FTP_OK;
    function GetNextFile: string;
    procedure OnFtpReady (Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
  FtpErrorStr: array [FtpError] of string= (
    '','Network down','Invalid address','Internal error',
    'General winsock error','Connection aborted','Connection reset','Connection timeout',
    'Out of sockets','Network unreachable','Address not available',
    'Connection refused','Protocol error','Canceled','Unknown',
    'Address resolution error','Premature disconnect',
    'Host unreachable','No server','No proxy server',
    'File open','File write','File read','File not found',
    'Timeout','Server down','Access denied','Data error',
    'Resume failed','Permission denied','Bad url',
    'Transfer type','Transfer port','Transfer fatal port','Transfer get','Transfer put',
    'Transfer fatal error','Transfer resume failed'
  );

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  d: TData;
begin
  d:= TData.Create;
  try
    d.LoadFromFile ('russia.wbd');
    ListBox1.Items.Add ('������ ��������� �� russia.wbd');
    ListBox1.Refresh;
  except
    d.Free;
    MessageDlg ('������ ������ ����� RUSSIA.WBD',mtError,[mbOk],0);
    Close;
    exit;
  end;
  try
    d.SaveToFile ('russia_web.wbd',false,false);
    ListBox1.Items.Add ('������ �������� � russia_web.wbd');
    ListBox1.Refresh;
  except
    d.Free;
    MessageDlg ('������ ������ ����� RUSSIA_WEB.WBD',mtError,[mbOk],0);
    Close;
    exit;
  end;
  d.Free;
  fc.OnStorFileProcess:= OnStorProcess;
  fc.Server:= 'u84746.ftp.masterhost.ru';
  fc.Username:= 'u84746_winbase';
  fc.Password:= 'unct7pelepin';
  fc.Passive:= true;
  fc.Asynchronous:= false;
  fc.Login;
  if not fc.Success then
    begin
      fc.Quit;
      MessageDlg ('������ ���������� � ��������',mtError,[mbOk],0);
      Close;
    end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fc.Quit;
  fc.Disconnect;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  fc:= TMFtp.Create (self);
  fc.OnFtpNeedInfo:= OnFtpNeedInfo;
  fc.OnLoggedIn:= OnLoggedIn;
  fc.OnDirectoryChanged:= OnDirectoryChanged;
  fc.OnFileStored:= OnFileStored;
  fc.OnFtpError:= OnFtpError;
  fc.OnFtpReady:= OnFtpReady;
  fFileIndex:= 0;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fc.Free;
end;

function TForm1.GetNextFile: string;
begin
  case fFileIndex of
    0: Result:= 'russia.wbd';
    1: Result:= 'russia_web.wbd';
  else
    Result:= '';
  end;
  inc (fFileIndex);
  fRetries:= 0;
end;

procedure TForm1.OnDirectoryChanged(Sender: TObject);
begin
  ListBox1.Items.Add ('current dir: '+fc.CurrentDirectory);
  PostMessage (Form1.Handle,WM_FTP_OK,0,0);
end;

procedure TForm1.OnFileStored(Sender: TObject);
begin
  ListBox1.Items.Add ('file stored ok');
  PostMessage (Form1.Handle,WM_FTP_OK,0,0);
end;

procedure TForm1.OnFtpError(Sender: TObject; error: FtpError; addinfo: String);
begin
  if error= ftpFileOpen then
    begin
      inc (fRetries);
      if fRetries< 3 then
        begin
          ListBox1.Items.Add ('������ #'+IntToStr (fRetries)+': '+fCurrentFile);
          fc.PutFile (fCurrentFile,fCurrentFile);
          exit;
        end;
    end;
  ListBox1.Items.Add ('ftp error: ['+FtpErrorStr[error]+'] '+addinfo);
  MessageDlg ('������ FTP!',mtError,[mbOk],0);
  Close;
end;

procedure TForm1.OnFtpNeedInfo(Sender: TObject; need: TMFtpInfoNeeded; var Value: String);
begin
  case need of
    niAccount: Value:= '';
    niOverwrite: Value:= 'overwrite';
  end;
end;

procedure TForm1.OnFtpReady(Sender: TObject);
begin
end;

procedure TForm1.OnLoggedIn(Sender: TObject);
begin
  ListBox1.Items.Add ('FTP login OK');
//  fc.ChangeDirectory ('/');
  fc.ChangeToParentDirectory;
//  PostMessage (Form1.Handle,WM_FTP_OK,0,0);
end;

procedure TForm1.OnStorProcess(Sender: TObject);
begin
  ListBox1.Items[ListBox1.Count-1]:= '����������� '+fCurrentFile+': '+IntToStr (fc.BytesTransferred)+' bytes';
end;

procedure TForm1.WMFtpOk(var M: TMessage);
begin
  fCurrentFile:= GetNextFile;
  if fCurrentFile<> '' then
    begin
      ListBox1.Items.Add ('����������� '+fCurrentFile);
      fc.PutFile (fCurrentFile,fCurrentFile);
    end
  else
    begin
      MessageDlg ('����� ����������� �� ������',mtInformation,[mbOk],0);
      fc.OnFtpError:= nil;
      Close;
    end;
end;

end.

