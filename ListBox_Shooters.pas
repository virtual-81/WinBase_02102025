unit ListBox_Shooters;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Graphics,
  System.SysUtils,
  System.StrUtils,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  MyListBoxes,
  System.Math,
  Data;

type
  TPrintListCriteria= (plAll,plMarked,plInStart);

type
	TShootersFilterItem= class (TCollectionItem)
	private
		fShooter: TShooterItem;
    fInStart: integer;  // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
                        // -1 пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ, 0 - пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
    fHasResults: boolean;
		function get_Rating: integer;
		function get_CurrentEvent: TEventItem;
	public
		constructor Create (ACollection: TCollection); override;
		property Shooter: TShooterItem read fShooter write fShooter;
		property Rating: integer read get_Rating;
		property CurrentEvent: TEventItem read get_CurrentEvent;
		function RatingStr: string;
    property HasResults: boolean read fHasResults write fHasResults;
    property InStart: integer read fInStart write fInStart;
    function CSVStr: string;
	end;

	TShootersFilter= class (TCollection)
	private
		fCurrentEvent: TEventItem;
		fSortOrder: TShootersSortOrder;
    procedure set_CurrentEvent(const Value: TEventItem);
		function get_ShooterIdx(index: integer): TShootersFilterItem;
		function get_MarkedShooterIdx(index: integer): TShootersFilterItem;
	public
		constructor Create;
		property SortOrder: TShootersSortOrder read fSortOrder write fSortOrder;
		function Add: TShootersFilterItem; overload;
		property Items [index: integer]: TShootersFilterItem read get_ShooterIdx;
		property Marked [index: integer]: TShootersFilterItem read get_MarkedShooterIdx;
		procedure Add (AShooter: TShooterItem); overload;
		procedure Add (AShooters: TShooters); overload;
		procedure Sort;
		property Event: TEventItem read fCurrentEvent write set_CurrentEvent;
		function MarkedCount: integer;
		procedure Remove (AShooter: TShooterItem);
		procedure MarkAll (Marked: boolean);
		function Find (SearchFrom: integer; stt: string): integer;
		procedure MarkAllRated;
    function GetLastMarkedIndex: integer;
    function MarkedIdx (index: integer): TShootersFilterItem;
		function FindItem (AShooter: TShooterItem): TShootersFilterItem;
	end;

 	TShootersListBox= class (THeadedListBox)
	private
		fShootersFilter: TShootersFilter;
		fCurrentSearchStr: string;
    fPhotoBitmap,fResultsBitmap: TBitmap;
    fOnChangeMark: TNotifyEvent;
    fLastClickShiftState: TShiftState;
		function get_SortOrder: TShootersSortOrder;
		procedure set_SortOrder(const Value: TShootersSortOrder);
		function get_MarkedShooterIdx(index: integer): TShootersFilterItem;
		procedure UpdateListBox;
		function get_Shooter(index: integer): TShootersFilterItem;
		function get_CurrentEvent: TEventItem;
		procedure set_CurrentEvent(const Value: TEventItem);
	public
		constructor Create (AOwner: TComponent); override;
		destructor Destroy; override;
		procedure Mark;
		procedure MarkAll (Select: boolean);
		procedure MarkAllRated;
		procedure Clear; override;
		procedure Add (AShooter: TShooterItem); overload;
		procedure Add (AShooters: TShooters); overload;
		property SortOrder: TShootersSortOrder read get_SortOrder write set_SortOrder;
		procedure Sort;
		function MarkedCount: integer;
		procedure DeleteShooter (index: integer);
		procedure Remove (AShooter: TShooterItem);
		property Marked [index: integer]: TShootersFilterItem read get_MarkedShooterIdx;
    procedure DrawItem (Sender: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState); override;
		procedure DrawItemSection (Index: Integer; ARect: TRect; State: TOwnerDrawState;
      ASection: THeadedListBoxSection; const AText: string); override;
		function CurrentShooter: TShootersFilterItem;
		property FilteredShooters [index: integer]: TShootersFilterItem read get_Shooter; default;
		property Event: TEventItem read get_CurrentEvent write set_CurrentEvent;
