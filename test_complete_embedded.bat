@echo off
echo ========================================
echo ���� ������� ����������� ��������� ������
echo ========================================
echo.

echo 1. ��������� �����:
if exist embedded_language_complete.pas (
    echo ? embedded_language_complete.pas ������
) else (
    echo ? embedded_language_complete.pas �� ������!
    pause
    exit /b 1
)

echo.
echo 2. ���������� �����:
for /f %%i in ('find /c /v "" embedded_language_complete.pas') do echo ����� ����: %%i

echo.
echo 3. ��������� ��������� � �������:
echo ����� embedded_language_complete � wbase_synpdf.dpr:
findstr "embedded_language_complete" wbase_synpdf.dpr

echo.
echo ����� embedded_language_complete � Main.pas:
findstr "embedded_language_complete" Main.pas

echo.
echo ========================================
echo ������ � ���������� � ������������!
echo ========================================
echo.
echo ����������:
echo 1. ������������� wbase_synpdf.dpr � Delphi IDE
echo 2. ��������� � ��������� ����� - ������ �������� ��� ������
echo 3. ���������� exe � ������ ����� � ���������
echo 4. ������ ��� �������� ���������� ������ ���� �� �������!
echo.
echo ��������:
echo - 990 ������� �������� �����
echo - 985 ���������� �������� �����  
echo - ������ �������� ����������
echo.
echo ���� ��� �������� ������������ �� ������� - �������� ������!
echo ========================================
pause