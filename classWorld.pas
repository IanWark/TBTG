unit classWorld;

interface
uses classTile, GameValues,
    Classes, FMX.Objects, FMX.Types, SysUtils;

type

  // YSize array of XSize arrays make up the world
  TWorld = class(TRectangle)
  private
    WorldArray : Array of Array of TTile;

    cXSize : Integer;
    cYSize : Integer;

    AvailableMoves : Array of TCircle;
    cAvailableMovesShown : Integer;
    AvailableAttacks : Array of TRectangle;
    cAvailableAttacksShown : Integer;
  published
    property XSize : Integer
      read cXSize;
    property YSize : Integer
      read cYSize;

    property AvailableMovesShown : Integer
      read cAvailableMovesShown write cAvailableMovesShown;
    property AvailableAttacksShown : Integer
      read cAvailableAttacksShown write cAvailableAttacksShown;

    constructor Create(AOwner : TComponent; _XSize : Integer; _YSize : Integer);
    procedure GenerateMountains;
    procedure GenerateRivers;
    function GetAvailableMove : TCircle;
    function GetAvailableAttack : TRectangle;
    procedure ClearAvailableMoves;
    procedure ClearAvailableAttacks;
    procedure ClearDistances;
    function GetTile(X : Integer; Y : Integer) : TTile;
  end;

implementation
uses Main;

// TWorld is array of arrays like
// [[0, 0, 0]
//  [0, 0, 0]]
// Where World Array is parent array and so in Y dimension
// and the child arrays are in X dimension
constructor TWorld.Create(AOwner : TComponent; _XSize: Integer; _YSize: Integer);
var
  Y: Integer;
  X: Integer;
  NewTile : TTile;
begin
  Inherited Create(AOwner);
  cXSize := _XSize;
  cYSize := _YSize;
  Width  := XSize * TileWidth;
  Height := YSize * TileHeight;
  Visible := True;

  SetLength(WorldArray, YSize);
  for Y := 0 to YSize-1 do
  begin
    SetLength(WorldArray[Y], XSize);
    for X := 0 to XSize-1 do
    begin
      NewTile := TTile.Create(Self, X, Y);
      NewTile.Parent := Self;

      if Y > 0 then NewTile.SetNorth(WorldArray[Y-1][X]);
      if X > 0 then NewTile.SetWest(WorldArray[Y][X-1]);

      WorldArray[Y][X] := NewTile;
    end;
  end;

  GenerateMountains;
  GenerateRivers;

  AvailableMovesShown := 0;
  SetLength(AvailableMoves, AvailableMovesShown);

  AvailableAttacksShown := 0;
  SetLength(AvailableAttacks, AvailableAttacksShown);
end;

procedure TWorld.GenerateMountains;
var
  CurrTile : TTile;
  MoreRoll : Extended;
  Roll : Integer;

  WorldSize : Integer;
  MoreChance : Extended;
  EndRange : Boolean;
begin
  WorldSize := XSize * YSize;
  WorldSize := Trunc(WorldSize / WorldGenSizeDivisor);

  MoreChance := MountainChance * WorldSize;
  MoreRoll := Random;

  while (MoreRoll < MoreChance) do
  begin
    CurrTile := WorldArray[Random(WorldY)][Random(WorldX)];
    CurrTile.SetTerrain(iMountain);

    EndRange := False;
    while not EndRange do
    begin
      // 4 directions
      Roll := Random(MountainRollMax);
      case Roll of
        iNorth : CurrTile := CurrTile.North;
        iEast  : CurrTile := CurrTile.East;
        iSouth : CurrTile := CurrTile.South;
        iWest  : CurrTile := CurrTile.West;
        else EndRange := True;
      end;

      // Stop if end of world or another mountain
      if ((not Assigned(CurrTile)) or (CurrTile.Terrain = iMountain)) and (not EndRange) then
      begin
        EndRange := True;
      end
      else
      begin
        CurrTile.SetTerrain(iMountain);
      end;
    end;

    MoreRoll := Random;
    MoreChance := MoreChance * MountainMultiplier;
  end;
end;

// Somewhat inspired/informed by
// https://medium.com/@scbarrus/my-final-step-generating-a-river-on-a-procedurally-generated-map-or-a-river-runs-through-it-fb8e58a1e563#.hl15q0ir1
procedure TWorld.GenerateRivers;
var
  WorldSize : Integer;
  Chance : Extended;

  MakeNewRiver : Boolean;
  EndRiver : Boolean;

  StartWest : Integer;
  XVal : Integer;
  CurrTile : TTile;
  Roll : Integer;

  FavoredDir : Integer;
  BackDir : Integer;
  NewDir : Integer;
