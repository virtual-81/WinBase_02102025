# �������� ������� ����������� ��������� ������

Write-Host "������� ������ embedded_language_complete.pas..."

# ������ ������� ����
$russianLines = [System.IO.File]::ReadAllLines('russian.wbl', [System.Text.Encoding]::GetEncoding(1251))
Write-Host "������� �����: $($russianLines.Count)"

# ������ ���������� ����  
$englishLines = [System.IO.File]::ReadAllLines('english.wbl', [System.Text.Encoding]::GetEncoding(1251))
Write-Host "���������� �����: $($englishLines.Count)"

# ������� ������ ������
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
  // ������ ���������� ������� �������� ������ (�������������)
  LangData := 
"@

# ��������� ������� ������
foreach ($line in $russianLines) {
    if ($line.Trim() -ne "") {
        $escapedLine = $line.Replace("'", "''")
        $content += "    '$escapedLine' + #13#10 +`n"
    }
}

# ������� ��������� +
$content = $content.TrimEnd(" +`n")
$content += ";`n`n  Language.LoadFromString(LangData);`nend;`n`n"

# ��������� ���������� ���������
$content += @"
procedure LoadEmbeddedEnglish;
var
  LangData: String;
begin
  // ������ ���������� ���������� �������� ������ (�������������)
  LangData := 
"@

# ��������� ���������� ������
foreach ($line in $englishLines) {
    if ($line.Trim() -ne "") {
        $escapedLine = $line.Replace("'", "''")
        $content += "    '$escapedLine' + #13#10 +`n"
    }
}

# ������� ��������� +
$content = $content.TrimEnd(" +`n")
$content += ";`n`n  Language.LoadFromString(LangData);`nend;`n`nend."

# ��������� ����
[System.IO.File]::WriteAllText('embedded_language_complete.pas', $content, [System.Text.Encoding]::UTF8)

Write-Host "? ������ embedded_language_complete.pas"
Write-Host "? �������� $($russianLines.Count) ������� �����"
Write-Host "? �������� $($englishLines.Count) ���������� �����"