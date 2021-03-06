unit Main;

interface
uses classWorld, classUnit, classTile, GameValues, Tutorial,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ExtCtrls, FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation,

  {$IFDEF MSWINDOWS}
    Winapi.Windows, FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.ListBox
  {$ENDIF}
  ;

type
  TMainForm = class(TForm)
    Background: TRectangle;
    ImageSword: TImageControl;
    bEndTurn: TButton;
    layBottom: TLayout;
    ImageArcher: TImageControl;
    DragRectangle: TRectangle;
    ImageCavalry: TImageControl;
    menuCustomGame: TPanel;
    eWorldX: TNumberBox;
    layCustWorldX: TLayout;
    lWorldX: TLabel;
    layCustWorldY: TLayout;
    eWorldY: TNumberBox;
    lWorldY: TLabel;
    layCustTeam2: TLayout;
    eTeam2: TNumberBox;
    lTeam2: TLabel;
    layCustTeam1: TLayout;
    eTeam1: TNumberBox;
    lTeam1: TLabel;
    bCustNext: TButton;
    layCustButtons: TLayout;
    layMenu: TLayout;
    bCustBack: TButton;
    Label1: TLabel;
    menuMain: TPanel;
    lTitle: TLabel;
    bCustomGame: TButton;
    layMainButtons: TLayout;
    layTop: TLayout;
    bQuit: TButton;
    panelResultScreen: TPanel;
    lResultScreen: TLabel;
    layResultScreen: TLayout;
    menuSelectUnits: TPanel;
    StyleBook1: TStyleBook;
    lbSelectUnits: TListBox;
    laySelectButtons: TLayout;
    bSelectBack: TButton;
    bSelectStart: TButton;
    cbUnitTypes: TComboBox;
    Sword: TListBoxItem;
    Archer: TListBoxItem;
    Cavalry: TListBoxItem;
    bSelectAdd: TButton;
    Layout1: TLayout;
    bTutorial: TButton;
    menuTutorial: TPanel;
    lTutorial: TLabel;
    rectTutorialPage1: TRectangle;
    lTutorialPage1: TLabel;
    layTutButtons: TLayout;
    tutNext: TButton;
    tutBack: TButton;
    lTutorialPage2: TLabel;
    rectTutorialPage2: TRectangle;
    ImageTutorialUnit: TImageControl;
    rectTutorialPage3: TRectangle;
    lTutorialPage3: TLabel;
    rectTutSword: TRectangle;
    layTutSword: TLayout;
    lTutSword: TLabel;
    layTutArcher: TLayout;
    rectTutArcher: TRectangle;
    lTutArcher: TLabel;
    layTutCavalry: TLayout;
    rectTutCavalry: TRectangle;
    lTuTCavalry: TLabel;
    rectTutorialPage4: TRectangle;
    lTutorialPage4: TLabel;
    layTutGrass: TLayout;
    rectTutGrass: TRectangle;
    lTutGrass: TLabel;
    layTutRiver: TLayout;
    rectTutRiver: TRectangle;
    lTutRiver: TLabel;
    layTutMountain: TLayout;
    rectTutMountain: TRectangle;
    lTutMountain: TLabel;
    procedure FormCreate(Sender: TObject);

    // Menu Buttons
    procedure bCustomGameClick(Sender: TObject);
    procedure bTutorialClick(Sender: TObject);

    procedure bCustBackClick(Sender: TObject);
    procedure bCustNextClick(Sender: TObject);

    procedure tutBackClick(Sender: TObject);

    procedure UpdateUnitListCount;
    procedure bSelectAddClick(Sender: TObject);
    procedure lbSelectUnitsItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);

    procedure bSelectBackClick(Sender: TObject);
    // Start custom game
    procedure bSelectStartClick(Sender: TObject);

    procedure panelResultScreenClick(Sender: TObject);

    procedure StartNewGame;

    function GetStartTile(Team : Integer) : TTile;