begin
  WorldSize := XSize * YSize;
  WorldSize := Trunc(WorldSize / WorldGenSizeDivisor);

  // Random chance of making a river
  Chance := RiverChance * WorldSize;
  if Random < Chance then MakeNewRiver := True
  else MakeNewRiver := False;

  // Keep rivers with decreasing chance
  while MakeNewRiver do
  begin
    // Randomly start on an edge tile west or east
    StartWest := Random(2);
    if StartWest = 1 then
    begin
      XVal := 0;
      FavoredDir := iEast;
      BackDir := iWest;
    end
    else
    begin
      XVal := WorldX-1;
      FavoredDir := iWest;
      BackDir := iEast;
    end;
    CurrTile := WorldArray[Random(WorldY)][XVal];
    CurrTile.SetTerrain(iRiver);

    // Add river tiles until reach end of world or double back on a river or hit mountain
    EndRiver := False;
    while not EndRiver do
    begin
      Roll := Random(RiverRollMax);
      // (RollMax - 3)/RollMax chance to go Favored
      // (2)/RollMax chance to change direction

      case Roll of
        iNorth : NewDir := iNorth;
        iEast  : NewDir := iEast;
        iSouth : NewDir := iSouth;
        iWest  : NewDir := iWest;
        else NewDir := FavoredDir;
      end;

      // If it wants to go backwards, go favored direction
      if NewDir = BackDir then NewDir := FavoredDir;

      case NewDir of
        iNorth : CurrTile := CurrTile.North;
        iEast  : CurrTile := CurrTile.East;
        iSouth : CurrTile := CurrTile.South;
        iWest  : CurrTile := CurrTile.West;
      end;

      if not Assigned(CurrTile) or (CurrTile.Terrain = iRiver) or (CurrTIle.Terrain = iMountain) then
      begin
        EndRiver := True;
      end
      else
      begin
        FavoredDir := NewDir;
        case FavoredDir of
          iNorth : BackDir := iSouth;
          iEast  : BackDir := iWest;
          iSouth : BackDir := iNorth;
          iWest  : BackDir := iEast;
        end;
        CurrTile.SetTerrain(iRiver);
      end;
    end;

    Chance := Chance * RiverMultiplier;
    if Random < Chance then MakeNewRiver := True
    else MakeNewRiver := False;
  end;

end;

function TWorld.GetAvailableMove : TCircle;
begin
  // If need more circles than available, create a new one
  if AvailableMovesShown >= Length(AvailableMoves) then
  begin
    Result := TCircle.Create(Self);
    Result.Width := CircleSize;
    Result.Height := CircleSize;
    Result.Align := TAlignLayout.Center;
    Result.Fill.Color := ColorMovementCircle;
    Result.Visible := True;

    AvailableMovesShown := AvailableMovesShown + 1;
    SetLength(AvailableMoves, AvailableMovesShown);
    AvailableMoves[AvailableMovesShown - 1] := Result;
  end
  else
  // Else, just use an old, unused one.
  begin
    Result := AvailableMoves[AvailableMovesShown-1];
  end;
end;

function TWorld.GetAvailableAttack : TRectangle;
begin
  // If need more circles than available, create a new one
  if AvailableAttacksShown >= Length(AvailableAttacks) then
  begin
    Result := TRectangle.Create(Self);
    Result.Width := TileWidth;
    Result.Height := TileHeight;
    Result.Align := TAlignLayout.Center;
    Result.Fill.Color := ColorAttackCircle;
    Result.Opacity := 0.70;
    Result.Visible := True;

    AvailableAttacksShown := AvailableAttacksShown + 1;
    SetLength(AvailableAttacks, AvailableAttacksShown);
    AvailableAttacks[AvailableAttacksShown - 1] := Result;
  end
  else
  // Else, just use an old, unused one.
  begin
    Result := AvailableAttacks[AvailableAttacksShown-1];
  end;
end;

procedure TWorld.ClearAvailableMoves;
var
  I: Integer;
  CurrCircle : TCircle;
  CurrTile : TTile;
begin
  for I := 0 to Length(AvailableMoves)-1 do
  begin
    CurrCircle := AvailableMoves[I];
    if Assigned(CurrCircle.Parent) then
    begin
      CurrTile := TTile(CurrCircle.Parent);
      CurrTile.MovementCircle := nil;
      CurrCircle.Parent := nil;
    end;
    CurrCircle.OnClick := nil;
  end;
end;

procedure TWorld.ClearAvailableAttacks;
var
  I: Integer;
  CurrRect : TRectangle;
  CurrTile : TTile;
begin
  for I := 0 to Length(AvailableAttacks)-1 do
  begin
    CurrRect := AvailableAttacks[I];
    if Assigned(CurrRect.Parent) then
    begin
      CurrTile := TTile(CurrRect.Parent);
      CurrTile.AttackRect := nil;
      CurrRect.Parent := nil;
    end;
    CurrRect.OnClick := nil;
  end;
end;

procedure TWorld.ClearDistances;
var
  Y: Integer;
  X: Integer;
begin
  for Y := 0 to Length(WorldArray)-1 do
  begin
    for X := 0 to Length(WorldArray[Y])-1 do
    begin
      WorldArray[Y][X].MoveDistFromSelected := -1;
      WorldARray[Y][X].ATKDistFromSelected := -1;
      WorldArray[Y][X].Moveable := False;
      WorldArray[Y][X].Attackable := False;
    end;
  end;
end;

function TWorld.GetTile(X : Integer; Y : Integer) : TTile;
begin
  Result := WorldArray[Y][X];
end;

end.
