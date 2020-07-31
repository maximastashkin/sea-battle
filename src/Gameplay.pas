{ Модуль, реализующий поведение при основном игровом процессе. }
unit Gameplay;
Interface
  uses GraphABC, GlobalVars, Drawing, Types, GameStarting;
  procedure MouseClickGameplay(x,y, mousebutton:integer);
  procedure ComputerShoot();
  procedure SetStrings(_hit, _dead: integer);
  procedure SetBarr(FirstClick, SecondClick:pnt; br: integer; var p:Player);
  Type
    arr = array[1..10] of ShortInt;   //Вспомогательный тип для передачи массива в процедуру.
  Var
    step:                   boolean;  //Флаг, отвечающий за право хода игрока/компьютера (True - ход игрока).
    inShip, inComp:         boolean;  //Флаги, отвечающие за то, производится ли атака на конкретный корабль игроком(inShip) или компьютером(inComp) (True - производится атака). 
    count:                  integer;  //Количество попаданий в определенный корабль.
    click, f, s, fc:            pnt;  //Вспомогательные координаты точек, использующиеся при выстрелах игроков.
    lastpoint, firstpoint:      pnt;  //Вспомогательные координаты для алгоритма стрельбы компьютера (при попадании в корабль позволяют, добить его, а не переключиться на другой случайный).                                                                                                                                                    
    horiz, vert:            boolean;  //Флаги для алгоритма стрельбы компьютера, помечающие расположение атакуемого компьютером корабля.
                                      //horizontal = True - направление горизонтальное.
                                      //vertical = True - направление вертикальное. 
                                      //Оба False -  направление пока что неопределено.
    curS:                   integer;  //Размерность текущего атакуемого корабля.
    _start, _end:           integer;  //Координаты, используемые при проверке на то, выбит ли корабль.
    dead, hit:              integer;  //Флаги, отвечающие за формирование строк с репилками игроков (при промахе, попадании, выбитии).
                                      //dead = True - корабль выбит.
                                      //hit = True - попадание в корабль.
                                      //Оба False - нет попадания.
