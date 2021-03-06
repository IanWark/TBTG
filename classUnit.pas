unit classUnit;

interface
uses classTile, GameValues, classActValues,
    Classes, FMX.StdCtrls, FMX.Types, FMX.Objects, FMX.Graphics, FMX.Layouts,
    SysUtils, UITypes, Math;

type
  // TUnit is abstract class - DO NOT USE
  // Can't make this actually abstract it seems? just the methods
  TUnit = class(TRectangle)
  private
    cID : Integer;
    Tile : TTile;
    Selection : TCircle;
    Image: TImage;
    // Visual representation of remaining movement as colored circles
    MovementCircles : Array of TCircle;
    AttackCircles   : Array of TCircle;
    layCircles : TLayout;

    HealthBar : TRectangle;

    Team : Integer;
    isSelected : Boolean;

    HP   : Integer; // 0 HP and unit dies
    MP   : Integer; // Move Points left
    AP   : Integer; // Points left that can do actions

    MaxHP: Integer;
    MaxMP: Integer; // Max Move Points
    MaxAP: Integer; // Max Action Points
    DAM  : Integer; // Damage to enemy HP when attacking
    Range: Integer; // Range of attack (1 range can attack adjacent tiles)

    procedure OnUnitClick(Sender : TObject);
    procedure FriendlyClick;
    procedure HostileClick;
  published
    property ID : Integer
      read cID write cID;

    function CreateCircle : TCircle;
    constructor Create(AOwner : TComponent; newTeam : Integer; newID : Integer);
    destructor Destroy;
    procedure Select;
    procedure Deselect;

    procedure SetHP(newValue : Integer);
    procedure SetMP(newValue : Integer); dynamic;
    procedure SetAP(newValue : Integer);

    procedure Move(Destination : TTile; Cost : Integer);
    procedure AvailableActions;
    procedure SetAttackRectOnClick(EnemyTile : TTile);
    procedure SetAvailableAttacks(Friendly : TList; Hostile : TList);
    procedure Attack(Target : TUnit); virtual;

    procedure RecieveHit(Damage : Integer);
    procedure Die;

    procedure EndTurn;
    procedure AITurn;
  end;

  // Sword is tough, slow, meh damage
  TSword = class(TUnit)
    published
      constructor Create(AOwner : TComponent; newTeam : Integer; newID : Integer);
      procedure Attack(Target : TUnit); override;
  end;

  // Archer is fragile, slow, ok damage, but long ranged
  TArcher = class(TUnit)
    published
      constructor Create(AOwner : TComponent; newTeam : Integer; newID : Integer);
      procedure Attack(Target : TUnit); override;
  end;

  // Cavalry is fast and has a charge attack that deals extra damage if
  // there is a straight line between them and the target when attacking,
  // but is fragile in a straight fight
  TCavalry = class(TUnit)
    published
      constructor Create(AOwner : TComponent; newTeam : Integer; newID : Integer);
      procedure SetMP(newValue : Integer); override;
      procedure Attack(Target : TUnit); override;
  end;

implementation
uses Main;

procedure TUnit.OnUnitClick(Sender : TObject);
begin
  if Team = 1 then FriendlyClick
  else if Team = 2 then HostileClick;
end;

procedure TUnit.FriendlyClick;
var
  SelectedID : Integer;
begin
  if Assigned(SelectedUnit) then
  begin
    SelectedID := Main.SelectedUnit.ID;
    MainForm.Deselect;
    if ID <> SelectedID then Select;
  end
  else Select;
end;

procedure TUnit.HostileClick;
begin
  if Assigned(SelectedUnit) and Tile.Attackable then
  begin
    SelectedUnit.Attack(Self);
  end;
end;

// CONSTRUCT

// Used in constructor to create the movement and attack circles
function TUnit.CreateCircle : TCircle;
begin
  Result := TCircle.Create(layCircles);
  Result.Parent := layCircles;
  Result.Width := CircleSize;
  Result.Height:= CircleSize;
  Result.Margins.Left := CircleMargins;
  Result.Margins.Right:= CircleMargins;
  Result.Visible := True;
  Result.OnClick := OnUnitClick;
end;

constructor TUnit.Create(AOwner : TComponent; newTeam : Integer; newID : Integer);
var
  I: Integer;
  Circle : TCircle;
