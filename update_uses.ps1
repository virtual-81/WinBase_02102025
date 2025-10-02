# PowerShell скрипт для автоматического обновления uses секций

param(
  [string]$ProjectPath = "."
)

Write-Host "Обновление uses секций для совместимости с Delphi 12..." -ForegroundColor Green

# Замены для обновления uses секций
$usesMappings = @{
  'FileCtrl'  = 'System.UITypes, Vcl.FileCtrl'
  'Graphics'  = 'Vcl.Graphics'
  'Controls'  = 'Vcl.Controls'
  'Forms'     = 'Vcl.Forms'
  'Dialogs'   = 'Vcl.Dialogs'
  'StdCtrls'  = 'Vcl.StdCtrls'
  'ExtCtrls'  = 'Vcl.ExtCtrls'
  'ComCtrls'  = 'Vcl.ComCtrls'
  'Menus'     = 'Vcl.Menus'
  'Classes'   = 'System.Classes'
  'SysUtils'  = 'System.SysUtils'
  'Math'      = 'System.Math'
  'DateUtils' = 'System.DateUtils'
  'StrUtils'  = 'System.StrUtils'
  'Registry'  = 'System.Win.Registry'
  'IniFiles'  = 'System.IniFiles'
  'Variants'  = 'System.Variants'
  'Windows'   = 'Winapi.Windows'
  'Messages'  = 'Winapi.Messages'
  'CommDlg'   = 'Winapi.CommDlg'
  'Printers'  = 'Vcl.Printers'
  'ShellAPI'  = 'Winapi.ShellAPI'
}

# Функция для обновления файла
function Update-UsesClause {
  param([string]$FilePath)
    
  try {
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $originalContent = $content
        
    # Обновляем uses секции
    foreach ($oldUnit in $usesMappings.Keys) {
      $newUnit = $usesMappings[$oldUnit]
      # Замена в uses секции (учитываем запятые и точки с запятой)
      $content = $content -replace "\b$oldUnit\b(?=\s*[,;])", $newUnit
    }
        
    # Добавляем необходимые новые uses для Unicode поддержки
    if ($content -match "uses\s+") {
      if ($content -notmatch "System\.SysUtils") {
        $content = $content -replace "(uses\s+)", "`$1System.SysUtils, "
      }
    }
        
    # Сохраняем только если были изменения
    if ($content -ne $originalContent) {
      Set-Content $FilePath $content -Encoding UTF8
      Write-Host "Обновлен: $FilePath" -ForegroundColor Yellow
      return $true
    }
    return $false
  }
  catch {
    Write-Host "Ошибка обработки файла $FilePath`: $_" -ForegroundColor Red
    return $false
  }
}

# Функция для обновления строковых типов
function Update-StringTypes {
  param([string]$FilePath)
    
  try {
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $originalContent = $content
        
    # Замена AnsiString на String где это безопасно
    $content = $content -replace "\bAnsiString\b", "String"
        
    # Обновление PChar на PAnsiChar где необходимо для API
    # $content = $content -replace "\bPChar\b", "PAnsiChar"
        
    if ($content -ne $originalContent) {
      Set-Content $FilePath $content -Encoding UTF8
      Write-Host "Обновлены строковые типы: $FilePath" -ForegroundColor Cyan
      return $true
    }
    return $false
  }
  catch {
    Write-Host "Ошибка обновления строковых типов в $FilePath`: $_" -ForegroundColor Red
    return $false
  }
}

# Обработка всех .pas файлов
$pasFiles = Get-ChildItem -Path $ProjectPath -Filter "*.pas" -Recurse

$totalFiles = $pasFiles.Count
$updatedFiles = 0
$stringUpdatedFiles = 0

Write-Host "Найдено $totalFiles .pas файлов для обработки..."

foreach ($file in $pasFiles) {
  if (Update-UsesClause $file.FullName) {
    $updatedFiles++
  }
    
  if (Update-StringTypes $file.FullName) {
    $stringUpdatedFiles++
  }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Обработка завершена!" -ForegroundColor Green
Write-Host "Обновлено uses секций: $updatedFiles из $totalFiles файлов" -ForegroundColor Yellow
Write-Host "Обновлено строковых типов: $stringUpdatedFiles из $totalFiles файлов" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green

# Создание отчета
$reportPath = Join-Path $ProjectPath "migration_report.txt"
$report = @"
Отчет об обновлении проекта для Delphi 12
==========================================

Дата: $(Get-Date)
Всего обработано файлов: $totalFiles
Обновлено uses секций: $updatedFiles
Обновлено строковых типов: $stringUpdatedFiles

Основные изменения:
- Обновлены uses секции для совместимости с namespace
- Заменены AnsiString на String
- Добавлена поддержка Unicode

Следующие шаги:
1. Откройте проект в Delphi 12
2. Скомпилируйте и исправьте оставшиеся ошибки
3. Протестируйте функциональность
4. Обновите внешние библиотеки если необходимо
"@

Set-Content $reportPath $report -Encoding UTF8
Write-Host "Отчет сохранен в: $reportPath" -ForegroundColor Green
