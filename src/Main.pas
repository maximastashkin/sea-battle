Program SeaBattle;

Uses 
  GraphABC, Drawing, GlobalVars, Types, Menu, Gameplay;

{ Точка входа. }
Begin
  lastState := -2;
  MainState._gameState := MenuGameState;
  OnMouseDown := MouseClickMenu;
  InitWin();
  DrawCurrentState(false);
  step := true;
  while (true) do  //Решение проблемы с блокировкой потока обработчика.
  begin
    if not step and (MainState._gameState = MainGameState) then
    begin
      sleep(1000);
      ComputerShoot();
      SetStrings(hit, dead);
      DrawCurrentState(not step);
    end;
  end;
End. 