//    procedure MouseDown(Sender: TObject; Button: TMouseButton;
//      Shift: TShiftState; X, Y: Single);
//    procedure MouseEndDrag;
//    procedure MouseMove(Sender: TObject; Shift: TShiftState; X,
//      Y: Single);
//    procedure MouseUp(Sender: TObject; Button: TMouseButton;
//      Shift: TShiftState; X, Y: Single);
//    procedure MouseEnter(Sender: TObject);

    // Clicks
    procedure bEndTurnClick(Sender: TObject);
    procedure BackgroundClick(Sender: TObject);
    procedure bQuitClick(Sender: TObject);
    procedure tutNextClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure Deselect;
    procedure Print(Text : String);
    procedure EndGame;
    procedure RemoveFromTeam(Removed : TUnit; Team : Integer);
  end;

var
  MainForm: TMainForm;
  World : TWorld;
  Team1 : TList;
  Team2 : TList;
  SelectedUnit : TUnit;
  StartX : Single;
  StartY : Single;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Background.SendToBack;
  //Background.OnMouseDown := MouseDown;
  Tutorial.setTutorialLabels;
end;

// Menu Buttons
// menuMain to menuCustomGame
procedure TMainForm.bCustomGameClick(Sender: TObject);
begin
  menuMain.Visible := False;
  menuCustomGame.Visible := True;
end;

// menuMain to menuTutorial
procedure TMainForm.bTutorialClick(Sender: TObject);
begin
  menuMain.Visible := False;
  menuTutorial.Visible := True;
  rectTutorialPage1.Visible := True;
  rectTutorialPage2.Visible := False;
  rectTutorialPage3.Visible := False;
  rectTutorialPage4.Visible := False;
  Tutorial.currentPage := 1;
end;

// menuCustomGame to menuMain
procedure TMainForm.bCustBackClick(Sender: TObject);
begin
  menuCustomGame.Visible := True;
  menuMain.Visible := True;
end;

// menuCustomGame to menuSelectUnits
procedure TMainForm.bCustNextClick(Sender: TObject);
var
  Item : TListBoxItem;
  I: Integer;
begin
  lbSelectUnits.Clear;
  UpdateUnitListCount;

  menuCustomGame.Visible := False;
  menuSelectUnits.Visible := True;
end;

// go back a page in tutorial
procedure TMainForm.tutBackClick(Sender: TObject);
begin
  Tutorial.backPage;
end;

// go to next page of tutorial
procedure TMainForm.tutNextClick(Sender: TObject);
begin
  Tutorial.nextPage;
end;

// Used in bCustNextClick, bSelectAddClick, lbSelectUnitsItemClick
procedure TMainForm.UpdateUnitListCount;
begin
  bSelectAdd.Text := lbSelectUnits.Count.ToString+'/'+eTeam1.Text;
end;

procedure TMainForm.bSelectAddClick(Sender: TObject);
var
  Item : TListBoxItem;
  Valid: Boolean;
begin
  bSelectAdd.FontColor := TAlphaColorRec.Black;
  // If at or above limit don't do anything
  // if not Infantry, Archer or Cavalry, also doesn't do anything
  if Assigned(cbUnitTypes.Selected) then
  begin
    Valid := False;
    if lbSelectUnits.Count < Trunc(eTeam1.Value) then
    begin
      Item := TListBoxItem.Create(lbSelectUnits);
      Item.StyleLookup := 'UnitListBoxItem';
      if cbUnitTypes.Selected.Text = 'Infantry' then
      begin
        Item.ItemData.Bitmap := ImageSword.Bitmap;
        Valid := True;
      end
      else
      if cbUnitTypes.Selected.Text = 'Archer' then
      begin
        Item.ItemData.Bitmap := ImageArcher.Bitmap;
        Valid := True;
      end
      else
      if cbUnitTypes.Selected.Text = 'Cavalry' then
      begin
        Item.ItemData.Bitmap := ImageCavalry.Bitmap;
        Valid := True;
      end;

      if Valid then
      begin
        Item.Text := cbUnitTypes.Selected.Text;
        lbSelectUnits.AddObject(Item);
        UpdateUnitListCount;
      end;
    end;
  end;
end;

procedure TMainForm.lbSelectUnitsItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  Sender.Items.Delete(Item.Index);
  UpdateUnitListCount;
end;

