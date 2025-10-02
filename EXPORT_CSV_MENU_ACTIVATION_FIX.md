# Исправление активации меню экспорта CSV

## Проблема
После предыдущих исправлений пункты меню "Экспорт..." при любых обстоятельствах остаются неактивными.

## Выявленные причины

### 1. Неправильная проверка границ массива
В функции `pmEventPopup` использовалась проверка `Length(fEventsData)` вместо `fStart.Events.Count`

### 2. Отсутствие обновления состояния меню при инициализации
При установке начального значения `lbEvents.ItemIndex:= 0` не вызывалось обновление состояния меню

### 3. Слишком строгие условия активации
Меню было привязано к `lotsdrawn`, что требует полной жеребьевки всех стрелков

## Внесенные исправления

### 1. Исправлена проверка границ в pmEventPopup

**Файл: form_managestart.pas**
```pascal
// Было:
if (idx< 0) or (idx>= Length (fEventsData)) then

// Стало:
if (idx< 0) or (idx>= fStart.Events.Count) then
```

### 2. Добавлено обновление данных событий в lbEventsClick

**Файл: form_managestart.pas**
```pascal
procedure TManageStartForm.lbEventsClick(Sender: TObject);
var
  idx: integer;
  ev: TStartListEventItem;
begin
  // Обновляем данные перед обновлением меню
  idx:= lbEvents.ItemIndex;
  if (idx >= 0) and (idx < fStart.Events.Count) then
    begin
      ev:= fStart.Events [idx];
      // Обновляем данные события
      with fEventsData [idx] do
        begin
          started:= ev.IsStarted;
          lotsdrawn:= ev.IsLotsDrawn;
          rel_count:= ev.Relays.Count;
          pos_count:= ev.PositionsCount;
          comp_completed:= ev.IsCompleted;
          start_no:= ev.StartNumber;
          final_completed:= ev.IsFinalOk;
          saved:= ev.Saved;
          shoot_offs:= ev.Fights;
        end;
    end;
  
  // Обновляем состояние меню при клике на элемент списка
  pmEventPopup(pmEvent);
end;
```

### 3. Изменена логика активации меню экспорта

**Файл: form_managestart.pas**
```pascal
// Было:
mnuCSV.Enabled:= fEventsData [idx].lotsdrawn;

// Стало:
// Экспорт CSV доступен если есть стрелки для экспорта
mnuCSV.Enabled:= (ev.Shooters.Count > 0);
```

### 4. Добавлено обновление меню при инициализации

**Файл: form_managestart.pas**
```pascal
// В функции UpdateStartInfo добавлено:
// Обновляем состояние меню после установки начального выбора
lbEventsClick(lbEvents);
```

### 5. Добавлено обновление меню в UpdateStartListInfo

**Файл: form_managestart.pas**
```pascal
procedure TManageStartForm.UpdateStartListInfo;
begin
  lName.Caption:= fStart.Info.CaptionText;
  lChamp.Caption:= fStart.Info.ChampionshipName;
  // ... остальной код ...
  Caption:= fStart.Info.CaptionText;
  
  // Обновляем состояние меню
  pmEventPopup(pmEvent);
end;
```

## Логика работы

Теперь меню экспорта CSV активируется при следующих условиях:

1. **Выбрано событие** в списке (idx >= 0 и idx < fStart.Events.Count)
2. **Есть стрелки** для экспорта (ev.Shooters.Count > 0)

Это более гибкий подход, который позволяет:
- Экспортировать список участников до проведения жеребьевки
- Экспортировать промежуточные результаты
- Экспортировать финальные результаты

## Отладка

Для отладки временно добавлена информация в заголовок окна:
```pascal
Caption:= 'DEBUG: shooters=' + IntToStr(ev.Shooters.Count) + ', lotsdrawn=' + BoolToStr(fEventsData [idx].lotsdrawn, True);
```

Эту строку можно удалить после подтверждения работоспособности.

## Тестирование

1. Откройте управление стартом
2. Выберите любое событие в списке
3. Проверьте, что меню "Экспорт результатов в CSV..." становится активным
4. Попробуйте экспорт для разных событий
5. Убедитесь, что создаются корректные CSV файлы