begin
  Inherited Create(AOwner);
  ID := newID;
  Team := newTeam;

  Fill.Color := ColorNull;
  Stroke.Kind := TBrushKind.None;

  Align := TAlignLayout.Center;
  Width  := UnitWidth ;
  Height := UnitHeight;
  Visible := True;
  OnClick := OnUnitClick;

  // Selection circle
  Selection := TCircle.Create(Self);
  Selection.Parent := Self;
  Selection.Align := TAlignLayout.Contents;
  Selection.Fill.Kind := TBrushKind.None;
  Selection.Stroke.Thickness := ThicknessUnselected;
  Selection.OnClick := OnUnitClick;
  isSelected := False;

  Team := newTeam;
  if Team = 1 then Selection.Stroke.Color := ColorTeam1
  else
  if Team = 2 then Selection.Stroke.Color := ColorTeam2
  else Selection.Stroke.Color := ColorTeam3;

  // Create layout where point circles go (bottom of unit)
  layCircles := TLayout.Create(Self);
  layCircles.Parent := Self;

  layCircles.Align := TAlignLayout.Bottom;
  layCircles.Height := CircleSize;
  layCircles.Margins.Left := CircleLayoutMargins;
  layCircles.Margins.Right := CircleLayoutMargins;
  layCircles.Margins.Bottom := CircleLayoutMargins;;
  layCircles.Visible := True;

  // Create movement point circles (bottom left of unit)
  SetLength(MovementCircles, MaxMP);
  for I := 0 to MaxMP-1 do
  begin
    Circle := CreateCircle;
    Circle.Align:= TAlignLayout.Left;
    Circle.Fill.Color := ColorMovementCircle;

    MovementCircles[I] := Circle;
  end;

  // Create attack point circles (bottom right of unit)
  SetLength(AttackCircles, MaxAP);
  for I := 0 to MaxAP-1 do
  begin
    Circle := CreateCircle;
    Circle.Align := TAlignLayout.Right;
    Circle.Fill.Color := ColorAttackCircle;

    AttackCircles[I] := Circle;
  end;

  HealthBar := TRectangle.Create(Self);
  HealthBar.Parent := Self;
  HealthBar.Align := TAlignLayout.Top;
  HealthBar.Height := HealthBarHeight;
  HealthBar.Fill.Color := ColorHealthBar;
  HealthBar.Visible := True;
  HealthBar.OnClick := OnUnitClick;

  Image := TImage.Create(Self);
  Image.Parent := Self;
  Image.Align  := TAlignLayout.Contents;
  Image.Margins.Left := ImageMargins;
  Image.Margins.Right:= ImageMargins;
  Image.Margins.Top := ImageMargins;
  Image.Margins.Bottom := ImageMargins;
  Image.Visible:= True;
  Image.OnClick := OnUnitClick;
  Image.SendToBack;
end;

destructor TUnit.Destroy;
var
  I : Integer;
begin
  //Selection.Destroy;
  //Image.Destroy;
  //HealthBar.Destroy;

  for I := 0 to length(MovementCircles)-1 do
  begin
    MovementCircles[I].Destroy;
  end;
  for I := 0 to length(AttackCircles)-1 do
  begin
    AttackCircles[I].Destroy;
  end;

  Inherited;
end;

procedure TUnit.Select;
begin
  IsSelected := True;
  SelectedUnit := Self;
  Selection.Stroke.Thickness := ThicknessSelected;

  AvailableActions;
end;

procedure TUnit.Deselect;
begin
  IsSelected := False;
  SelectedUnit := nil;
  Selection.Stroke.Thickness := ThicknessUnselected;

  World.ClearAvailableMoves;
  World.ClearAvailableAttacks;
  World.ClearDistances;
end;

// SET VALUES
// Used in RecieveHit
procedure TUnit.SetHP(newValue: Integer);
begin
  HP := newValue;
  // Move bar by Percent Damage Taken * UnitWidth  away from full
  HealthBar.Margins.Right := ((MaxHP - HP)/MaxHP)*(UnitWidth);
end;

// Used in Move, TUnit.EndTurn
procedure TUnit.SetMP(newValue: Integer);
var
  I: Integer;