// menuSelectUnits to menuCustomGame
procedure TMainForm.bSelectBackClick(Sender: TObject);
begin
  menuSelectUnits.Visible := False;
  menuCustomGame.Visible := True;
end;

// Start custom game
procedure TMainForm.bSelectStartClick(Sender: TObject);
begin
  bSelectAdd.FontColor := TAlphaColorRec.Black;
  if lbSelectUnits.Count = Trunc(eTeam1.Value) then
  begin
    StartNewGame;
  end
  else
  begin
    bSelectAdd.FontColor := TAlphaColorRec.Red;
  end;
end;

procedure TMainForm.StartNewGame;
var
  UnitString : String;
  CurrUnit : TUnit;
  I : Integer;
  LongestSide : Single;
  Zoom : Single;

  Roll : Integer;

  CurrTile : TTile;
begin
  // Get values from menu
  WorldX := Trunc(eWorldX.Value);
  WorldY := Trunc(eWorldY.Value);
  Team1UnitsNum := Trunc(eTeam1.Value);
  Team2UnitsNum := Trunc(eTeam2.Value);

  // Get rid of any menus
  menuMain.Visible := False;
  menuCustomGame.Visible := False;
  bQuit.Visible := True;

  // Create world
  World := TWorld.Create(Self, WorldX, WorldY);
  World.Parent := Self;

  // Zoom out to fit entire world
  if (World.Height > MainForm.Height) or (World.Width > MainForm.Width)  then
  begin
    if World.Height > World.Width then
    begin
      Zoom := MainForm.Height / (World.Height * ExtraSpaceMultiplier);
    end
    else
    begin
      Zoom := MainForm.Width / (World.Width * ExtraSpaceMultiplier);
    end;
    World.Scale.X := Zoom;
    World.Scale.Y := Zoom;
  end;

  World.Align := TAlignLayout.Center;
  World.Align := TAlignLayout.None;

  //World.OnMouseDown := MouseDown;

  // Create teams
  // Player team is selected
  Team1 := TList.Create;
  for I := 0 to Team1UnitsNum-1 do
  begin
    UnitString := lbSelectUnits.ListItems[i].Text;

    if UnitString = 'Infantry' then CurrUnit := TSword.Create(Self, 1, I)
    else if UnitString = 'Archer' then CurrUnit := TArcher.Create(Self, 1, I)
    else if UnitString = 'Cavalry' then CurrUnit := TCavalry.Create(Self, 1, I)
    else
    begin
      ShowMessage('Error in Player team creation');
      Application.Terminate();
    end;

    CurrUnit.Parent := Self;
    CurrUnit.Move(GetStartTile(1),0);
    Team1.Insert(I, CurrUnit);
  end;

  // Enemy team is random
  Team2 := TList.Create;
  for I := 0 to Team2UnitsNum-1 do
  begin
    Roll := Random(3);
    if Roll = 0 then CurrUnit := TSword.Create(Self, 2, I)
    else if Roll = 1 then CurrUnit := TArcher.Create(Self, 2, I)
    else if Roll = 2 then CurrUnit := TCavalry.Create(Self, 2, I);

    CurrUnit.Parent := Self;
    CurrUnit.Move(GetStartTile(2),0);
    Team2.Insert(I, CurrUnit);
  end;

  layBottom.BringToFront;
  bEndTurn.Visible := True;
  bEndTurn.BringToFront;
end;

// Try to get random tile close to team's side and not on mountain, river, or other unit
function TMainForm.GetStartTile(Team : Integer) : TTile;
var
  InvalidTile : Boolean;
  YPos : Integer;
  Attempts : Integer;
begin
  if Team = 1 then YPos := WorldY-1
  else YPos := 0;

  Attempts := 0;
  InvalidTile := True;
  while InvalidTile do
  begin
    if Attempts > 50 then
    begin
      if Team = 1 then YPos := YPos - 1
      else YPos := YPos + 1;
      Attempts := 0;
    end;

    Result := World.GetTile(Random(WorldX),YPos);
    if (not Assigned(Result)) or Result.HasUnit
    or (Result.Terrain = iMountain) or (Result.Terrain = iRiver)
    then
    begin
      InvalidTile := True;
      Attempts := Attempts + 1;
    end
    else InvalidTile := False;
  end;
