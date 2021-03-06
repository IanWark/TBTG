unit GameValues;

interface
uses UITypes, IOUtils;


const
  TileWidth = 75;
  TileHeight = 75;

  UnitWidth = 69;
  UnitHeight = 69;
  ImageMargins = 10;

  ExtraSpaceMultiplier = 1.2;

  DragSpeed = 1.5;

  CircleLayoutMargins = 1;
  CircleSize = 10;
  CircleMargins = 1;
  HealthBarHeight = 10;

  ColorHealthBar = TAlphaColorRec.Red;
  ColorMovementCircle = TAlphaColorRec.Lightblue;
  ColorAttackCircle = TAlphaColorRec.Red;

  ColorRecieveDamage = TAlphaColorRec.Red;

  ColorNull  = TAlphaColorRec.Null;
  ColorGrass = TAlphaColorRec.Lightgreen;
  ColorRiver = TAlphaColorRec.Blue;
  ColorMountain = TAlphaColorRec.LightGrey;

  ColorTeam1 = TAlphaColorRec.Blue;
  ColorTeam2 = TAlphaColorRec.Red;
  ColorTeam3 = TAlphaColorRec.Yellow;

  ThicknessSelected = 3;
  ThicknessUnselected = 1;

  // This is the amount that the world size (X*Y) is divided by
  // before multiplying the Mountain and River Chances
  // Decreasing will result in more Mountains and Rivers
  // Increasing will result in less Mountains and Rivers
  WorldGenSizeDivisor = 12;

  // These world gen numbers are BEFORE having an increased chance based on world size
  // Chance of generating a mountain in world gen reduction in chance for every successful mountain
  MountainChance = 0.95;
  // Reduction in chance for every successful mountain
  MountainMultiplier = 0.7;
  // 5 = 4 directions, plus chance to stop
  MountainRollMax = 5;

  // Chance of generating a river in world gen
  RiverChance = 0.8;
  // Reduction in chance for every successful river
  RiverMultiplier = 0.5;

  RiverRollMax = 8;

  // Movement speed when adjacent to an enemy unit
  IfAdjacentEnemyMP = 1;

  // Unit Stats
  // Sword is tough, slow, meh damage
  SwordHP = 12;
  SwordAP = 1;
  SwordDAM = 3;
  SwordMP = 2;
  SwordRange = 1;

  // Archer is fragile, slow, ok damage, but long ranged
  ArcherHP = 8;
  ArcherAP = 1;
  ArcherDam = 4;
  ArcherMP = 2;
  ArcherRange = 5;

  // Cavalry is fast and has a charge attack that deals extra damage if
  // there is a straight line between them and the target when attacking,
  // but is fragile in a straight fight
  CavalryHP = 8;
  CavalryAP = 1;
  CavalryDam = 3;
  CavalryMP = 4;

var
  SwordBitmapPath : String;
  WorldX : Integer;
  WorldY : Integer;

  // Number of units on each team
  Team1UnitsNum : Integer;
  Team2UnitsNum : Integer;

implementation

end.