begin
  MP := newValue;

  for I := 0 to Length(MovementCircles)-1 do
  begin
    if newValue > 0 then MovementCircles[I].Visible := True
    else MovementCircles[I].Visible := False;
    newValue := newValue - 1;
  end;
end;

// Used in Attack, TUnit.EndTurn
procedure TUnit.SetAP(newValue: Integer);
var
  I: Integer;
begin
  AP := newValue;

  for I := 0 to Length(AttackCircles)-1 do
  begin
    if newValue > 0 then AttackCircles[I].Visible := True
    else AttackCircles[I].Visible := False;
    newValue := newValue - 1;
  end;
end;

// Move unit to destination tile
// Cost is cost to move points
procedure TUnit.Move(Destination : TTile; Cost : Integer);
begin
  if MP >= Cost then
  begin
    // Old tile is empty
    if Assigned(Tile) then Tile.HasUnit := False;

    Tile := Destination;
    // New tile has unit
    Tile.HasUnit := True;
    Parent := Tile;

    SetMP(MP - Cost);

    if Assigned(SelectedUnit) then AvailableActions;
  end;
end;

// Recalculate tile values
procedure TUnit.AvailableActions;
var
  RangeVals : TActValues;
  DistVals : TActValues;
begin
  World.ClearAvailableMoves;
  World.ClearAvailableAttacks;
  World.ClearDistances;

  Tile.MoveDistFromSelected := 0;
  Tile.ATKDistFromSelected := 0;

  RangeVals := TActValues.Create(Range, MP);

  Tile.GetTileDistances(RangeVals, 0, AP, Self.ClassName, Tile);

  if Team = 1 then SetAvailableAttacks(Main.Team1, Main.Team2)
  else
  if Team = 2 then SetAvailableAttacks(Main.Team2, Main.Team1);
end;

// Used in SetAvailableAttacks
procedure TUnit.SetAttackRectOnClick(EnemyTile : TTile);
begin
  if Assigned(EnemyTile.AttackRect) then EnemyTile.AttackRect.OnClick := OnUnitClick;
end;

// Used in AvailableActions
procedure TUnit.SetAvailableAttacks(Friendly : TList; Hostile : TList);
var
  oldX : Extended;
  oldY : Extended;
  X: Extended;
  Y: Extended;
  ATKDist : Integer;
  Angle : Extended;
  AngleIncAmt : Extended;

  xs : Single;
  ys : Single;

  I: Integer;
  CurrUnit : TUnit;
  CurrTile : TTile;
begin
  // No AP left means no attack
  if AP > 0 then
  begin
      Angle := 0;
      if Self.ClassName = 'TCavalry'
      then AngleIncAmt := 90
      else AngleIncAmt := 10;

      // for every angle:
      // Go forward until out of range, leaving world, or touching mountain (can't shoot through mountain)
      // lay down a AttackRect for for each reachable tile to show which tiles are in range
      while Angle < 360 do
      begin
        // move a step
        X := Tile.Coords.X + cos(DegToRad(Angle));
        Y := Tile.Coords.Y + sin(DegToRad(Angle));

        // Calculate number of tiles traveled
        ATKDist := Trunc(sqrt(sqr( Trunc(X) - Tile.Coords.X ))
                   + sqrt(sqr( Trunc(Y) - Tile.Coords.Y )) );

        while ((X >= 0) and (X < World.XSize))
          and ((Y >= 0) and (Y < World.YSize))
        do begin
          CurrTile := World.GetTile(Trunc(X), Trunc(Y));
          if not Assigned(CurrTile.AttackRect)
             and (ATKDist <= Range)
          then CurrTile.SetAttackRect;

          if (CurrTile.ATKDistFromSelected < 0) or
             (CurrTile.ATKDistFromSelected > ATKDist)
          then CurrTile.ATKDistFromSelected := ATKDist;

          oldX := X;
          oldY := Y;
          // move a step
          X := X + cos(DegToRad(Angle));
          Y := Y + sin(DegToRad(Angle));
          // Calculate number of tiles traveled
          ATKDist := ATKDist
          + Trunc(sqrt(sqr( Trunc(X) - Trunc(oldX) )) + sqrt(sqr( Trunc(Y) - Trunc(oldY) )));

          // if at end of range or touch mountain, color this one, then end loop
          if (CurrTile.ATKDistFromSelected = Range)
          or (CurrTile.Terrain = iMountain)
          then Y := -1;
        end;

        Angle := Angle + AngleIncAmt;
      end;

      // Go through hostile team to look for which are in range
      for I := 0 to Hostile.Count-1 do
      begin
        CurrUnit := TUnit(Hostile[I]);
        CurrTile := CurrUnit.Tile;

        if ((CurrTile.ATKDistFromSelected <> -1)
        and (CurrTile.ATKDistFromSelected <= Range)) then
        begin
          CurrUnit.SetAttackRectOnClick(CurrTile);

          CurrTile.Attackable := True;
        end;
      end;
      // Go through friendly and make sure no allies are lit up in red
      for I := 0 to Friendly.Count-1 do
      begin
        CurrUnit := TUnit(Friendly[I]);
        CurrTile := CurrUnit.Tile;
        if Assigned(CurrTile.AttackRect) then
        begin
          CurrTile.AttackRect.Parent := nil;
          CurrTile.AttackRect.OnClick := nil;
          CurrTile.AttackRect := nil;
        end;
      end;
  end;
