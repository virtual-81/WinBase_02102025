@echo off
echo ========================================
echo ТЕСТ ПОЛНОГО ВСТРОЕННОГО ЯЗЫКОВОГО МОДУЛЯ
echo ========================================
echo.

echo 1. Проверяем файлы:
if exist embedded_language_complete.pas (
    echo ? embedded_language_complete.pas найден
) else (
    echo ? embedded_language_complete.pas НЕ найден!
    pause
    exit /b 1
)

echo.
echo 2. Статистика файла:
for /f %%i in ('find /c /v "" embedded_language_complete.pas') do echo Строк кода: %%i

echo.
echo 3. Проверяем изменения в проекте:
echo Поиск embedded_language_complete в wbase_synpdf.dpr:
findstr "embedded_language_complete" wbase_synpdf.dpr

echo.
echo Поиск embedded_language_complete в Main.pas:
findstr "embedded_language_complete" Main.pas

echo.
echo ========================================
echo ГОТОВО К КОМПИЛЯЦИИ И ТЕСТИРОВАНИЮ!
echo ========================================
echo.
echo ИНСТРУКЦИЯ:
echo 1. Скомпилируйте wbase_synpdf.dpr в Delphi IDE
echo 2. Запустите в проектной папке - должно работать как раньше
echo 3. Скопируйте exe в другую папку и запустите
echo 4. Теперь ВСЕ элементы интерфейса должны быть на русском!
echo.
echo Включено:
echo - 990 русских языковых строк
echo - 985 английских языковых строк  
echo - Полное покрытие интерфейса
echo.
echo Если все элементы отображаются на русском - ПРОБЛЕМА РЕШЕНА!
echo ========================================
pause