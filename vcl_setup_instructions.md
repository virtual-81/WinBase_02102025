# Инструкция: Как вставить код из step0_minimal.dpr в новый проект

## Шаг 1: Сохраните новый проект
1. В Delphi IDE нажмите **File > Save All**
2. Сохраните проект как `test_vcl_new` (или любое другое имя)
3. Это создаст файлы:
   - `test_vcl_new.dpr` (главный файл программы)
   - `test_vcl_new.dproj` (файл проекта)
   - `Unit1.pas` (файл формы)
   - `Unit1.dfm` (дизайн формы)

## Шаг 2: Откройте главный файл программы
1. В Project Manager (справа) найдите `test_vcl_new.dpr`
2. Дважды кликните на него для открытия

## Шаг 3: Замените код в .dpr файле
Замените весь код в .dpr файле на этот:

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

## Шаг 4: Уберите ссылку на форму
1. Найдите строки типа:
   ```pascal
   uses
     Vcl.Forms,
     Unit1 in 'Unit1.pas' {Form1};
   ```
2. Удалите `, Unit1 in 'Unit1.pas' {Form1}` 
3. Удалите строки типа:
   ```pascal
   Application.CreateForm(TForm1, Form1);
   ```

## Шаг 5: Скомпилируйте
1. Нажмите **Project > Build** или **F9**
2. Проект должен скомпилироваться без ошибок
3. Появится сообщение "VCL Test - SUCCESS!"

## Альтернативный способ
Если хотите использовать готовый файл:
1. Откройте `step0_minimal.dproj` напрямую в Delphi
2. Попробуйте скомпилировать его