end;

procedure TUnit.Attack(Target: TUnit);
begin
  SetAP(AP - 1);
  // Character's turn ends after attacking
  SetMP(0);
  // TODO possibly attack animation?
  Target.RecieveHit(DAM);
end;

procedure TUnit.RecieveHit(Damage: Integer);
begin
  SetHP(HP - Damage);
  // TODO possibly damage animation?

  if HP <= 0 then
  begin
    Die;
  end;
end;

procedure TUnit.Die;
begin
  Tile.HasUnit := False;
  MainForm.RemoveFromTeam(Self, Team);
  if isSelected then SelectedUnit := nil;
  Self.Visible := False;

  // TODO Occasional Error when unit dies
  //Destroy;
end;

procedure TUnit.EndTurn;
var
  IsAdjacentEnemy : Boolean;
  Enemy : TUnit;
  I : Integer;
begin
  // If there is an adjacent enemy, you can only move IfAdjacentEnemyMP
  IsAdjacentEnemy := False;
  if Team = 1 then
  begin
    for I := 0 to Team2.Count-1 do
    begin
      Enemy := Team2[I];
      if (Enemy.Tile.North = Tile) or
         (Enemy.Tile.East = Tile) or
         (Enemy.Tile.South = Tile) or
         (Enemy.Tile.West = Tile) then
      IsAdjacentEnemy := True;
    end;
  end
  else
  if Team = 2 then
    begin
    for I := 0 to Team1.Count-1 do
    begin
      Enemy := Team1[I];
      if (Enemy.Tile.North = Tile) or
         (Enemy.Tile.East = Tile) or
         (Enemy.Tile.South = Tile) or
         (Enemy.Tile.West = Tile) then
      IsAdjacentEnemy := True;
    end;
  end;

  if IsAdjacentEnemy then SetMP(IfAdjacentEnemyMP)
  else SetMP(MaxMP);

  SetAP(MaxAP);
end;

// Find closest enemy, move towards it, and attack it
procedure TUnit.AITurn;
var
  I: Integer;
  CurrUnit : TUnit;
  ClosestUnit : TUnit;
  CurrTile : TTile;
  BestTile : TTile;
  MPToMove : Integer;
