# ����������: ��� �������� ��� �� step0_minimal.dpr � ����� ������

## ��� 1: ��������� ����� ������
1. � Delphi IDE ������� **File > Save All**
2. ��������� ������ ��� `test_vcl_new` (��� ����� ������ ���)
3. ��� ������� �����:
   - `test_vcl_new.dpr` (������� ���� ���������)
   - `test_vcl_new.dproj` (���� �������)
   - `Unit1.pas` (���� �����)
   - `Unit1.dfm` (������ �����)

## ��� 2: �������� ������� ���� ���������
1. � Project Manager (������) ������� `test_vcl_new.dpr`
2. ������ �������� �� ���� ��� ��������

## ��� 3: �������� ��� � .dpr �����
�������� ���� ��� � .dpr ����� �� ����:

```pascal
program test_vcl_new;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  ShowMessage('VCL Test - SUCCESS!');
end.
```

## ��� 4: ������� ������ �� �����
1. ������� ������ ����:
   ```pascal
   uses
     Vcl.Forms,
     Unit1 in 'Unit1.pas' {Form1};
   ```
2. ������� `, Unit1 in 'Unit1.pas' {Form1}` 
3. ������� ������ ����:
   ```pascal
   Application.CreateForm(TForm1, Form1);
   ```

## ��� 5: �������������
1. ������� **Project > Build** ��� **F9**
2. ������ ������ ���������������� ��� ������
3. �������� ��������� "VCL Test - SUCCESS!"

## �������������� ������
���� ������ ������������ ������� ����:
1. �������� `step0_minimal.dproj` �������� � Delphi
2. ���������� �������������� ���
