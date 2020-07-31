{ Модуль, реализующий поведение при расстановки кораблей игроком и ЭВМ. }
unit ShipPlacement;
Interface
  uses GraphABC, Types, GlobalVars, Drawing, Gameplay, GameStarting;
  procedure MouseClickShipPlacement(x,y, mousebutton:integer);
  procedure SetComputerShip(var p: Player);
  procedure SetCountInMenu();
  
  Var  
    clicks:                     boolean;  //Флаг, отвечающий за режим расположения корабля. (True - игрок в режиме расстановки кораблей).
    fc, sc:                         pnt;  //Крайние точки, расставляемого корабля.
    SqCntMenu:                  integer;  //Количество клеток, из которых состоят корабли в меню выбора кораблей.
    
Implementation
  
  { Процедура, определяющая количество клеток, из которых состоят корабли в меню выбора кораблей. }
  { Определение происходит в зависимости от размера игрового поля - size.                         }
  procedure SetCountInMenu();
  begin
    case size of
      10: SqCntMenu := 13;
      8:  SqCntMenu := 8;
      6:  SqCntMenu := 4;
    end;
  end;
  
  { Процедура, выполняющая простейший обмен значений переменных. }
  { Данная операция была вынесена в отдельную процедуру в связи  }
  { с несколькими обменами координат во время пользовательского  }
  { расставления кораблей.                                       }
  procedure Swap(var a, b: integer);
  begin
    var buff := a;
    a := b;
    b := buff;
  end;
  
  { Процедура, выполняющая смену текущего расставляемого пользователем корабля.             }
  { Параметры x, y: integer -  координаты клика мыши. В данном случае разделены             }
  { в связи с ненадобностью создания отдельной переменной типа pnt. При передаче аргумента. }
  
  procedure ChangeShip(x, y: integer);
  Var
    buff: integer; //Вспомогательная перменная для возвращения текущего корабля к предыдущему выбранному в случае
                   //если корабли выбранного типа закончились.
  begin
    buff := curship;
    case (x - ShipsMenuCrds.x) div (GridSize div size) of
      0: curship := 1;
      2,3: curship := 2;
      5,6,7: curship := 3;
      9,10,11,12: curship := 4;  
    end;
    if MainState._player.ShipsPlacementCount[curShip] = 0 then
      curShip := buff;
  end; 
  
  procedure PrintError(f: boolean);
  begin
    if f then
    begin
      labels[7].coord.x := GrCrds.x + GridSize;
      labels[7].coord.y := 360;
      labels[7].text := 'Таким образом корабль поставить нельзя. Читайте инструкцию!'; 
    end
    else
      labels[7].text := ' ';
    
  end;
  
  { Функция, проверяющая 2 крайние точки, устанавливаемого корабля на правильность. }
  { Под проверкой на правильность подразумевается:                                  }
  { проверка расстояния между 2 точками (должно быть равно размерности корабля),    }
  { проверка на пустоту между 2 точками (между ними не должно быть ничего кроме 0). }
  { Если проверка пройдена успешно, возвращает True, иначе False.                   }
  { Параметры: var p: Player -  игрок, на поле которого устанавливается корабль.    }
  { cs:intger - размерность устанавливаемого корабля.                               }
  function CheckValidPoints(var p: Player; cs:integer):boolean;
  Var
    pass: boolean;  //Флаг отвечающий за успешность прохождения проверок (возвращается из функции (True - точки правильны)).
  begin
    if (sc.x < 1) or (sc.x > size) or (sc.y < 1) or (sc.y > size) then pass := false  //Проверка на нахождение точек внутри игрового поля.
    else
    begin
      pass := true;
      if (fc.x > sc.x) then       //*                     
        Swap(fc.x, sc.x);         //В данном блоке условий происходит подгонка входных данных под алгоритм.     
      if (fc.y > sc.y) then       //Данна подгонка вынужденная мера, связанная с тем, что корабль может быть поставлен как вертикально, так и горизонтально.
        Swap(fc.y, sc.y);         //*
      if ((fc.x <> sc.x) and (fc.y <> sc.y)) or ((fc.x = sc.x) and (fc.y = sc.y)) then 
      begin
        pass := false           //Проверки на соответствие размерности корабля.
      end
      else
      begin
       if (fc.x = sc.x) then
        begin
          if sc.y - fc.y <> cs - 1 then pass := false
          else
            for var i := fc.y to sc.y do                                //Проверки на пустоту между точкам.
              if (p._map[sc.x, i] <> 0) and (p._map[sc.x, i] <> -2) then pass := false
        end;
        if (fc.y = sc.y) then  //Данный блок выполянет те же проверки, что и верхний, только в случае вертикального расположения корабля.
        begin
          if sc.x - fc.x <> cs - 1 then pass := false
          else
            for var j := fc.x to sc.x do
              if (p._map[j, fc.y] <> 0) and (p._map[j, fc.y] <> -2) then pass := false;
        end;
      end;
      PrintError(not pass);
      CheckValidPoints := pass;
    end;
  end;
  
  { Процедура, размещающая корабль на игровом поле.                                   }
  { Координаты точек, по которым размещается корабль берутся из глобальных перменных, }
  { доступных только в этом модуле (fc, sc).                                          }
  { Параметры: cs: integer -  размерность, устанавливаемого корабля,                  }
  { var p: Player - игрок, на поле которого устанавливается корабль.                  }
  procedure PickShipOnMap(cs:integer; var p: Player);
  begin
  SetBarr(fc, sc, -1, p);
  if (fc.x = sc.x) then  //Корабль располагается горизонтально.
    for var i := fc.y to sc.y do
      p._map[sc.x, i] := cs
  else //Корабль располгается вертикально.
    for var j := fc.x to sc.x do
        p._map[j, fc.y] := cs;
  p.ShipsPlacementCount[cs] -= 1; //Уменьшение количества доступных к размещению кораблей размерность cs.
  end;
  
  
  { Процедура генерации расположения кораблей на поле игрока/компьютера.               }
  { Используется при расставлении кораблей компьютером/случайном расставлении игроком. }
  { Параметры: var p: Player - игрок на поле которого генерируются корабли.            }
  { Данная процедура использует практически все выше описанные процедуры и функции.    }
  procedure SetComputerShip(var p: Player);
  const
    ToUp    = 1;      //Своеобразный enum направлений
    ToDown  = 2;
    ToLeft  = 3;
    ToRight = 4;
  var
    dirs: array[1..4] of integer; //Массив флагов для направлений, которые уже были неудачно использованы при расположении корабля относительно 1-ой случайной точки (1 направление уже использовалось).
    direction, poss: integer;     //direction - текущее направление относительно 1-ой точки, poss - количество попыток установки корабля в разных направлениях относительно 1-ой точки.
    cs:              integer;     //Размеронсть текущего устанавливаемого корабля. 
    pass:            boolean;     //Флаг прохождения проверки координат точек на валидность (True - точки правильны).
    trycount:        integer;     //Общее количество попыток установки одного корабля.
                                  //Испольузется для запуска процедуры заново при невозможности установки корабля на поле при данной конфигурации.
  begin
    cs := 1;
    trycount := 0;
    randomize();
    //В данном блоке рандомится 1 точка, относительно которой будут далее выбираться направления.
    while (cs <> 5) and (p.ShipsPlacementCount[cs] <> 0) do
    begin
      repeat
        fc.x := random(1, size);
        fc.y := random(1, size);
        trycount += 1;
      until (p._map[fc.x, fc.y] = 0) or (trycount >= size * size);
      if trycount > size*size then  //При данном количестве попыток, становится понятно, что корабль установить невозможно при данной конфигурации.
      begin                         //Следует проводить генрацию полностью заново.
        SetStartMap(p);
        SetShips();
        SetCountInMenu();
        curShip := 1;
        SetComputerShip(p);
        exit;
      end;
      //--------------------------------------------------------//
      if cs = 1 then //Если корабль имеет размерность 1, установить его легко(достаточно того, чтобы клетка была пуста), поэтому дальнейший код выполнять нет смысла.
      begin
        SetBarr(fc, fc, -1, p);
        p._map[fc.x, fc.y] := cs;
        p.ShipsPlacementCount[cs] -= 1;
      end
      else
      begin
        pass := true;
        poss := 0;
        for var i := 1 to 4 do
          dirs[i] := 0;
        repeat
          repeat
            direction := random(1,4);
          until dirs[direction] = 0;
          dirs[direction] := 1;
          poss += 1;
          //Подсчет координаты 2-ой точки.
          case direction of
            ToUp:
            begin
              sc.x := fc.x - cs + 1;
              sc.y := fc.y;
            end;
            ToDown:
            begin
              sc.x := fc.x + cs - 1;
              sc.y := fc.y;
            end;
            ToLeft:
            begin
              sc.x := fc.x;
              sc.y := fc.y - cs + 1;
            end;
            ToRight:
            begin
              sc.x := fc.x;
              sc.y := fc.y + cs - 1;
            end;
          end;
          pass := CheckValidPoints(p, cs);
        until pass or (poss = 4) or (trycount >= size * size);
        if pass then
        begin
          PickShipOnMap(cs, p);
          trycount := 0;
        end;
      end;
      //Обработка, если закончились расставляемые корабли размерности cs.
      if p.ShipsPlacementCount[cs] = 0 then
      begin
        cs += 1;
        if (cs = 5) or (p.ShipsPlacementCount[cs] = 0) then
        begin  
          curShip := 0;
          exit;
        end;
      end;
    end;
  end;
  
  { Процедура, выполняющая сам процесс постановки корабля на игровое поля, путем }
  { вызова выше описанных и реализованных процедур.                              }
  procedure SetShip();
  var
    grayCross: pnt;  //Координаты первой точки, помечаемой серым крестом на белом фоне.
  begin
    if (MainState._player._map[fc.x, fc.y] = 0) or (MainState._player._map[fc.x, fc.y] = -2) then
    begin
      MainState._player._map[fc.x, fc.y] := -2; //Помечаем на поле первую выбранную точку серым крестом на белом фоне.
      grayCross.x := fc.x;
      grayCross.y := fc.y;
      if curShip = 1 then
      begin
        SetBarr(fc,fc, -1, MainState._player);
        MainState._player._map[fc.x, fc.y] := curShip;
        MainState._player.ShipsPlacementCount[curShip] -= 1;
        clicks := false;
        PrintError(false);
      end
      else
        if clicks = false then
        begin
          if CheckValidPoints(MainState._player, curShip) then
            PickShipOnMap(curShip, MainState._player)  
          else
            MainState._player._map[grayCross.x, grayCross.y] := 0;            
        end;
    end
    else
    begin
      clicks := false;
      PrintError(true);
    end;
    //Обработка, если закончились расставляемые корабли выбранного типа 
    if MainState._player.ShipsPlacementCount[curShip] = 0 then
    begin
      curShip := 1;
      while MainState._player.ShipsPlacementCount[curShip] = 0 do
      begin
        curShip += 1;
        if curShip = 5 then
        begin
          curShip := 0;
          break;
        end;
      end; 
    end;
  end;
  
  { Процедура, удаляющая корабль и его ограничения из -1, окружающие его.                                            }
  { Используется в программе, когда пользователь хочет удалить неудачно поставленный корабль и поставить его заново. }
  procedure DelShip();
  Var 
    br, k:        integer;  //Вспомогательные перменные (счетчики) для определения границ удаляемой области.
    fdelpnt, sdelpnt: pnt;  //Вспомогательные координаты точек, ограничивающих удаляемую область.
  begin
    k := -1;
    br := 0;
    
    //Определние двух точек, задающих прямоугольник, который нужно удалить.
    //Сначала "движимся" в верхний левый угол ограничения корабля, далее в правый нижний.
    //-1-1-1-1-1-1      *fdelpnt-1-1-1-1-1           0 0 0 0 0 
    //-1 4 4 4 4-1 =>         -1 4 4 4 4-1       =>  0 0 0 0 0 
    //-1-1-1-1-1-1            -1-1-1-1-1*sdelpnt     0 0 0 0 0
    while k <> 3 do
    begin
      if k > 0 then br := size + 1;
      var i := fc.x;
      while (MainState._player._map[i, fc.y] <> -1) and (i <> br) do
        i += k;
      var j := fc.y;
      while (MainState._player._map[fc.x, j] <> -1) and (j <> br) do
        j += k;
      
      if i = br then i -= k;
      if j = br then j -= k;
      
      if k < 0 then
      begin
        fdelpnt.x := i;
        fdelpnt.y := j;
      end
      else
      begin
        sdelpnt.x := i;
        sdelpnt.y := j;
      end;
      k += 2;
    end;
    
    //Удаление выделенного прямоугольника
    MainState._player.ShipsPlacementCount[MainState._player._map[fc.x, fc.y]] += 1;
    curShip := MainState._player._map[fc.x, fc.y];
    for var i := fdelpnt.x to sdelpnt.x do
      for var j := fdelpnt.y to sdelpnt.y do
        MainState._player._map[i, j] := 0;
    
    //Восстановление случайно удаленных ограничений, окружающих корабли и находящихся на стыках.
    for var i := 0 to size + 1 do
      for var j := 0 to size + 1 do
        if (MainState._player._map[i, j] <> -1) and (MainState._player._map[i, j] <> 0) then
          for var h := i - 1 to i + 1 do
            for var n := j - 1 to j + 1 do
              if MainState._player._map[h, n] = 0 then MainState._player._map[h, n] := -1;
  end; 
  
  { Обработчик кликов мыши.                                                  }
  { Обрабатываются случаи нажатия в поле игрока,                             }
  {при расстановке корабелй (указание точек для кораблей, удаление корабля), }
  { нажатия на программные кнопки, нажатия на меню выбора корабля.           }
  procedure MouseClickShipPlacement(x,y, mousebutton:integer);
  begin
    //Клик ЛКМ.
    if (MainState._gameState = StartGameState) and (mousebutton = 1) then
    begin
      //Клик в меню выбора кораблей.
      if (x > ShipsMenuCrds.x) and (x < ShipsMenuCrds.x + SqCntMenu * GridSize div size) and
         (y > ShipsMenuCrds.y) and (y < ShipsMenuCrds.y + GridSize div size) and (not clicks) and (curShip <> 0) and not pause then
        ChangeShip(x,y);

      //Клик в сетку
      if (x > GrCrds.x) and (y > GrCrds.y) and (x < GrCrds.x + GridSize) and (y < GrCrds.y + GridSize) and (curShip <> 0) and not pause then
      begin
        if not clicks then
        begin
          fc.y := (x - GrCrds.x) div (GridSize div size) + 1;
          fc.x := (y - GrCrds.y) div (GridSize div size) + 1;
          sc.y := 0;
          sc.x := 0;
          clicks := true;
        end
        else
        begin
          sc.y := (x - GrCrds.x) div (GridSize div size) + 1;
          sc.x := (y - GrCrds.y) div (GridSize div size) + 1;
          clicks := false;
        end;
        SetShip();
      end;
      var b := -1;
      for var i := 1 to 4 do
        if (x > btns[i].coord.x) and (x < btns[i].coord.x + btns[i].width) and (y > btns[i].coord.y) and (y < btns[i].coord.y +  btns[i].heigth) and not clicks then
          b := i; //Индекс нажатой кнопки в массиве кнопок в Drawing.
      case b of
        1:  //Программная кнопка - "Случайно".
        begin
          if not pause then
          begin
            SetStartMap(MainState._player);
            SetShips();
            SetCountInMenu();
            curShip := 1;
            SetComputerShip(MainState._player);
            DrawCurrentState(false); 
          end;          
        end;
        2:  //Программная кнопка - "Назад".
        begin
          if not pause then
          begin
            var fl := false;
            for var i := 1 to size do 
              for var j := 1 to size do
                if MainState._player._map[i, j] = -1 then
                  fl := true;
            if fl then
              pause := true
            else
            begin
              MainState._gameState := SetSizeState;
              OnMouseDown -= MouseClickShipPlacement;
            end;
          end
          else
          begin
            MainState._gameState := SetSizeState;
            OnMouseDown -= MouseClickShipPlacement;
            pause := false;
          end;
        end;
        3:  //Программная кнопка - "Начать игру".
        begin
          if not pause then
          begin
            pause := false;
            MainState._computer._shots := 0;
            MainState._player._shots := 0;
            SetComputerShip(MainState._computer);
            var r := random(0,1);  //Определение того, кто будет делать первый выстрел.
            if r = 0 then
              step := false
            else
              step := true;
            inComp := false;
            MainState._winner := false;
            SetStrings(-1,-1);
            MainState._gameState := MainGameState;
            OnMouseDown -= MouseClickShipPlacement;
            OnMouseDown += MouseClickGameplay; 
          end
          else
            pause := false;
        end;
      end;
    end;
    //Клик ПКМ.
    if (MainState._gameState = StartGameState) and (mousebutton = 2) and not pause then
    begin
      if clicks then
      begin
        MainState._player._map[fc.x, fc.y] := 0;    //Отмена 1-ой поставленной точки.
        clicks := false;
      end
      else //Удаление выбранного корабля.
      begin
          fc.y := (x - GrCrds.x) div (GridSize div size) + 1;
          fc.x := (y - GrCrds.y) div (GridSize div size) + 1;
          if (x > GrCrds.x) and (y > GrCrds.y) and (x < GrCrds.x + GridSize) and (y < GrCrds.y + GridSize) then
          begin  
            if (MainState._player._map[fc.x, fc.y] <> 0) and (MainState._player._map[fc.x, fc.y] <> -1) then
              DelShip();
          end;
      end;
    end;
    DrawCurrentState(clicks);  
  end;
end.