begin
  if Team1.Count = 0 then exit;   // If no enemies, stop

  AvailableActions;
  // Figure out which enemy is closest
  ClosestUnit := Team1[0];
  for I := 1 to Team1.Count-1 do
  begin
    CurrUnit := TUnit(Team1[I]);
    if CurrUnit.Tile.MoveDistFromSelected < ClosestUnit.Tile.MoveDistFromSelected then
    begin
      ClosestUnit := CurrUnit;
    end;
  end;
  while MP > 0 do
  begin
    // Don't move if adjacent to enemy
    for I := 0 to Tile.Neighbours.Count-1 do
    begin
      if ClosestUnit.Tile = Tile.Neighbours[I] then
      begin
         SetMP(0);
         Break;
      end;
    end;

    // Find distances relative to target
    ClosestUnit.AvailableActions;

    // Move to adjacent tile with smallest distance to target
    MPToMove := MP;
    BestTile := Self.Tile;

    for I := 0 to Tile.Neighbours.Count-1 do
    begin
      if Assigned(Tile.Neighbours[I]) then
      begin
        CurrTile := Tile.Neighbours[I];

        if CurrTile.MoveDistFromSelected = -1 then
        begin
          CurrTile := CurrTile;
        end;

        if (CurrTile.MoveDistFromSelected < BestTile.MoveDistFromSelected) then
        begin
          BestTile := CurrTile;
        end;
      end;
    end;

    if Assigned(BestTile) and (not BestTile.HasUnit) then
    begin
      case BestTile.Terrain of
        iGrass : MPToMove := 1;
        iRiver : MPToMove := 2;
        iMountain : MPToMove := 2;
      end;

      if MPToMove <= MP then
      begin
        Move(BestTile, MPToMove);
      end
      else SetMP(0);
    end
    else SetMP(0);

    // Find distances relative to Self
    AvailableActions;
    if ClosestUnit.Tile.Attackable then
    begin
      Attack(ClosestUnit);
    end;
  end;

  // if world is not assigned it means the game is over
  if Assigned(World) then
  begin
    World.ClearAvailableMoves;
    World.ClearAvailableAttacks;
    World.ClearDistances;

    EndTurn;
  end;

end;

constructor TSword.Create(AOwner: TComponent; newTeam : Integer; newID : Integer);
begin
  HP    := SwordHP;
  MP    := SwordMP;
  AP    := SwordAP;

  MaxHP := SwordHP;
  MaxMP := SwordMP;
  MaxAP := SwordAP;
  DAM   := SwordDAM;
  Range := SwordRange;

  Inherited Create(AOwner, newTeam, newID);

  Image.Bitmap.Assign(MainForm.imageSword.Bitmap);
end;

procedure TSword.Attack(Target : TUnit);
begin
  Inherited Attack(Target);
  Deselect;
end;

constructor TArcher.Create(AOwner: TComponent; newTeam: Integer; newID: Integer);
begin
  HP    := ArcherHP;
  MP    := ArcherMP;
  AP    := ArcherAP;

  MaxHP := ArcherHP;
  MaxMP := ArcherMP;
  MaxAP := ArcherAP;
  DAM   := ArcherDAM;
  Range := ArcherRange;

  Inherited Create(AOwner, newTeam, newID);

  Image.Bitmap.Assign(MainForm.imageArcher.Bitmap);
end;

procedure TArcher.Attack(Target : TUnit);
begin
  Inherited Attack(Target);
  Deselect;
end;

constructor TCavalry.Create(AOwner: TComponent; newTeam: Integer; newID: Integer);
begin
  HP    := CavalryHP;
  MP    := CavalryMP;
  AP    := CavalryAP;

  MaxHP := CavalryHP;
  MaxMP := CavalryMP;
  MaxAP := CavalryAP;
  DAM   := CavalryDAM;
  Range := CavalryMP + 1;

  Inherited Create(AOwner, newTeam, newID);

  Image.Bitmap.Assign(MainForm.imageCavalry.Bitmap);
end;

procedure TCavalry.SetMP(newValue: Integer);
begin
  Inherited SetMP(newValue);
  Range := newValue + 1;
end;

procedure TCavalry.Attack(Target: TUnit);
begin
  if Tile.IsLineTo(Target.Tile) then
  begin
    // Move infront of target
    // Target is East
    if Target.Tile.Coords.X > Self.Tile.Coords.X then Move(Target.Tile.West, 0)
    // Target is West
    else if Target.Tile.Coords.X < Self.Tile.Coords.X then Move(Target.Tile.East, 0)
    // Target is South
    else if Target.Tile.Coords.Y > Self.Tile.Coords.Y then Move(Target.Tile.North, 0)
    // Target is North
    else if Target.Tile.Coords.Y < Self.Tile.Coords.Y then Move(Target.Tile.South, 0);

    Inherited Attack(Target);

    // Deal extra damage based on distance traveled
    // (-1 is because target is always atleast 1 away)
    Target.RecieveHit(Target.Tile.ATKDistFromSelected - 1);
    Deselect;
  end;
end;

end.