end;

// Mouse stuff
// http://docwiki.embarcadero.com/CodeExamples/Berlin/en/OnMouseMove_(Delphi)
//// Currently not used
//procedure TMainForm.MouseDown(Sender: TObject; Button: TMouseButton;
//  Shift: TShiftState; X, Y: Single);
//begin
//  if GetKeyState(VK_LBUTTON) < 0 then
//  begin
//    StartX := X;
//    StartY := Y;
//
//    DragRectangle.Visible := True;
//    DragRectangle.BringToFront;
//  end;
//end;
//
//procedure TMainForm.MouseEndDrag;
//begin
//  DragRectangle.Visible := False;
//end;
//
//procedure TMainForm.MouseMove(Sender: TObject; Shift: TShiftState; X,
//  Y: Single);
//begin
//  if GetKeyState(VK_LBUTTON) < 0 then
//  begin
//    if StartX > X then World.Position.X := World.Position.X - DragSpeed
//    else
//    if StartX < X then World.Position.X := World.Position.X + DragSpeed;
//    if StartY > Y then World.Position.Y := World.Position.Y - DragSpeed
//    else
//    if StartY < Y then World.Position.Y := World.Position.Y + DragSpeed;
//
////    World.Position.X := World.Position.X + (X - StartX)/4;
////    World.Position.Y := World.Position.Y + (Y - StartY)/4;
//
//    StartX := X;
//    StartY := Y;
//  end
//  else
//  begin
//    MouseEndDrag;
//  end;
//end;
//
//procedure TMainForm.MouseUp(Sender: TObject; Button: TMouseButton;
//  Shift: TShiftState; X, Y: Single);
//begin
//  MouseEndDrag;
//end;
//
//procedure TMainForm.MouseEnter(Sender: TObject);
//begin
//  if not GetKeyState(VK_LBUTTON) < 0 then
//  begin
//    MouseEndDrag;
//  end;
//end;


// CLICKS

procedure TMainForm.bEndTurnClick(Sender: TObject);
var
  I: Integer;
begin
  Deselect;
  for I := 0 to Team1.Count-1 do
  begin
    TUnit(Team1.Items[I]).EndTurn;
  end;
  for I := 0 to Team2.Count-1 do
  begin
    TUnit(Team2.Items[I]).AITurn;
  end;
end;

procedure TMainForm.bQuitClick(Sender: TObject);
begin
  EndGame;
end;

procedure TMainForm.BackgroundClick(Sender: TObject);
begin
  Deselect;
end;

procedure TMainForm.panelResultScreenClick(Sender: TObject);
begin
  EndGame;
end;

procedure TMainForm.Deselect;
begin
  if Assigned(SelectedUnit) then
  begin
    SelectedUnit.Deselect;
  end;
end;

procedure TMainForm.Print(Text: string);
begin
  ShowMessage(Text);
end;

procedure TMainForm.EndGame;
begin
  World.Destroy;
  menuMain.Visible := True;
  layResultScreen.Visible := False;
  bQuit.Visible := False;
  bEndTurn.Visible := False;
end;

procedure TMainForm.RemoveFromTeam(Removed: TUnit; Team : Integer);
var
  Curr : TUnit;
  I: Integer;
begin
  if Team = 1 then
  begin
    for I := 0 to Team1.Count-1 do
    begin
      Curr := Team1[I];
      if Curr.ID = Removed.ID then
      begin
        Team1.Delete(I);
        Break;
      end;
    end;
    if Team1.Count = 0 then
    begin
      lResultScreen.Text := 'You Lose!';

      layResultScreen.Visible := True;
      layResultScreen.BringToFront;
      lResultScreen.BringToFront;
    end;
  end

  else
  if Team = 2 then
  begin
    for I := 0 to Team2.Count-1 do
    begin
      Curr := Team2[I];
      if Curr.ID = Removed.ID then
      begin
        Team2.Delete(I);
        Break;
      end;
    end;
    if Team2.Count = 0 then
    begin
      lResultScreen.Text := 'You Win!';
      layResultScreen.Visible := True;
      layResultScreen.BringToFront;
      lResultScreen.BringToFront;
    end;
  end;
end;

end.
