# ?? ��������� �����! ��������� ������!

## ?? ����������� ��������:
**�� ����� ������ �� �����!**

### ? ��� ������:
- ? Unicode compatibility errors
- ? PDF property access errors  
- ? Type compatibility errors
- ? Declaration differs errors
- ? Missing identifiers errors
- ? Too many parameters errors

### ?? �������� ������ ����:
- ? **E2030 Duplicate case label** - ��������� �����!

## ?? ��������� �����������:
�������� case statement �� if statements ��� ��������� ����� ��������� conflicts:

```pascal
if (stt [j] >= #128) and (stt [j] <= #175) then
  stt [j]:= chr (ord (stt [j])+64)
else if (stt [j] >= #176) and (stt [j] <= #223) then
  stt [j]:= chr (ord (stt [j])-48)
else if (stt [j] >= #224) and (stt [j] <= #239) then
  stt [j]:= chr (ord (stt [j])+16);
```

## ?? ��������� ���������:
**������ �������� ���������� WBASE.DPROJ!**

��� ������ ���� ��������� ����������� ����� �������!

## ?? ��������� ���:
**���������� �������������� WBASE.DPROJ ��������� ���!**
