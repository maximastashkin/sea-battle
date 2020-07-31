{ Модуль, реализующий заполнение некоторых игровых структур при старте игрового процесса. }
Unit GameStarting;

Interface
  Uses GraphABC, Types, GlobalVars;
  procedure SetStartMap(var p:Player);
  procedure SetShips();
  
Implementation
  
  { Процедура, выполняющая стартовое заполнение игровых полей             }
  { Параметры: p:Player - игрок, поле которого нужно заполнить            }
  { Заполнение выполяняется в зависимости от размера игрового поля - size }
  procedure SetStartMap(var p:Player);
  begin
      //-1 является ограничением игрового поля, т.к. изначально используется
      //статический двумерный массив 12 на 12.
      //Такое ухищрение используется для избежания ошибок во время отладки.
      for var raw := 0 to size + 1 do
        for var column := 0 to size + 1 do
        begin
          if (raw = 0) or (raw = size + 1) then
          begin  
            p._map[column, raw] := -1;
          end
          else
          begin
            if (column = 0) or (column = size + 1) then
              p._map[column, raw] := -1
            else
              p._map[column, raw] := 0;
          end;
      end;
  end;
  { Процедура, заполняющая структуры, хранящие количество доступных кораблей }
  { Заполнение выполяняется в зависимости от размера игрового поля - size    }
  procedure SetShips();
  begin
    case size of
      10: 
      begin
        MainState._player.ShipsCount[1] := 4;
        MainState._player.ShipsCount[2] := 3;
        MainState._player.ShipsCount[3] := 2;
        MainState._player.ShipsCount[4] := 1;
      end;
      8: 
      begin
        MainState._player.ShipsCount[1] := 4;
        MainState._player.ShipsCount[2] := 3;
        MainState._player.ShipsCount[3] := 1;
        MainState._player.ShipsCount[4] := 0;
      end;
      6: 
      begin
        MainState._player.ShipsCount[1] := 4;
        MainState._player.ShipsCount[2] := 2;
        MainState._player.ShipsCount[3] := 0;
        MainState._player.ShipsCount[4] := 0;
      end;
    end;
    //Копирование массива ShipsCount в массив ShipsPlacementCount и 
    //в соответсвующие массивы для компьютера (как игрока).
    for var i := 1 to 4 do
    begin
      MainState._player.ShipsPlacementCount[i] := MainState._player.ShipsCount[i];
      MainState._computer.ShipsCount[i] := MainState._player.ShipsCount[i];
      MainState._computer.ShipsPlacementCount[i] := MainState._player.ShipsCount[i];
    end;
  end;
end.