Implementation

  { Процедура, устанавливающая ограждение вокруг поставленного корабля.        }
  { Параметры: FirstClick, SecondClick:pnt - координаты крайних точек корабля, }
  { br: integer - число ограждения,                                            }
  { var p:Player - игрок, на поле которого ограждение.                         }
  procedure SetBarr(FirstClick, SecondClick:pnt; br: integer; var p:Player);
  begin
    for var i := FirstClick.x - 1 to SecondClick.x + 1 do
      for var j := FirstClick.y - 1 to SecondClick.y + 1 do
        p._map[i,j] := br;
  end;
  
  { Процедура формирующая строки реплик игроков (при промахе, попадании, выбитии.                         }
  { Параметры: _hit:integer - флаг, отвечающий за попадание, _dead:integer - флаг, отвечающий за выбытие. }
  { Логика работы флагов, как и у глобальных переменных, передающихся в процедуру.                        }
  procedure SetStrings(_hit, _dead: integer);
  var 
    key, k: integer; //k - коэффициент для сдвига реплики на сторону поля компьютера, key -  флаг, отвечающий за то, чью реплику следует заполнить.
  begin
    labels[1].coord.x := GrCrds.x - 10;
    labels[1].coord.y := 20;
    for var i := 2 to 3 do
    begin
      k := 0;
      if i = 3 then 
        k := 60;
      labels[i].coord.x := GrCrds.x + (i - 2) * GridSize + k ;
      labels[i].coord.y := GrCrds.y + GridSize + 10;
    end;
    if step then
    begin
      labels[1].text := 'Ваш ход';
      if (hit = 1) or (dead = 1) then
        key := 3
      else
        key := 2;
    end
    else
    begin
      labels[1].text := 'Ход соперника';
      if (hit = 1) or (dead = 1) then
        key := 2
      else
        key := 3;
    end;
    if _hit = -1 then
      labels[key].text := '';
    if _hit = 0 then
      labels[key].text := 'Мимо!';
    if _hit = 1 then
      labels[key].text := 'Попал!';
    if _dead = 1 then
      labels[key].text := 'Попал! Убил!';
    if key = 3 then
      labels[2].text := ''
    else
      labels[3].text := '';
  end;
  
  { Функция, возвращающая True в случае, если атакуемый корабль выбит, в противном случае - False. }
  { Параметры: roc:arr - массив координат точек, которые нужно проверить на выбитые корабли.       }
  { В программе вызывается дважды, в связи с тем, что после попадания, нужно проверить             }
  { как вертикальное, так и горизонтальные напрваления относительно последнего попадания.          }
  { Таким образом, сначала передается массив - строка (в которую был нанесен выстрел), затем       }
  { массив - столбец.                                                                              }
  Function CheckForDie(roc: arr): boolean;
  begin
    CheckForDie := false;
    _start := 0;
    _end := 0;
    inShip := false;
    if curS = 1 then //Выстрел совершен в однопалубный корабль.
    begin
      _start := click.y;
      _end := click.y;
      CheckForDie := true;
      dead := 1;
      hit := 0;
    end
    else            //Выстрел совершен в многопалубный корабль.
      for var i := 1 to size do
      begin 
        if (roc[i] = curS * 5) then
        begin
          if (inShip = false) then
          begin
            inShip := true;
            _start := i;
          end
          else
          begin
            _end := i;
            if _end - _start = curS - 1 then
            begin
              CheckForDie := true;
              dead := 1;
              hit := 0;
              exit;
            end;
          end;
        end
        else
        begin
          inShip := false;
          _start := 0;
          _end := 0;
          CheckForDie := false;
          dead := 0;
        end;
      end;
  end;
  
  { Процедура, проверяющая не выявлен ли победитель после последнего совершенного выстрела. }
  { В случае, если победитель - игрок(человек), то делает новую запись в таблицу рекордов.  }
  procedure CheckForWinner();
  Const
    MAX_RECORDS = 100;
  var
    plP, cmpP:boolean;                        //Флаги отвечающие за наличие активных кораблей на полях игроков (plP = true - у игрока остались корабли, cmpP = true - у компьютера остались корабли).
    records: text;                            //Файл с таблицей рекордов.
    str, num: string;                         //str - строка таблицы рекордов, num - строковое представление количества выстрелов текущей записи таблицы.
    exist: boolean;                           //Флаг, показывающий существование записи с таким именем в таблице рекордов (True - существует).
    persons: array[0..MAX_RECORDS-1] of rec;  //Массив записей таблицы рекордов.
    quantity: integer;                        //Количество записей в таблице рекордов.
  begin
    plP := false;
    cmpP := false;
    for var i := 1 to 4 do  //Проверка, не закончились ли у игроков невыбитые корабли на игровых полях.                        
    begin
      if MainState._computer.ShipsCount[i] <> 0 then
        cmpP := true;
      if MainState._player.ShipsCount[i] <> 0 then
        plP := true;
    end;
    if not plP then  //Победа компьютера.
    begin
      MainState._gameState := EndGameState;
      step := true;
    end;
    if not cmpP then
    begin  
      MainState._gameState := EndGameState;
      MainState._winner := true;
      exist := false;
      assign(records, 'records/records' + size + '.txt');   //Для каждой из 3 размерностей игрового поля свой файл с таблицей.
      if fileexists('records/records' + size + '.txt') then
      begin
        quantity := 0;
        reset(records);
        while not eof(records) and (quantity < MAX_RECORDS - 1) do
        begin
          str := '';
          num := '';
          readln(records, str);   
          if Length(str) <> 0 then  //Блок выполняющий заполнение массива текущих записей в таблице рекордов.
          begin
            var p := pos(' ', str);
            for var j := 1 to p - 1 do
              persons[quantity].nick += str[j];
            for var j := p + 1 to Length(str) do
              num += str[j];
            var err := 0;
            val(num, persons[quantity].shots, err);
            if persons[quantity].nick = MainState._player._name then
            begin
              exist := true;
              if MainState._player._shots < persons[quantity].shots then //Если текущий результат лучше того, который занесен в таблицу.
                persons[quantity].shots := MainState._player._shots;
            end;
            quantity += 1;
          end;
        end;
        close(records); 
      end;
      if not exist then //Если не существует записи с таким именем.
      begin
        persons[quantity].nick := MainState._player._name;
        persons[quantity].shots := MainState._player._shots;  
      end
      else
        quantity -= 1;
      for var i :=  0 to quantity do          //Блок сортировки массива с записями таблицы рекордов. 
        for var j := 0 to quantity - i - 1 do //(Можно переделать через вставку, используя бинарный поиск.)
          if persons[j].shots > persons[j + 1].shots then
          begin
            var buff := persons[j];
            persons[j] := persons[j + 1];
            persons[j + 1] := buff;
          end;
      rewrite(records);
      for var i := 0 to quantity do
      begin
        write(records, persons[i].nick + ' ');
        writeln(records, persons[i].shots); 
      end;
      close(records);
    end;
  end;
  
  { Процедура проверки выстрела.                                                 }
  { Параметры: var p: Player - игрок, чьё поле после выстрела следует проверять. }
  procedure Check(var p: player);
  var
    row, col: arr; //Массивы координат точек для передачи в функцию CheckForDie(roc: arr): boolean
    pass: boolean; //Флаг отвечающий за то, выбит ли корабль или нет (True - корабль выбит).
  begin
    inShip := false;
    With p do
    begin
      if (_map[click.x, click.y] = 1) or (_map[click.x, click.y] = 2) or
         (_map[click.x, click.y] = 3) or (_map[click.x, click.y] = 4) then  //Попадание
      begin
        lastpoint := click;
        curS := _map[click.x, click.y];
        _map[click.x, click.y] := _map[click.x, click.y] * 5;
        hit := 1;
        if not step then
        begin
          inComp := true;
          count += 1;
        end;
        for var i := 1 to size do
        begin
          row[i] := _map[click.x, i];
          col[i] := _map[i, click.y];
        end;
        pass := CheckForDie(row); //Проверка строки выстрела.
        if pass then
        begin
          f.x := click.x;
          f.y := _start;
          s.x := click.x;
          s.y := _end;
          SetBarr(f,s,-3, p);
          for var i := f.y to s.y do
            _map[f.x, i] := curS * 25;
        end
        else
        begin
          pass := CheckForDie(col); //Проверка столбца выстрела.
          if pass then
          begin
            f.x := _start;
            f.y := click.y;
            s.x := _end;
            s.y := click.y;
            SetBarr(f, s, -3, p);
            for var i := f.x to s.x do
              _map[i, f.y] := curS * 25;
          end;
        end;
        if pass then  //Корабль выбит
        begin
          ShipsCount[curS] -= 1;
          if not step then
            inComp := false;
        end;
      end
      else if (_map[click.x, click.y] = -1) or (_map[click.x, click.y] = 0) then
      begin   
        hit := 0;
        dead := 0;
        _map[click.x, click.y] := -3;
        lastpoint := firstpoint;
        step := not step;
      end;
    end;
   CheckForWinner();
  end;
  
  
  { Процедура, выполняющая выстрел за компьютер по полю игрока.          }
  { Во многом после 1-го попадания функция работает по образу            }
  { процедуры setComputerShip() из модуля ShipPlacement.                 }
  { Принцип работы таков: сначала рандомится точка для выстрела,         }
  { если это попадание в корабль (опустим однопалубные корабли)          }
  { начинается атака на поврежденный корабль: выбираются случайные       }
  { направления до выстрела, до тех пор, пока не будет 2-го попадания    }
  { благодаря 2-му попаданию, можно сделать вывод о расположении корабля }
  { и полностью выбить поврежденный корабль.                             }
  procedure ComputerShoot();
  const
    ToUp    = 1;
    ToDown  = 2;
    ToLeft  = 3;
    ToRight = 4;
  var
    dir: integer;
    dirs: array [1..4] of integer;
    newPoint: pnt;
    pass: integer;
  begin
    MainState._computer._shots += 1;
    randomize();
    //В данном блоке рандомится 1-ая точка (в том случае, если уже не ведется атака по кораблю \\
    //Для того, чтобы ускорить рандом на последних стадиях игры (достаточно сложно зарандомить пустую точку из 100 точек
    //будем проходить "вперед" по массиву в поисках доступной для выстрела клетки, если такая клетка не будет найдена, то "назад".
    if not inComp then
    begin
      click.x := random(1, size);
      click.y := random(1, size);
      var k := false;
      for var i := click.x to size do
      begin
        for var j := click.y to size do
        begin
          if (MainState._player._map[i, j] = 0) or (MainState._player._map[i, j] = -1) or (MainState._player._map[i, j] = 1) or 
          (MainState._player._map[i, j] = 2) or (MainState._player._map[i, j] = 3) or (MainState._player._map[i, j] = 4)then
          begin
            k := true;
            click.x := i;
            click.y := j;
            break;
          end;
        end;
        if k then break;
      end;
      if not k then
      begin
        for var i := click.x downto 1 do
        begin
          for var j := click.y downto 1 do
          begin
            if (MainState._player._map[i, j] = 0) or (MainState._player._map[i, j] = -1) or (MainState._player._map[i, j] = 1) or 
            (MainState._player._map[i, j] = 2) or (MainState._player._map[i, j] = 3) or (MainState._player._map[i, j] = 4)then
            begin
              k := true;
              click.x := i;
              click.y := j;
              break;
            end;
          end;
          if k then break;
        end;
      end;
      fc.x := click.x;
      fc.y := click.y;
      count := 0;
      Check(MainState._player);
      pass := 0;
      firstpoint := click;
      vert := false;
      horiz := false;
      SetStrings(hit, dead);
    end
    //------------------------------------------------------\\
    //В данном блоке реализуется алгоритм атаки на поврежденный корабль
    else
    begin
      repeat
        repeat
          if (pass = 2) and (horiz or vert) then
          begin
            lastpoint := firstpoint;
            for var i := 1 to 4 do
              dirs[i] := 0;
            pass := 0;
          end;
          //После того, как будет определена ориентация корабля на карте, можем выбирать всего 2 направление.
          if horiz then
            dir := random(3, 4)  //Лево/Право.
          else if vert then 
            dir := random(1,2)   //Верх/Вниз.
          else
            dir := random(1, 4); //Ориентация пока что неопределена.
        until dirs[dir] = 0;
        dirs[dir] := 1;
        case dir of              //Вычисление координат новой точки для выстрела.              
          ToUp: 
          begin
            newPoint.x := lastpoint.x + 1;
            newPoint.y := lastpoint.y;
          end;
          ToDown:
          begin  
            newPoint.x := lastpoint.x - 1;
            newPoint.y := lastpoint.y;
          end;
          ToLeft:
          begin 
            newPoint.x := lastpoint.x;
            newPoint.y := lastpoint.y - 1;
          end;
          ToRight:
          begin  
            newPoint.x := lastpoint.x;
            newPoint.y := lastpoint.y + 1;
          end;
        end;
        pass := 0;
        for var i := 1 to 4 do
          if dirs[i] = 1 then pass += 1;
      until (((newpoint.x <= size) and (newpoint.x > 0) and (newpoint.y <= size) and (newpoint.y > 0)) 
            and (((MainState._player._map[newpoint.x, newpoint.y] = -1) 
            or (MainState._player._map[newpoint.x, newpoint.y] = 2) 
            or (MainState._player._map[newpoint.x, newpoint.y] = 3) 
            or (MainState._player._map[newpoint.x, newpoint.y] = 4))));        
      pass := 0;
      click := newPoint;
      Check(MainState._player);
      if count = 2 then  //В случае невозможности совершить выстрел из точки, в которую пришел алгоритм, 
      begin              //возвращаемся к точке - первому попаданию и совершаем выстрел в противоложном направлении.
        count += 1;
        if lastpoint.x = firstpoint.x then horiz:= true;
        if lastpoint.y = firstpoint.y then vert := true;  
      end;
    end;
  end;
  
  { Обработчик кликов мыши.                               }
  { Обрабатываются случаи нажатия в поле компьютера,      }
  { при совершении выстрела (указание точки для выстрела),}
  { нажатия на программные кнопки                         }
  procedure MouseClickGameplay(x,y, mousebutton:integer);
  begin
    if step and (MainState._gameState = MainGameState) and (mousebutton = 1) and (MainState._gameState <> EndGameState) and not pause then
    begin
      if (x > GrCrds.x + 300) and (y > GrCrds.y) and (x < GrCrds.x + GridSize + 300) and (y < GrCrds.y + GridSize) then
      begin
        click.y := (x - GrCrds.x - 300) div ((GridSize) div size) + 1;
        click.x := (y - GrCrds.y) div ((GridSize) div size) + 1;
        MainState._player._shots += 1;
        Check(MainState._computer);
        SetStrings(hit, dead);
        DrawCurrentState(not step)
      end;
    end;
    if step and (mousebutton = 1) and ((MainState._gameState = EndGameState) or (MainState._gameState = MainGameState)) then
    begin
      var b := -1;
      for var i := 1 to 2 do
        if (x > btns[i].coord.x) and (x < btns[i].coord.x + btns[i].width) and (y > btns[i].coord.y) and (y < btns[i].coord.y +  btns[i].heigth) then
          b := i;
      if not pause then
      begin
        case b of
          1:
          begin
            pause := true;
            if MainState._gameState = EndGameState then
            begin
              pause := false;
              MainState._gameState := MenuGameState;
              OnMouseDown -= MouseClickGameplay;
            end;
          end;
        end;
      end
      else
      begin
        case b of
          1:
          begin
            MainState._gameState := MenuGameState;
            OnMouseDown -= MouseClickGameplay;
            pause := false;
          end;
          2:
            pause := false;
        end;
      end;
      DrawCurrentState(not step)
    end;
  end;
End.