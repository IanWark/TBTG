unit Tutorial;

interface
uses  FMX.Objects, FMX.Graphics, FMX.Types, GameValues;

var
    currentPage : Integer;

  procedure setTutorialLabels;
  procedure setImage(TargetRect : TRectangle; SourceImage : TBitmap);
  procedure backPage;
  procedure nextPage;




const
  tutorialPage1 =
  'The game board consists of square tiles arranged in a grid.' + sLineBreak + sLineBreak +
  'Two players face off against each other. Each player has multiple units, and ' +
  'the first to eliminate all of their enemies units wins the battle. ' + sLineBreak + sLineBreak +
  'The human players units are surrounded by a blue circle, and the enemies units have a red circle.';

  tutorialPage2 =
  'A typical unit is shown above. ' +
  'Once a unit uses all its attacks, its turn is over and cannot continue to move. ' + sLineBreak + sLineBreak +
  'Select a unit by clicking on it. When a unit is selected, its possible moves are ' +
  'shown by small blue circles, and its attack range is shown by red squares.';

  tutorialPage3 = 'There are 3 types of units: ';
  tutorialSword = 'Infantry are tough, slow, and can only attack when adjacent to an enemy.';
  tutorialArcher = 'Archers are fragile and slow, but can shoot at range.';
  tutorialCavalry = 'Cavalry are quick, fragile, and hava a charge that deals damage ' +
                    'based on straight line distance before reaching the target.';

  tutorialPage4 = 'There are also 3 types of tile terrain: ';
  tutorialGrass = 'Grass costs 1 movement point to traverse and does not block line of sight.';
  tutorialRiver = 'Rivers cost 2 movement points to cross and do not block line of sight.';
  tutorialMountain = 'Mountains cost 2 movement points to climb and DO block line of sight for archers and cavalry.';

implementation
uses Main;

  procedure setTutorialLabels;
  begin
    MainForm.lTutorialPage1.Text := tutorialPage1;
    MainForm.lTutorialPage2.Text := tutorialPage2;
    MainForm.lTutorialPage3.Text := tutorialPage3;
    MainForm.lTutorialPage4.Text := tutorialPage4;

    setImage(MainForm.rectTutSword, MainForm.ImageSword.Bitmap);
    MainForm.lTutSword.Text := tutorialSword;
    setImage(MainForm.rectTutArcher, MainForm.ImageArcher.Bitmap);
    MainForm.lTutArcher.Text := tutorialArcher;
    setImage(MainForm.rectTutCavalry, MainForm.ImageCavalry.Bitmap);
    MainForm.lTuTCavalry.Text := tutorialCavalry;

    MainForm.rectTutGrass.Fill.Color := ColorGrass;
    MainForm.lTutGrass.Text := tutorialGrass;
    MainForm.rectTutRiver.Fill.Color := ColorRiver;
    MainForm.lTutRiver.Text := tutorialRiver;
    MainForm.rectTutMountain.Fill.Color := ColorMountain;
    MainForm.lTutMountain.Text := tutorialMountain;

    currentPage := 1;
  end;

  procedure setImage(TargetRect : TRectangle; SourceImage : TBitmap);
  var
    Image : TImage;
  begin
    Image := TImage.Create(TargetRect);
    Image.Parent := TargetRect;
    Image.Align  := TAlignLayout.Contents;
    Image.Visible:= True;
    Image.Bitmap.Assign(SourceImage);
  end;

  procedure backPage;
  begin
    if currentPage = 1 then
    begin
      MainForm.menuTutorial.Visible := False;
      MainForm.menuMain.Visible := True;
    end
    else
    if currentPage = 2 then
    begin
      MainForm.rectTutorialPage2.Visible := False;
      MainForm.rectTutorialPage1.Visible := True;

      currentPage := 1;
    end
    else
    if currentPage = 3 then
    begin
      MainForm.rectTutorialPage3.Visible := False;
      MainForm.rectTutorialPage2.Visible := True;

      currentPage := 2;
    end
    else
    if currentPage = 4 then
    begin
      MainForm.rectTutorialPage4.Visible := False;
      MainForm.rectTutorialPage3.Visible := True;

      currentPage := 3;
    end;
  end;

  procedure nextPage;
  begin
    if currentPage = 1 then
    begin
      MainForm.rectTutorialPage1.Visible := False;
      MainForm.rectTutorialPage2.Visible := True;

      currentPage := 2;
    end
    else
    if currentPage = 2 then
    begin
      MainForm.rectTutorialPage2.Visible := False;
      MainForm.rectTutorialPage3.Visible := True;

      currentPage := 3;
    end
    else
    if currentPage = 3 then
    begin
      MainForm.rectTutorialPage3.Visible := False;
      MainForm.rectTutorialPage4.Visible := True;

      currentPage := 4;
    end
    else
    if currentPage = 4 then
    begin
      MainForm.menuTutorial.Visible := False;
      MainForm.menuMain.Visible := true;
    end;

  end;

end.
