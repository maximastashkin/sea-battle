{ Модуль, реализующий поведение при использовании пунктов и подпунктов игрового меню. }
Unit Menu;
Interface
  uses Types, GlobalVars, Drawing, GameStarting, GraphABC, ShipPlacement;
  procedure MouseClickMenu(x,y, mousebutton:integer);
  procedure NickInputKeyDown(k: char);
    
Implementation

  { Оработчик кликов мыши в меню.                              }
  { При нажатии на кнопки проихсодит смена игрового состояния. }
  { Также в некоторых случая смена обработчика кликов мыши.    }
  procedure MouseClickMenu(x,y, mousebutton:integer);
  var 
    b: integer;  //Индекс нажатой кнопки в массиве кнопок в Drawing.
  begin
    b := -1;
    for var i := 1 to 4 do
      if (x > btns[i].coord.x) and (x < btns[i].coord.x + btns[i].width) and (y > btns[i].coord.y) and (y < btns[i].coord.y +  btns[i].heigth) then
        b := i;
    if MainState._gameState = MenuGameState then
    begin
      case b of
        1:                                              //Программная кнопка - "Начать новую игру".
        begin
          MainState._player._name := '';
          MainState._gameState := NickInputState;     
          OnKeyPress += NickInputKeyDown;             
        end;                                          
        2: MainState._gameState := RecordsTableState;   //Программная кнопка - "Таблица рекодов".
        3:
        begin
          pic := 'MainInfo';
          MainState._gameState := InfoState;
        end;
        4: halt();                                      //Программная кнопка - "Выход".
      end;
    end
    else if MainState._gameState = RecordsTableState then
      case b of
        1: MainState._gameState := MenuGameState;       //Программная кнопка - "Назад".
      end
    else if MainState._gameState = InfoState then
      case b of
        1: MainState._gameState := MenuGameState;       //Программная кнопка - "Назад".
        2: MainState._gameState := PlacementInfoState;  //Программная кнопка - "Расстановка кораблей".
        3: MainState._gameState := GameInfoState;       //Программная кнопка - "Игровой процесс".
      end
    else if (MainState._gameState = PlacementInfoState) or (MainState._gameState = GameInfoState) then
      case b of
        1: MainState._gameState := InfoState;           //Программная кнопка - "Назад".
      end
    else if MainState._gameState = NickInputState then
    begin
      case b of
        1:                                              //Программная кнопка - "Продолжить".
        begin
          if Length(MainState._player._name) > 0 then
          begin
            MainState._gameState := SetSizeState;
            OnKeyPress -= NickInputKeyDown;
            labels[1].text := '';
          end
          else
          begin  
            labels[1].coord.x := 75;
            labels[1].coord.y := 120;
            labels[1].text := 'Имя игрока не должно быть пустым!';
          end;
        end;
        2:                                              //Программная кнопка - "Назад".
        begin
          MainState._gameState := MenuGameState;
          OnKeyPress -= NickInputKeyDown;
          labels[1].text := '';
        end;
      end;
    end
    else if MainState._gameState = SetSizeState then
    begin
      case b of
        1: size := 6;                                  //Программная кнопка - "6x6".
        2: size := 8;                                  //Программная кнопка - "8x8".
        3: size := 10;                                 //Программная кнопка - "10x10".
      end;
      if (b = 1) or (b = 2) or (b = 3) then 
      begin
        SetStartMap(MainState._player);
        SetStartMap(MainState._computer);
        curShip := 1;
        SetShips();
        MainState._gameState := StartGameState;
        pause := false;
        labels[7].text := '';
        SetCountInMenu();
        OnMouseDown += MouseClickShipPlacement;
        DrawCurrentState(false);
      end
      else if b = 4 then                              //Программная кнопка - "Назад".
      begin
        OnKeyPress += NickInputKeyDown;
        MainState._gameState := NickInputState;
      end;
    end;
    if (MainState._gameState = MenuGameState) or (MainState._gameState = RecordsTableState) or (MainState._gameState = InfoState) or 
       (MainState._gameState = PlacementInfoState) or (MainState._gameState = GameInfoState) or (MainState._gameState = NickInputState) or 
       (MainState._gameState = SetSizeState) then
      DrawCurrentState(false); 
  end;
  
  { Обработчик нажатий клавиш на клавиатуре.                                                                   }
  { Используется при NickInputState для ввода никнейма в поле для ввода.                                       }
  { В процедуре происходит проверка ввода (Заглавные и строчные латинские буквы, цифры, нижнее подчеркивание). }
  procedure NickInputKeyDown(k: char);
  Const
    A_CODE = 65;  
    Z_CODE = 90;        //*
    A_LOW_CODE = 97;    //Набор ASCII кодов,
    Z_LOW_CODE = 122;   //используемых для валидации ввода.
    ZERO_CODE = 48;     //*
    NINE_CODE = 57;
    UNDERSCORE_CODE = 95;
  begin
    if (ord(k) = 8) then
    begin
      if Length(MainState._player._name) > 0 then
        delete(MainState._player._name, Length(MainState._player._name), 1);
    end
    else if (((ord(k) >= A_CODE) and (ord(k) <= Z_CODE)) or ((ord(k) >= A_LOW_CODE) and 
            (ord(k) <= Z_LOW_CODE)) or (ord(k) = UNDERSCORE_CODE) or ((ord(k) >= ZERO_CODE) and (ord(k) <= NINE_CODE))) 
            and (Length(MainState._player._name) < 12) then
      MainState._player._name := MainState._player._name + k;
    DrawCurrentState(false);
  end;
End.