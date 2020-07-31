{ Модуль выполняющий всю отрисовку окна. }
Unit Drawing;
Interface
  uses GraphABC, Types, GlobalVars, GameStarting;
  procedure DrawCross(coordsOfSquare:pnt; p:integer; c: Color);
  procedure DrawGrid();
  procedure DrawShipMenu(c: Color);
  procedure InitWin();
  procedure DrawCurrentState(clicks: boolean);
  procedure ClearLabelList();
  Type
    //Тип, описывающий "программную кнопку".
    button = record
      coord:      pnt;  //Координаты левого верхнего угла прямоугольника, образующего кнопку.
      text:    string;  //Текст кнопки.
      width:  integer;  //Ширина кнопки.
      heigth: integer;  //Высота  кнопки.
    end; 
    //Тип описывающий надпись в пространстве окна.
    lbl = record
      coord: pnt;    //Координаты левого верхнего угла надписи.
      text: string;  //Текст надписи.
    end;
  Var
    btns: array[1..4] of button;  //Массив кнопок.   */Располагающихся в
    labels: array [1..7] of lbl;  //Массив надписей. */пространстве окна.
    pic: string;                  //Имя файла с изображением для вкладки информация.
Implementation
  
  { Вспомогательная процедура очистки массива кнопок. }
  { Используется при смене игровых состояний.         }
  procedure ClearButtonList();
  begin
    for var i := 1 to 4 do
      begin
        btns[i].width := -1;
        btns[i].heigth := -1;
        btns[i].coord.x := -1;
        btns[i].coord.y := -1;
        btns[i].text := '';
      end;
  end;
  
  { Вспомогательная процедура очистки массива надписей. }
  { Используется при смене игровых состояний.           }
  procedure ClearLabelList();
  begin
    for var i := 1 to 6 do
    begin
      labels[i].coord.x := 0;
      labels[i].coord.y := 0;
      labels[i].text := '';
    end;
  end;
  { Процедура, определяющая размеры окна и координаты основных управляющих структур. }
  { Размеры окна определяются в зависимости от текущего игрового состояния.          }
  { Так же при вызове процедуры происходит центрирование окна.                       }
  procedure InitWin();
  begin
    lastState := MainState._gamestate;
    SetWindowIsFixedSize(true);
    SetWindowTitle('Морской бой');
    if (MainState._gameState = MenuGameState) or (MainState._gameState = SetSizeState) then
    begin
      SetWindowWidth(500);
      SetWindowHeight(500);
    end;
    if (MainState._gameState = RecordsTableState) then
    begin
      SetWindowWidth(1200);
      SetWindowHeight(480);
    end;
    if (MainState._gameState = InfoState) then
    begin
      SetWindowWidth(897);
      SetWindowHeight(400);
    end;
    if (MainState._gameState = PlacementInfoState) then
    begin
      SetWindowWidth(975);
      SetWindowHeight(520);
    end;
    if (MainState._gameState = GameInfoState) then
    begin
      SetWindowWidth(966);
      SetWindowHeight(360);
    end;
    if (MainState._gameState = EndGameState) then
      SetWindowWidth(780);
    if (MainState._gameState = StartGameState) or (MainState._gameState = MainGameState) then
    begin
      var koef := 0;
      if size = 6 then
        koef := 76;
      if (MainState._gameState = StartGameState) then
      begin
        SetWindowWidth(970);
        SetWindowHeight(460 + koef);
      end
      else
      begin
        SetWindowWidth(650);
        SetWindowHeight(480);
      end;
      GrCrds.x := 50;
      GrCrds.y := 100;
      ShipsMenuCrds.x := GrCrds.x;
      ShipsMenuCrds.y := grCrds.y + 240 + 2 * 240 div size;
    end;  
    CenterWindow();
  end;
  
  { Процедура отрисовки креста в определенной клетке игрового поля.                }
  { Параметры: coordsOfSquare:pnt - координаты клетки,                             }
  { в которой должен быть отрисован крест, p:integer - флаг/коэффициент,           }
  {(0 - поле игрока, 1 - поле компьютера).                                         }
  { отвечающий за отрисовку на поле игрока или компьютера, c:Color - цвет креста.  }
  procedure DrawCross(coordsOfSquare:pnt; p:integer; c: Color);
  var
    width: integer; //Толщина линий креста.
  begin
    //Определение толщины линий креста в зависимости от размера размера игрового поля size.
    case size of
      6: width := 3;
      8, 10: width := 2;
      
    end;  
    SetPenWidth(width);
    if p = 1 then p := GridSize + 60;
    Line(GrCrds.x + (coordsOfSquare.x - 1) * (GridSize div size) + p, 
         GrCrds.y + (coordsOfSquare.y - 1) * (GridSize div size), 
         GrCrds.x + (coordsOfSquare.x) * (GridSize div size) + p, 
         GrCrds.y + (coordsOfSquare.y) * (GridSize div size), c);
         
    Line(GrCrds.x + coordsOfSquare.x * (GridSize div size) + p,
         GrCrds.y + (coordsOfSquare.y - 1) * (GridSize div size), 
         GrCrds.x + (coordsOfSquare.x - 1) * (GridSize div size) + p, 
         GrCrds.y + coordsOfSquare.y * (GridSize div size), c);
    SetPenWidth(1);
  end;
  
  { Процедура отрисовки точки в определенной клетке игрового поля.                 }
  { Параметры: coordsOfSquare:pnt - координаты клетки,                             }
  { в которой должна быть отрисована точка, p:integer - флаг/коэффициент,          }
  {(0 - поле игрока, 1 - поле компьютера).                                         }
  { отвечающий за отрисовку на поле игрока или компьютера, c:Color - цвет точки.   }
  procedure DrawPoint(coordsOfSquare: pnt; p: integer; c:Color);
  var
    radius: integer; //Радиус отрисовываемой точке.
  begin
    //Определение радиуса точки в зависимости от размера размера игрового поля size.
    SetBrushColor(c);
    case size of
      6: radius := 5;
      8: radius := 4;
      10: radius := 3;
    end;
    if p = 1 then p := GridSize + 60;;
    FillCircle(GrCrds.x + (coordsOfSquare.x - 1) * (GridSize div size) + (GridSize div size div 2) + p , GrCrds.y + (coordsOfSquare.y - 1) * (GridSize div size) + (GridSize div size div 2), radius);
    SetBrushColor(clWhite);
  end;
  
  { Процедура отрисовки закрашенного квадрата в определенной клетке игрового поля. }
  { Параметры: coordsOfSquare:pnt - координаты клетки,                             }
  { в которой должен быть отрисован квадрат, p:integer - флаг/коэффициент,         }
  {(0 - поле игрока, 1 - поле компьютера).                                         }
  { отвечающий за отрисовку на поле игрока или компьютера, c:Color - цвет точки.   }
  procedure DrawRect(coordsOfSquare: pnt; p: integer; c:Color);
  begin
    SetBrushColor(c);
    if p = 1 then p := 300;
    FillRectangle(GrCrds.x + (coordsOfSquare.x - 1) * (GridSize div size) + p, 
         GrCrds.y + (coordsOfSquare.y - 1) * (GridSize div size), 
         GrCrds.x + (coordsOfSquare.x) * (GridSize div size) + p, 
         GrCrds.y + (coordsOfSquare.y) * (GridSize div size)) ;
    SetBrushColor(clWhite);
  end;  
  
  { Процедура отрисовки сеток игровых полей.                            }
  { Отрисовка происходит в зависимости от размера игрового поля - size. }
  procedure DrawGrid();
  begin
   var fontsize := Font.Size;
   SetFontSize(round(100 / size));
   for var i := 0 to size do
   begin   
     Line(((GridSize * i) div size) + GrCrds.x, GrCrds.y, ((GridSize * i) div size) + GrCrds.x, GridSize + GrCrds.y, clBlack);
     Line(GrCrds.x, ((GridSize * i) div size) + GrCrds.y, GridSize + GrCrds.x,((GridSize * i) div size) + GrCrds.y, clBlack);
     Line(((GridSize * i) div size) + 300 + GrCrds.x, GrCrds.y, ((GridSize * i) div size) + 300 + GrCrds.x, GridSize + GrCrds.y, clBlack);
     Line(300 + GrCrds.x, ((GridSize * i) div size) + GrCrds.y, 540 + GrCrds.x,((GridSize * i) div size) + GrCrds.y, clBlack);   
   end;
   for var i := 1 to size do
   begin
     TextOut(GrCrds.x - 18, (GridSize * (i - 1) div size) + GrCrds.y + 5, i);
     TextOut((GridSize * (i - 1) div size) + GrCrds.x + 7, GrCrds.y - 26, chr(64 + i));  
     TextOut(280 + GrCrds.x, GridSize * (i - 1) div size + GrCrds.y + 5, i);  
     TextOut((GridSize * (i - 1) div size) + GrCrds.x + 305, GrCrds.y - 26, chr(64 + i));
   end;
   TextOut(GrCrds.x, GrCrds.y - 48, 'Ваше поле');
   TextOut(GrCrds.x + GridSize + 60, GrCrds.y - 48, 'Поле соперника');
   SetFontSize(fontsize)
  end;
  
  { Процедура отрисовки текущей игровой ситуации на игровых полях.                            }
  { Отрисовка происходит по картам игроков _map с использованием процедур реализованных выше. }
  procedure DrawCurrentGrids();
  var
    crds: pnt; //Вспомогательная переменная координат, текущей отрисовываемой клетки.
  begin
  for var i := 1 to size do
    for var j := 1 to size do
    begin
      crds.x := j;
      crds.y := i;
      if (MainState._player._map[i,j] = 1) or (MainState._player._map[i,j] = 2) or (MainState._player._map[i,j] = 3) or (MainState._player._map[i,j] = 4) then
      begin
        DrawCross(crds, 0, clBlack);
      end;
      if MainState._player._map[i,j] = -2 then
      begin
        DrawCross(crds, 0, clGray);
      end;
      if (MainState._computer._map[i,j] = 5) or (MainState._computer._map[i,j] = 10) or 
         (MainState._computer._map[i,j] = 15) or (MainState._computer._map[i,j] = 20) then
      begin
        DrawCross(crds, 1, clRed);
      end;
      if (MainState._computer._map[i,j] = 25) or (MainState._computer._map[i,j] = 50) or 
         (MainState._computer._map[i,j] = 75) or (MainState._computer._map[i,j] = 100) then
      begin
        DrawRect(crds,1, clGray);
        DrawCross(crds, 1, clBlack);
      end;
      if MainState._computer._map[i,j] = -3 then
      begin
        DrawPoint(crds, 1, clBlack);
      end;
       if (MainState._player._map[i,j] = 5) or (MainState._player._map[i,j] = 10) or 
         (MainState._player._map[i,j] = 15) or (MainState._player._map[i,j] = 20) then
      begin
        DrawRect(crds, 0, clOrange);
        DrawCross(crds, 0, clBlack);
      end;
      if (MainState._player._map[i,j] = 25) or (MainState._player._map[i,j] = 50) or 
         (MainState._player._map[i,j] = 75) or (MainState._player._map[i,j] = 100) then
      begin
        DrawRect(crds, 0, clGray);
        DrawCross(crds, 0, clBlack);
      end;
      if MainState._player._map[i,j] = -3 then
      begin
        DrawPoint(crds, 0, clBlack);
      end;      
    end;  
  end;
  
  { Процедура отрисовки кнопки.                           }
  { Параметры: btn: button - объект отрисовываемой кнопки }
  { c: Color - цвет прямоугольника и текста кнопки.       }
  { Передача цвета используется для того, чтобы показать  }
  { пользователю неактивные кнопки.                       }
  procedure DrawButton(btn: button; c:Color);
  begin
    SetPenColor(c);
    Font.Color := c;
    DrawRectangle(btn.coord.x, btn.coord.y, btn.coord.x + btn.width, btn.coord.y + btn.heigth);
    TextOut((btn.coord.x + btn.width div 2) - Length(btn.text) * 5, btn.coord.y + btn.heigth div 2 - 10, btn.text);
    SetPenColor(clBlack);
    Font.Color := clBlack;
  end;
  
  { Процедура отрисовки текущего состояния окна.                     }
  { Параметры clicks: boolean - флаг,                                }
  { применяющийся для показа пользователю неактивных                 }
  { элементов  (True - выделить неактивные элементы).                }
  { В каждой ветке, зависящей от игрового состояния, выполняется     }
  { заполнение массива кнопок и массива надписей (при надобности) и  }
  { вызов нужных процедур отрисовки.                                 }
  procedure DrawCurrentState(clicks: boolean);
  Var
    c: Color;       //Цвет отрисовки управляющих элементов (используется для неактивных элементов).
    records: text;  //Файл для получения данных таблиц рекордов, для их отрисовки.
  begin
    //При изменении игрового состояния вызывается процедура инициализации окна.
    if lastState <> MainState._gameState then
      InitWin();
    LockDrawing();  //Вызов процедур для
    clearwindow();  //реализации двойной буферезации.
    if clicks or ((MainState._gameState = StartGameState) and pause) then
      c := clGray
    else
      c := clBlack;    
    if MainState._gameState = MenuGameState then
    begin
      ClearButtonList();
      ClearLabelList();
      var p := new Picture(426, 87);
      p.Load('assets/logo.png');
      p.Draw((500 - 426) div 2,30);
      for var i := 1 to 4 do
      begin
        btns[i].width := 300;
        btns[i].heigth := 50;
        btns[i].coord.x := (500 - btns[i].width) div 2;
        btns[i].coord.y := 150 + i * (btns[i].heigth + 10);
      end;
      btns[1].text := 'Начать новую игру';
      btns[2].text := 'Таблица рекордов';
      btns[3].text := 'Информация';
      btns[4].text := 'Выход';
      SetFontSize(15);
      for var i := 1 to 4 do
        DrawButton(btns[i], c);
      var size := Font.Size;
      Font.Size := 10;
      TextOut(190, 480, 'Разработчик: студент группы 9413 Асташкин М.С.');
      Font.Size := size;
    end
    else if MainState._gameState = RecordsTableState then
    begin
      ClearButtonList();
      ClearLabelList();
      for var i := 1 to 3 do
      begin
        var koeff := 0;
        if i = 3 then
          koeff := -20;
        labels[i].coord.x := 100 + koeff + (i - 1) * 400;
        labels[i].coord.y := 25;
        labels[i].text := 'Таблица для поля ' + (i + 2) * 2 + 'x' + (i + 2) * 2;
        TextOut(labels[i].coord.x, labels[i].coord.y, labels[i].text);
        line(100 + i * 300 + (i - 1) * 100, 10, 100 + i * 300 + (i - 1) * 100, WindowHeight() - 100);
      end;
      line(50, 70, 1157, 70);
      line(50, WindowHeight() - 100, 1157, WindowHeight() - 100);
      for var i := 4 to 6 do
      begin
        labels[i].coord.x := 50 + (i - 4) * 400;
        labels[i].coord.y := 47;
        labels[i].text := 'Имя' + ' ' *  31 + 'Выстрелы';
        TextOut(labels[i].coord.x, labels[i].coord.y, labels[i].text);
      end;
      btns[1].width := 300;
      btns[1].heigth := 50;
      btns[1].coord.x := WindowWidth() - 350;
      btns[1].coord.y := WindowHeight() - 75;
      btns[1].text := 'Назад';
      DrawButton(btns[1], clBlack); 
      var j := 6;
      while j <= 10 do
      begin
        assign(records, 'records/records' + j + '.txt');
        if fileexists('records/records' + j + '.txt') then
        begin
          reset(records);
          var quantity := 0;         //Количество записей в таблице рекордов.
          while (not eof(records)) and (quantity <> 10) do //Ограничение на отображение 10 записей в таблице.
          begin
            var str := '';           //Строка, считываемая из файла с таблицей рекордов.
            var nick := '';          //Строка с именем игрока.
            var sht := '';           //Строка с количеством выстрелов игрока.
            readln(records, str);
            var p := pos(' ', str);  //Позиция пробела в строке, полученной из файла.
            for var i := 1 to p - 1 do
              nick += str[i];
            for var i := p + 1 to length(str) do
              sht += str[i];
            var err := 0;
            Textout(50 + (j - 6) * 200, 80 + quantity * 30, quantity + 1 + '.' + nick);
            TextOut(262 + (j - 6) * 200, 80 + quantity * 30, sht);
            quantity += 1;
          end;
          close(records);
        end;
        j += 2;
      end;
    end
    else if (MainState._gameState = InfoState) or (MainState._gameState = PlacementInfoState) or (MainState._gameState = GameInfoState) then
    begin
      ClearButtonList();
      ClearLabelList();
      btns[1].width := 150;
      btns[1].heigth := 50;
      btns[1].coord.x := WindowWidth() - 200;
      btns[1].coord.y := WindowHeight() - 75;
      btns[1].text := 'Назад';
      var p := new Picture(1, 1);
      if (MainState._gameState = InfoState) then
      begin
        for var i := 2 to 3 do
        begin
          btns[i].width := 300;
          btns[i].heigth := 50;
          btns[i].coord.x := 300;
          btns[i].coord.y := 200 + (i - 2) * 70;
        end;
        btns[2].text := 'Расстановка кораблей';
        btns[3].text := 'Игровой процесс';
        for var i := 2 to 3 do
          DrawButton(btns[i], clBlack);
        p.Load('assets/MainInfo.png');
      end;
      if (MainState._gameState = PlacementInfoState) then
        p.Load('assets/Info1.png');
      if (MainState._gameState = GameInfoState) then
        p.Load('assets/Info2.png');
      p.Draw(0,0);
      DrawButton(btns[1], clBlack);
    end
    else if MainState._gameState = NickInputState then
    begin
      ClearButtonList();
      TextOut(80, 150, 'Введите имя:');
      DrawRectangle(210, 150, 405, 175); 
      TextOut(213, 151, MainState._player._name);
      for var i := 1 to 2 do
      begin
        btns[i].width := 300;
        btns[i].heigth := 50;
        btns[i].coord.x := (500 - btns[i].width) div 2;
        btns[i].coord.y := 270 + i * (btns[i].heigth + 10);
      end;
      btns[1].text := 'Продолжить';
      btns[2].text := 'Назад';
      for var i := 1 to 4 do
        DrawButton(btns[i], c);
      if labels[1].text <> '' then
        TextOut(labels[1].coord.x, labels[1].coord.y, labels[1].text);
    end
    else if MainState._gameState = SetSizeState then
    begin
      ClearButtonList();
      ClearLabelList();
      TextOut(130, 100, 'Выберите размер карты: ');
      for var i := 1 to 3 do
      begin
        btns[i].width := 100;
        btns[i].heigth := 30;
        btns[i].coord.x := (500 - btns[i].width) div 2;
        btns[i].coord.y := 100 + i * (btns[i].heigth + 10);
      end;
      btns[1].text := '6x6';
      btns[2].text := '8x8';
      btns[3].text := '10x10';
      btns[4].text := 'Назад';
      btns[4].width := 300;
      btns[4].heigth := 50;
      btns[4].coord.x := (500 - btns[4].width) div 2;
      btns[4].coord.y := 150 + 4 * (btns[4].heigth + 10);
      SetFontSize(15);
      for var i := 1 to 4 do
        DrawButton(btns[i], c);
    end
    else if MainState._gameState = StartGameState then
    begin
      ClearButtonList();
      ClearLabelList();
      DrawGrid();
      DrawShipMenu(c);
      DrawCurrentGrids();
      if not pause then
      begin
        for var i := 1 to 2 do
        begin
          btns[i].width := 200;
          btns[i].heigth := 50;
          btns[i].coord.x := GrCrds.x + GridSize * 2 + 90;
          btns[i].coord.y := GrCrds.y + (i - 1) * (btns[i].heigth + 140);
        end;
        btns[1].text := 'Случайно';
        btns[2].text := 'Назад';
        if curShip = 0 then
        begin
            btns[3].width := 200;
            btns[3].heigth := 50;
            btns[3].coord.x := GrCrds.x + GridSize * 2 + 90;
            btns[3].coord.y := GrCrds.y + btns[1].heigth * 2 - 5;
            btns[3].text := 'Начать игру';
        end; 
      end
      else
      begin
        btns[2].width := 100;
        btns[2].heigth := 50;
        btns[2].coord.x := GrCrds.x + GridSize * 2 + 90;
        btns[2].coord.y := GrCrds.y + GridSize - 50;
        btns[2].text := 'Да';
        btns[3].width := 100;
        btns[3].heigth := 50;
        btns[3].coord.x := btns[2].coord.x + btns[2].width + 40;
        btns[3].coord.y := btns[2].coord.y;
        btns[3].text := 'Нет';
        TextOut(btns[2].coord.x, btns[2].coord.y - 30, 'Вы точно хотите выйти?');
      end;
        if pause then
        c := clBlack;
      for var i := 1 to 4 do
        DrawButton(btns[i], c);
      for var i := 1 to 7 do
        Textout(labels[i].coord.x, labels[i].coord.y, labels[i].text);
    end     
    else if MainState._gameState = MainGameState then
    begin
      ClearButtonList();
      DrawCurrentGrids();
      DrawGrid();
      btns[1].coord.x := GrCrds.x;
      btns[1].coord.y := GrCrds.y + GridSize + 50;
      btns[1].width := 320;
      btns[1].heigth := 50;
      if not pause then
        btns[1].text := 'Выйти в главное меню'
      else
      begin
        btns[1].text := 'Да';
        btns[1].width := 100;
        btns[2].text := 'Нет';
        btns[2].heigth := btns[1].heigth;
        btns[2].width := 100;
        btns[2].coord := btns[1].coord;
        btns[2].coord.x += btns[1].width + 20;
        TextOut(btns[1].coord.x, btns[1].coord.y + btns[1].heigth + 10, 'Вы точно хотите выйти?');
      end;
      for var i := 1 to 3 do
        if labels[i].text <> '' then
          TextOut(labels[i].coord.x, labels[i].coord.y, labels[i].text);
      DrawButton(btns[1], c);
      DrawButton(btns[2], c);
    end
    else if MainState._gameState = EndGameState then
    begin
      DrawCurrentGrids();
      DrawGrid();
      DrawButton(btns[1], c);
      if MainState._winner then
        TextOut(GrCrds.x - 10, 20, 'Игра окнчена. Победа ' + MainState._player._name + '. Количество выстрелов:' + MainState._player._shots)
      else
        TextOut(GrCrds.x - 10, 20, 'Игра окнчена. Победа компьютера.' + ' Количество выстрелов:' + MainState._player._shots)
    end;
    ReDraw(); //Процедура для реализации двойной буферезации.
  end;
  
  
  { Процедура отрисовки меню выбора кораблей при их расстановке пользователем }
  { Параметры: c:Color - цвет отрисовки элементов, из которых состоит меню.   }
  procedure DrawShipMenu(c: Color);
  var
    len: integer;          //Размер квадратов (в пикселях), из которых состоят корабли в меню.
    _shipsmenucrds: pnt;   //Вспомогательные координаты, фактически указывающее на текущий отрисовываемый элемент меню.
  begin
    TextOut(30,30, 'Расставьте ваши корабли, используя меню расстановки корабелй снизу или кнопку "Случайно"');
    _shipsmenucrds := ShipsMenuCrds;
    len := GridSize div size;
    SetPenColor(c);
    TextOut(_shipsmenucrds.x,  _shipsmenucrds.y - len, 'Выбор корабля');
    var i := 1;
    while (i < 5) do
    begin
      if MainState._player.ShipsPlacementCount[i] = 0 then SetPenColor(clGray)
      else
        SetPenColor(c);
      TextOut(_shipsmenucrds.x + len div 3,  _shipsmenucrds.y + len, MainState._player.ShipsPlacementCount[i]);
      for var j := 1 to i do
      begin
        DrawRectangle(_shipsmenucrds.x,  _shipsmenucrds.y,  _shipsmenucrds.x + len, _shipsmenucrds.y + len);
         _shipsmenucrds.x += len;
      end;
       _shipsmenucrds.x += + len;
      i += 1;
    end;
    TextOut( _shipsmenucrds.x, _shipsmenucrds.y - 1, 'Выбранный корабль: ' + curShip);
    SetPenColor(clBlack);
  end;

end.