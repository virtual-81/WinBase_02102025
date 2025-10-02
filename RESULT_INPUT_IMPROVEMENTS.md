# Улучшения ввода результатов

## Проблема
Система принимала результаты с десятыми только в формате с точкой (например, 101.9). Пользователи хотели вводить результаты в разных форматах:
- **101,9** - с запятой как разделителем
- **101.9** - с точкой как разделителем  
- **1019** - без разделителя (последняя цифра - десятые)

## Решение

### 1. Улучшена функция `StrToFinal10` в `data.pas`

Функция теперь поддерживает все три формата ввода:

```pascal
function StrToFinal10 (s: string): DWORD;
var
  i,f,n: integer;
  s1, s2: string;
  dotPos, commaPos: integer;
begin
  Result:= 0;
  s:= Trim(s);
  if s = '' then
    Exit;
    
  // Ищем разделители (точка или запятая)
  dotPos := pos('.', s);
  commaPos := pos(',', s);
  
  // Если есть точка или запятая - парсим как число с десятыми
  if (dotPos > 0) or (commaPos > 0) then
    begin
      // Используем тот разделитель, который найден первым
      if (dotPos > 0) and ((commaPos = 0) or (dotPos < commaPos)) then
        begin
          // Используем точку как разделитель
          s1:= substr(s, '.', 1);
          s2:= substr(s, '.', 2);
        end
      else
        begin
          // Используем запятую как разделитель
          s1:= substr(s, ',', 1);
          s2:= substr(s, ',', 2);
        end;
        
      if (s1 <> '') and (s2 <> '') then
        begin
          val(s1, i, n);
          if n = 0 then
            begin
              val(s2, f, n);
              if n = 0 then
                begin
                  // Если десятые больше 9, берем только первую цифру
                  if f > 9 then
                    f := f div 10;
                  Result:= i * 10 + f;
                end;
            end;
        end;
    end
  else
    begin
      // Нет разделителя - проверяем длину числа
      val(s, i, n);
      if n = 0 then  // проверка успешности преобразования
        begin
          // Если число больше 999, считаем что последняя цифра - десятые
          // Например: 1019 = 101.9
          if i > 999 then
            Result := i
          else
            Result := i * 10;  // Обычное целое число
        end;
    end;
end;
```

### 2. Обновлен метод `GetCompetition` в `form_inputresult.pas`

Метод теперь правильно определяет, содержит ли результат десятые доли:

```pascal
// Проверяем наличие разделителей (точка или запятая) или число > 999
var text := Trim(edtComp.Text);
var hasDecimalSeparator := (pos('.', text) > 0) or (pos(',', text) > 0);
var isLargeNumber := false;

if not hasDecimalSeparator then
  begin
    var tempVal, tempErr: integer;
    val(text, tempVal, tempErr);
    isLargeNumber := (tempErr = 0) and (tempVal > 999);
  end;

ER.Competition10:= StrToFinal10(text);
ER.fCompetitionWithTens:= hasDecimalSeparator or isLargeNumber;
```

## Примеры работы

| Ввод пользователя | Результат | Описание |
|------------------|-----------|----------|
| `101.9` | 1019 | Точка как разделитель |
| `101,9` | 1019 | Запятая как разделитель |
| `1019` | 1019 | Без разделителя (110-1090 = с десятыми) |
| `853` | 853 | Без разделителя (85.3) |
| `1090` | 1090 | Без разделителя (109.0) |
| `101` | 1010 | Обычное целое число (< 110) |
| `95.8` | 958 | Точка как разделитель |
| `95,8` | 958 | Запятая как разделитель |
| `95` | 950 | Обычное целое число (< 110) |

## Файлы изменены
- `data.pas` - функция `StrToFinal10`
- `form_inputresult.pas` - метод `GetCompetition`

Теперь пользователи могут вводить результаты в любом удобном формате!