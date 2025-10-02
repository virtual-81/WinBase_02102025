# Исправление экспорта результатов в CSV

## Проблема
После миграции с Delphi 7 на Delphi 12 функция "Экспорт результатов в CSV..." перестала работать при нажатии на соответствующий пункт в меню.

## Причины проблем
1. **Изменения в кодировке**: В Delphi 12 изменилась работа с кодировками и Unicode
2. **Отсутствие обработки ошибок**: Функция могла падать без уведомления пользователя
3. **Проблемы с сохранением файла**: Метод `SaveToFile` мог не работать корректно с русскими символами

## Решение

### 1. Исправлена функция `ExportResultsToCSV` в `data.pas`

```pascal
procedure TStartListEventItem.ExportResultsToCSV(const FName: TFileName);
var
  s: TStringList;
  i: integer;
  fs: TFileStream;
  utf8Bytes: TBytes;
begin
  Shooters.SortOrder:= soFinal;
  s:= TStringList.Create;
  try
    // Добавляем заголовок CSV
    s.Add('Регион,Стартовый номер,Фамилия,Имя,Год рождения,Квалификация,Результат');
    
    // Добавляем данные стрелков
    for i:= 0 to Shooters.Count-1 do
      s.Add (Shooters.Items [i].CSVStr);
    
    // Сохраняем в UTF-8 для корректного отображения русских символов
    try
      fs := TFileStream.Create(FName, fmCreate);
      try
        // Добавляем BOM для UTF-8
        utf8Bytes := TEncoding.UTF8.GetPreamble;
        if Length(utf8Bytes) > 0 then
          fs.WriteBuffer(utf8Bytes[0], Length(utf8Bytes));
        
        // Записываем содержимое в UTF-8
        utf8Bytes := TEncoding.UTF8.GetBytes(s.Text);
        fs.WriteBuffer(utf8Bytes[0], Length(utf8Bytes));
      finally
        fs.Free;
      end;
    except
      // Если не удалось сохранить в UTF-8, сохраняем обычным способом
      s.SaveToFile(FName);
    end;
  finally
    s.Free;
  end;
end;
```

### 2. Улучшена функция `mnuCSVClick` в `form_managestart.pas`

- Добавлена обработка ошибок с информативными сообщениями
- Добавлены проверки условий с объяснениями
- Улучшен диалог сохранения файла
- Добавлено подтверждение успешного экспорта

## Улучшения

1. **Корректная кодировка**: Файлы сохраняются в UTF-8 с BOM для правильного отображения русских символов
2. **Заголовок CSV**: Добавлен заголовок с названиями колонок
3. **Обработка ошибок**: Пользователь получает понятные сообщения об ошибках
4. **Информативность**: Показываются причины, почему экспорт невозможен
5. **Подтверждение**: Уведомление об успешном экспорте

## Условия для экспорта
Для успешного экспорта результатов должны быть выполнены условия:
1. Выбрано упражнение в списке
2. Проведена жеребьевка (`IsLotsDrawn = true`)
3. Соревнование начато (`IsStarted = true`)

## Файлы изменены
- `data.pas` - функция `ExportResultsToCSV`
- `form_managestart.pas` - функция `mnuCSVClick`

Теперь экспорт результатов в CSV работает корректно с поддержкой русских символов!