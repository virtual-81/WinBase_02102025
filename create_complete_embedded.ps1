# Создание полного встроенного языкового модуля

Write-Host "Создаем полный embedded_language_complete.pas..."

# Читаем русский файл
$russianLines = [System.IO.File]::ReadAllLines('russian.wbl', [System.Text.Encoding]::GetEncoding(1251))
Write-Host "Русских строк: $($russianLines.Count)"

# Читаем английский файл  
$englishLines = [System.IO.File]::ReadAllLines('english.wbl', [System.Text.Encoding]::GetEncoding(1251))
Write-Host "Английских строк: $($englishLines.Count)"

# Создаем начало модуля
$content = @"
unit embedded_language_complete;

interface

uses
  MyLanguage;

procedure LoadEmbeddedRussian;
procedure LoadEmbeddedEnglish;

implementation

procedure LoadEmbeddedRussian;
var
  LangData: String;
begin
  // Полные встроенные русские языковые данные (автогенерация)
  LangData := 
"@

# Добавляем русские строки
foreach ($line in $russianLines) {
    if ($line.Trim() -ne "") {
        $escapedLine = $line.Replace("'", "''")
        $content += "    '$escapedLine' + #13#10 +`n"
    }
}

# Убираем последний +
$content = $content.TrimEnd(" +`n")
$content += ";`n`n  Language.LoadFromString(LangData);`nend;`n`n"

# Добавляем английскую процедуру
$content += @"
procedure LoadEmbeddedEnglish;
var
  LangData: String;
begin
  // Полные встроенные английские языковые данные (автогенерация)
  LangData := 
"@

# Добавляем английские строки
foreach ($line in $englishLines) {
    if ($line.Trim() -ne "") {
        $escapedLine = $line.Replace("'", "''")
        $content += "    '$escapedLine' + #13#10 +`n"
    }
}

# Убираем последний +
$content = $content.TrimEnd(" +`n")
$content += ";`n`n  Language.LoadFromString(LangData);`nend;`n`nend."

# Сохраняем файл
[System.IO.File]::WriteAllText('embedded_language_complete.pas', $content, [System.Text.Encoding]::UTF8)

Write-Host "? Создан embedded_language_complete.pas"
Write-Host "? Включено $($russianLines.Count) русских строк"
Write-Host "? Включено $($englishLines.Count) английских строк"