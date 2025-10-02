@echo off
REM Скрипт для автоматической конвертации проектных файлов Delphi 7 в Delphi 12

echo ========================================
echo WinBASE Migration Script - Delphi 7 to 12
echo ========================================

REM Создание резервной копии
echo Создание резервной копии...
if not exist "backup" mkdir backup
xcopy *.bdsproj backup\ /Y
xcopy *.dof backup\ /Y
xcopy *.cfg backup\ /Y

echo Конвертация проектных файлов...

REM Основные проекты
echo Конвертация wbase.bdsproj...
powershell -Command "& { (Get-Content 'wbase.bdsproj') -replace '<FileVersion Name=\""Version\"">7.0</FileVersion>', '<FileVersion Name=\""Version\"">12.0</FileVersion>' | Set-Content 'wbase.dproj' }"

echo Конвертация ascor.bdsproj...
powershell -Command "& { (Get-Content 'ascor\\ascor.bdsproj') -replace '<FileVersion Name=\""Version\"">7.0</FileVersion>', '<FileVersion Name=\""Version\"">12.0</FileVersion>' | Set-Content 'ascor\\ascor.dproj' }"

echo Конвертация wbdstat.bdsproj...
powershell -Command "& { (Get-Content 'wbdstat.bdsproj') -replace '<FileVersion Name=\""Version\"">7.0</FileVersion>', '<FileVersion Name=\""Version\"">12.0</FileVersion>' | Set-Content 'wbdstat.dproj' }"

echo Конвертация проектов экспорта...
for /d %%d in (wbd2csv wbd2ftp wbasetosql wbdview) do (
    if exist "%%d\\%%d.bdsproj" (
        echo Конвертация %%d.bdsproj...
        powershell -Command "& { (Get-Content '%%d\\%%d.bdsproj') -replace '<FileVersion Name=\"\"Version\"\">[0-9.]+</FileVersion>', '<FileVersion Name=\"\"Version\"\"&gt;12.0</FileVersion>' | Set-Content '%%d\\%%d.dproj' }"
    )
)

echo ========================================
echo Конвертация завершена!
echo Файлы .dproj созданы для Delphi 12
echo Резервные копии сохранены в папке backup\
echo ========================================

pause