//		procedure LBKeyPress(Sender: TObject; var Key: Char);
//    procedure LBKeyDown (Sender: TObject; var Key: word; State: TShiftState);
    procedure LBClick (Sender: TObject);
		procedure LBMouseDown (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LBDblClick (Sender: TObject);
    procedure KeyDown (var Key: word; State: TShiftState); override;
    procedure KeyPress (var Key: char); override;
    procedure ResetSearch;
    function GetLastClickShiftState: TShiftState;
    property OnChangeMark: TNotifyEvent read fOnChangeMark write fOnChangeMark;
    property ParentFont;
    property Color;
    property ParentCtl3D;
    property Ctl3D;
    property BorderWidth;
    property Shooters: TShootersFilter read fShootersFilter;
    property Font;
    function Count: integer;
    property OnExit;
    property OnEnter;
    property OnKeyDown;
	end;

implementation

{ TShootersListBox }

procedure TShootersListBox.Add(AShooters: TShooters);
var
	i: integer;
begin
	for i:= 0 to AShooters.Count-1 do
    Add (AShooters.Items [i]);
end;

procedure TShootersListBox.Add(AShooter: TShooterItem);
begin
	fShootersFilter.Add (AShooter);
	ListBox.Items.Add ('');
end;

procedure TShootersListBox.Clear;
begin
  ResetSearch;
	fShootersFilter.Clear;
	inherited Clear;
end;

procedure TShootersListBox.LBClick (Sender: TObject);
begin
  ResetSearch;
end;

procedure TShootersListBox.LBDblClick(Sender: TObject);
begin
  DblClick;
end;

function TShootersListBox.Count: integer;
begin
  Result:= fShootersFilter.Count;
end;

constructor TShootersListBox.Create(AOwner: TComponent);
var
  i: integer;
  s: THeadedListBoxSection;
begin
	inherited;
	fShootersFilter:= TShootersFilter.Create;
//	ListBox.Style:= lbOwnerDrawFixed;
  fPhotoBitmap:= TBitmap.Create;
//  ListBox.OnKeyPress:= LBKeyPress;
//  ListBox.OnKeyDown:= LBKeyDown;
  ListBox.OnMouseDown:= LBMouseDown;
  ListBox.OnClick:= LBClick;
  ListBox.OnDblClick:= LBDblClick;
  fOnChangeMark:= nil;
  fLastClickShiftState:= []; // Инициализация состояния клавиш
  try
    // fPhotoBitmap.LoadFromResourceID (HInstance,1); // Ресурс не найден - создаем пустой bitmap
    fPhotoBitmap.Width := 16;
    fPhotoBitmap.Height := 16;
    fPhotoBitmap.Transparent:= true;
    fPhotoBitmap.TransparentColor:= fPhotoBitmap.Canvas.Pixels [0,0];
  except
  end;
  fResultsBitmap:= TBitmap.Create;
  try
    // fResultsBitmap.LoadFromResourceID (HInstance,4); // Ресурс не найден - создаем пустой bitmap
    fResultsBitmap.Width := 16;
    fResultsBitmap.Height := 16;
    fResultsBitmap.Transparent:= true;
    fResultsBitmap.TransparentColor:= fResultsBitmap.Canvas.Pixels [0,0];
  except
  end;
  ListBox.Font.Style:= [fsBold];
  s:= AddSection ('');
  s.MinWidth:= round (fPhotoBitmap.Width+16);
  s.Width:= s.MinWidth;
  s:= AddSection ('');
  s.MinWidth:= round (fResultsBitmap.Width+16);
  s.Width:= s.MinWidth;
  s:= AddSection ('');
  s.MinWidth:= 32;
  s.Width:= 256;
  for i:= 3 to 6 do
    begin
      s:= AddSection ('');
      s.MinWidth:= 32;
      s.Width:= 96;
    end;
end;

function TShootersListBox.CurrentShooter: TShootersFilterItem;
begin
	if (ListBox.ItemIndex>= 0) and (ListBox.ItemIndex< ListBox.Count) then
		Result:= fShootersFilter.Items [ListBox.ItemIndex]
	else
		Result:= nil;
end;

procedure TShootersListBox.DeleteShooter(index: integer);
begin
	fShootersFilter.Delete (index);
	ListBox.Items.Delete (index);
end;

destructor TShootersListBox.Destroy;
begin
	fShootersFilter.Free;
  fPhotoBitmap.Free;
	inherited;
end;

procedure TShootersListBox.DrawItem(Sender: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
var
  i: integer;
  s: THeadedListBoxSection;
begin
  with ListBox.Canvas do
    begin
      if odSelected in State then
        begin
          if not ListBox.Focused then
            Brush.Color:= clGrayText;
        end;
  		FillRect (ARect);
      for i:= 0 to Header.Sections.Count-1 do
        begin
          s:= Header.Sections [i] as THeadedListBoxSection;
          DrawItemSection (Index,ARect,State,s,'');
        end;
    end;
end;

procedure TShootersListBox.DrawItemSection (Index: Integer; ARect: TRect; State: TOwnerDrawState; ASection: THeadedListBoxSection; const AText: string);
var
	shf: TShootersFilterItem;
	sh: TShooterItem;
  s: string;
  w: integer;
  sr: TRect;
  fc: TColor;
begin
	shf:= fShootersFilter.Items [index];
	with ListBox.Canvas do
		begin
      fc:= Font.Color;
      Font:= ASection.Font;
      Font.Color:= fc;
			if (shf<> nil) and (shf.Shooter<> nil) then
				begin
					sh:= shf.Shooter;
					Brush.Style:= bsClear;
          if sh.Marked> 0 then
            begin
              if odSelected in State then
                Font.Color:= clYellow
              else
                begin
                  if shf.fInStart> 0 then
                    Font.Color:= clFuchsia
                  else if shf.fInStart= 0 then
                    Font.Color:= clFuchsia
                  else
                    Font.Color:= clRed;
                end;
            end
          else
            begin
              if shf.fInStart>= 0 then
                begin
                  if odSelected in State then
                    Font.Color:= clYellow
                  else
                    begin
                      if shf.fInStart= 0 then
                        Font.Color:= clNavy
                      else
                        Font.Color:= clBlue;
                    end;
                end;
            end;
          sr:= Rect (ARect.Left+ASection.Left,ARect.Top,ARect.Left+ASection.Right,ARect.Bottom);
          case ASection.Index of
            0: begin
              if sh.ImagesCount> 0 then
                Draw ((sr.Left+sr.Right-fPhotoBitmap.Width) div 2,(sr.Top+sr.Bottom-fPhotoBitmap.Height) div 2,fPhotoBitmap);
            end;
            1: begin
              if shf.fHasResults then
                Draw ((sr.Left+sr.Right-fResultsBitmap.Width) div 2,(sr.Top+sr.Bottom-fResultsBitmap.Height) div 2,fResultsBitmap);
            end;
            2: begin
              s:= sh.SurnameAndName;
              if (fCurrentSearchStr<> '') and (Index= ListBox.ItemIndex) then
                begin
                  Delete (s,1,Length (fCurrentSearchStr));
                  color:= Font.Color;
                  Font.Color:= clYellow;
                  Font.Style:= Font.Style + [fsUnderline];
                  TextRect (sr,sr.Left,sr.Top+5,fCurrentSearchStr);
                  w:= TextWidth (fCurrentSearchStr);
                  Font.Color:= color;
                  Font.Style:= Font.Style - [fsUnderline];
                  TextRect (sr,sr.Left+w,sr.Top+5,s);
                end
              else
                TextRect (sr,sr.Left,sr.Top+5,s);
            end;
            3: begin
							if sh.BirthFullStr<> '' then
								TextRect (sr,sr.Left,sr.Top+5,sh.BirthFullStr);
            end;
            4: begin
              TextRect (sr,sr.Left,sr.Top+5,sh.QualificationName);
            end;
            5: begin
      				TextRect (sr,sr.Left,sr.Top+5,sh.RegionAbbr1);
            end;
            6: begin
      				TextRect (sr,sr.Left,sr.Top+5,IntToStr (shf.Rating));
            end;
          end;
				end;
		end;
end;

function TShootersListBox.get_CurrentEvent: TEventItem;
begin
	Result:= fShootersFilter.Event;
end;

function TShootersListBox.get_MarkedShooterIdx(
	index: integer): TShootersFilterItem;
begin
	Result:= fShootersFilter.Marked [index];
end;

function TShootersListBox.get_Shooter(index: integer): TShootersFilterItem;
begin
	Result:= fShootersFilter.Items [index];
end;

function TShootersListBox.get_SortOrder: TShootersSortOrder;
begin
	Result:= fShootersFilter.SortOrder;
end;

procedure TShootersListBox.KeyDown(var Key: word; State: TShiftState);
begin
  case Key of
    VK_INSERT,VK_SPACE: begin
      Mark;
      Key:= 0;
    end;
		VK_SUBTRACT: begin
			MarkAll (false);
			Key:= 0;
		end;
		VK_ADD: begin
			MarkAll (true);
			Key:= 0;
		end;
		VK_MULTIPLY: begin
			MarkAllRated;
      if Assigned (fOnChangeMark) then
        fOnChangeMark (self);
			Key:= 0;
		end;
  else
    inherited;
  end;
end;

procedure TShootersListBox.KeyPress(var Key: char);
var
	s: string;
	idx: integer;
begin
	if Key> #32 then
		begin
			s:= fCurrentSearchStr+Key;
			idx:= fShootersFilter.Find (ListBox.ItemIndex,s);
			if idx>= 0 then
				begin
					fCurrentSearchStr:= s;
					ListBox.ItemIndex:= idx;
					ListBox.Invalidate;
				end;
		end
	else if Key= #10 then
		begin
			idx:= fShootersFilter.Find (ListBox.ItemIndex+1,fCurrentSearchStr);
			if idx>= 0 then
				begin
					ListBox.ItemIndex:= idx;
					ListBox.Invalidate;
				end;
		end
	else if Key= #8 then
		begin
			if fCurrentSearchStr<> '' then
				begin
					fCurrentSearchStr:= Copy (fCurrentSearchStr,1,Length (fCurrentSearchStr)-1);
					idx:= fShootersFilter.Find (0,fCurrentSearchStr);
					ListBox.ItemIndex:= idx;
					ListBox.Invalidate;
				end;
		end
	else
		begin
			fCurrentSearchStr:= '';
			ListBox.Invalidate;
      inherited;
		end;
end;

{
procedure TShootersListBox.LBKeyDown (Sender: TObject; var Key: word; State: TShiftState);
begin
  case Key of
    VK_INSERT,VK_SPACE: begin
      Mark;
      Key:= 0;
    end;
		VK_SUBTRACT: begin
			MarkAll (false);
			Key:= 0;
		end;
		VK_ADD: begin
			MarkAll (true);
			Key:= 0;
		end;
		VK_MULTIPLY: begin
			MarkAllRated;
      if Assigned (fOnChangeMark) then
        fOnChangeMark (self);
			Key:= 0;
		end;
  else
    KeyDown (Key,State);
  end;
end;
}

{
procedure TShootersListBox.LBKeyPress(Sender: TObject; var Key: Char);
var
	s: string;
	idx: integer;
begin
	if Key> #32 then
		begin
			s:= fCurrentSearchStr+Key;
			idx:= fShootersFilter.Find (0,s);
			if idx>= 0 then
				begin
					fCurrentSearchStr:= s;
					ListBox.ItemIndex:= idx;
					ListBox.Invalidate;
				end;
		end
	else if Key= #10 then
		begin
			idx:= fShootersFilter.Find (ListBox.ItemIndex+1,fCurrentSearchStr);
			if idx>= 0 then
				begin
					ListBox.ItemIndex:= idx;
					ListBox.Invalidate;
				end;
		end
	else if Key= #8 then
		begin
			if fCurrentSearchStr<> '' then
				begin
					fCurrentSearchStr:= Copy (fCurrentSearchStr,1,Length (fCurrentSearchStr)-1);
					idx:= fShootersFilter.Find (0,fCurrentSearchStr);
					ListBox.ItemIndex:= idx;
					ListBox.Invalidate;
				end;
		end
	else
		begin
			fCurrentSearchStr:= '';
			ListBox.Invalidate;
      KeyPress (Key);
		end;
end;
}

procedure TShootersListBox.Mark;
var
  sh: TShootersFilterItem;
begin
	if ListBox.ItemIndex>= 0 then
		begin
      sh:= fShootersFilter.Items [ListBox.ItemIndex];
      if sh.Shooter.Marked= 0 then
        sh.Shooter.Marked:= fShootersFilter.GetLastMarkedIndex+1
      else
  			sh.Shooter.Marked:= 0;
			if ListBox.ItemIndex< ListBox.Count-1 then
				ListBox.ItemIndex:= ListBox.ItemIndex+1
			else
				begin
					ListBox.ItemIndex:= -1;
					ListBox.ItemIndex:= ListBox.Count-1;
				end;
      if Assigned (fOnChangeMark) then
        fOnChangeMark (self);
		end;
end;

procedure TShootersListBox.MarkAll(Select: boolean);
begin
	fShootersFilter.MarkAll (Select);
  if Assigned (fOnChangeMark) then
    fOnChangeMark (self);
	ListBox.Invalidate;
end;

procedure TShootersListBox.MarkAllRated;
begin
	fShootersFilter.MarkAllRated;
  if Assigned (fOnChangeMark) then
    fOnChangeMark (self);
	Invalidate;
end;

function TShootersListBox.MarkedCount: integer;
begin
	Result:= fShootersFilter.MarkedCount;
end;

procedure TShootersListBox.LBMouseDown (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	idx: integer;
	s: TPoint;
begin
	// Сохраняем состояние клавиш для использования в обработчике двойного клика
	fLastClickShiftState:= Shift;
	
	idx:= ListBox.ItemAtPos (Point (x,y),true);
	if idx>= 0 then
		begin
			ListBox.ItemIndex:= idx;
			if Button= mbLeft then
				begin
{					if MarkedCount> 1 then
						DragCursor:= crMultiDrag
					else
						DragCursor:= crDrag;
					BeginDrag (false);}
				end
			else if Button= mbRight then
				begin
					if PopupMenu<> nil then
						begin
							s:= ClientToScreen (Point (x,y));
							PopupMenu.Popup (s.x,s.y);
						end;
				end;
		end;
end;

procedure TShootersListBox.Remove(AShooter: TShooterItem);
begin
	fShootersFilter.Remove (AShooter);
	UpdateListBox;
end;

procedure TShootersListBox.ResetSearch;
begin
  if fCurrentSearchStr<> '' then
    begin
      fCurrentSearchStr:= '';
      Invalidate;
    end;
end;

procedure TShootersListBox.set_CurrentEvent(const Value: TEventItem);
begin
	fShootersFilter.Event:= Value;
end;

procedure TShootersListBox.set_SortOrder(const Value: TShootersSortOrder);
begin
	fShootersFilter.SortOrder:= Value;
end;

procedure TShootersListBox.Sort;
var
  sh: TShootersFilterItem;
begin
  sh:= fShootersFilter.Items [ListBox.ItemIndex];
	fShootersFilter.Sort;
  if sh<> nil then
    ListBox.ItemIndex:= sh.Index;
  ResetSearch;
	Invalidate;
end;

procedure TShootersListBox.UpdateListBox;
begin
	while fShootersFilter.Count> ListBox.Count do
		ListBox.Items.Add ('');
	while fShootersFilter.Count< ListBox.Count do
		ListBox.Items.Delete (ListBox.Count-1);
end;

{ TShootersFilter }

function TShootersFilter.Add: TShootersFilterItem;
begin
	Result:= inherited Add as TShootersFilterItem;
end;

procedure TShootersFilter.Add(AShooter: TShooterItem);
var
	sh: TShootersFilterItem;
begin
	sh:= Add;
	sh.Shooter:= AShooter;
end;

procedure TShootersFilter.Add(AShooters: TShooters);
var
	i: integer;
begin
	for i:= 0 to AShooters.Count-1 do
		Add (AShooters [i]);
end;

constructor TShootersFilter.Create;
begin
	inherited Create (TShootersFilterItem);
	fSortOrder:= ssoNone;
end;

function TShootersFilter.Find(SearchFrom: integer; stt: string): integer;
var
	i: integer;
begin
	Result:= -1;
	for i:= SearchFrom to Count-1 do
		if AnsiStartsText (stt,Items [i].fShooter.Surname) then
			begin
				Result:= i;
				exit;
			end;
  if SearchFrom> 0 then
    begin
      for i:= 0 to SearchFrom-1 do
        if AnsiStartsText (stt,Items [i].fShooter.Surname) then
          begin
            Result:= i;
            exit;
          end;
    end;
end;

function TShootersFilter.FindItem(
	AShooter: TShooterItem): TShootersFilterItem;
var
	i: integer;
begin
	Result:= nil;
	for i:= 0 to Count-1 do
		if Items [i].Shooter= AShooter then
			begin
				Result:= Items [i];
				break;
			end;
end;

function TShootersFilter.GetLastMarkedIndex: integer;
var
  i: integer;
  sh: TShootersFilterItem;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.Shooter.Marked> Result then
        Result:= sh.Shooter.Marked;
    end;
end;

function TShootersFilter.get_MarkedShooterIdx(
	index: integer): TShootersFilterItem;
var
	i,c: integer;
begin
	Result:= nil;
	c:= -1;
	i:= 0;
	while (c< index) and (i< Count) do
		begin
			if Items [i].Shooter.Marked> 0 then
				inc (c);
			if c= Index then
				begin
					Result:= Items [i];
					break;
				end;
			inc (i);
		end;
end;

function TShootersFilter.get_ShooterIdx(
	index: integer): TShootersFilterItem;
begin
	if (index>= 0) and (index< Count) then
		Result:= inherited Items [index] as TShootersFilterItem
	else
		Result:= nil;
end;

procedure TShootersFilter.MarkAll (Marked: boolean);
var
	i: integer;
begin
	for i:= 0 to Count-1 do
		Items [i].Shooter.Marked:= byte (Marked);
end;

procedure TShootersFilter.MarkAllRated;
var
	i: integer;
begin
	for i:= 0 to Count-1 do
		Items [i].Shooter.Marked:= byte (Items [i].Rating> 0);
end;

function TShootersFilter.MarkedCount: integer;
var
	i: integer;
begin
	Result:= 0;
	for i:= 0 to Count-1 do
		if Items [i].Shooter.Marked> 0 then
			inc (Result);
end;

function TShootersFilter.MarkedIdx(index: integer): TShootersFilterItem;
var
  i: integer;
  sh: TShootersFilterItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.Shooter.Marked= index then
        begin
          Result:= sh;
          exit;
        end;
    end;
end;

procedure TShootersFilter.Remove(AShooter: TShooterItem);
var
	sh: TShootersFilterItem;
begin
	sh:= FindItem (AShooter);
	if sh<> nil then
		sh.Free;
end;

procedure TShootersFilter.set_CurrentEvent(const Value: TEventItem);
var
  i: integer;
  shf: TShootersFilterItem;
begin
  fCurrentEvent:= Value;
  for i:= 0 to Count-1 do
    begin
      shf:= Items [i];
      shf.fHasResults:= shf.Shooter.Results.ResultsInEvent (fCurrentEvent)> 0;
    end;
end;

procedure TShootersFilter.Sort;
var
	i,j: integer;
	sh1,sh2: TShootersFilterItem;
	cr: shortint;
begin
	if fSortOrder= ssoNone then
		exit;
	for i:= 0 to Count-2 do
		begin
			sh1:= Items [i];
			for j:= i+1 to Count-1 do
				begin
					sh2:= Items [j];
					case fSortOrder of
						ssoRating: begin
              cr:= Sign (sh2.Rating-sh1.Rating);
              if cr= 0 then
                begin
                  if (sh2.fHasResults) and (not sh1.fHasResults) then
                    cr:= 1
                  else if (not sh2.fHasResults) and (sh1.fHasResults) then
                    cr:= -1
                  else
                    cr:= 0;
                end;
            end;
					else
						cr:= sh2.Shooter.CompareTo (sh1.Shooter,fSortOrder);
					end;
					if cr> 0 then
						sh1:= sh2;
				end;
			if sh1.Index<> i then
				sh1.Index:= i;
		end;
end;

{ TShootersFilterItem }

constructor TShootersFilterItem.Create(ACollection: TCollection);
begin
	inherited;
  fInStart:= -1;
end;

function TShootersFilterItem.CSVStr: string;
begin
  if fShooter<> nil then
    Result:= fShooter.CSVStr+','+IntToStr (Rating)
  else
    Result:= '';
end;

function TShootersFilterItem.get_CurrentEvent: TEventItem;
begin
	Result:= (Collection as TShootersFilter).Event;
end;

function TShootersFilterItem.get_Rating: integer;
begin
	if CurrentEvent= nil then
		Result:= 0
	else
		begin
			if fShooter<> nil then
				Result:= fShooter.TotalRating [CurrentEvent]
			else
				Result:= 0;
		end;
end;

function TShootersFilterItem.RatingStr: string;
begin
	Result:= IntToStr (Rating);
end;

function TShootersListBox.GetLastClickShiftState: TShiftState;
begin
  Result:= fLastClickShiftState;
end;

end.

