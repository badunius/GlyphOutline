unit uGlyph;

interface

uses
  Graphics, Math, uQPixels;

type
  myGlyphRender = class
    procedure Render(glyph: word; dest: TCanvas; x, y: integer; outline: double = 0);
  end;

implementation

{ myGlyphRender }

procedure myGlyphRender.Render(glyph: word; dest: TCanvas; x, y: integer; outline: double);
var
  // шпаргалка с расстояниями
  dist: array of array of double;
  // буферный битмап
  buff: TBitMap;
  // я ебал эти ваши сканлайны, поэтому QP
  bp: TQuickPixels;
  // цвет
  col: TColor;
  // компоненты цвета
  r, g, b: byte;
  // координаты и паддинг
  u, v,
  uu, vv,
  l: integer;
  // кратчайшее расстояние
  d, md: double;
begin
  // рендерим на указанную канву, используя её шрифт, в указанную точку

  // готовим шпаргалку
  l := Ceil(outline);
  setLength(dist, l + 1);
  for u := 0 to l do begin
    setLength(dist[u], l + 1);
    for v := 0 to l do
      dist[u, v] := SQRT(u * u + v * v);
  end;

  // готовим буфер
  buff := TBitMap.Create;
  buff.PixelFormat := pf32bit;
  buff.Canvas.Font := dest.Font;
  buff.Canvas.Font.Color := clBlack;
  buff.Width := dest.TextWidth(chr(glyph)) + l * 2;
  buff.Height := dest.TextHeight(chr(glyph)) + l * 2;

  // готовим QP
  bp := TQuickPixels.Create;
  bp.Attach(buff);

  // Выводим в буфер глиф стандартными средствами
  buff.Canvas.TextOut(l, l, chr(glyph));

  // строим в буфере карту яркости (красный канал)
  for u := 0 to buff.Width - 1 do
    for v := 0 to buff.Height - 1 do begin
      col := bp[u, v];
      r := Byte(col);
      g := Byte(col shr 8);
      b := Byte(col shr 16);
      // считаем яркость и пишем её в R
      r := 255 - Round(r * 0.2126 + g * 0.7152 + b * 0.0722);
      g := 0;
      b := 0;
      // в rgb R - младший байт
      bp[u, v] := TColor(r or (g shl 8) or (b shl 16));
    end;

  // строим в буфере карту прозрачности (зелёный канал)
  for u := 0 to buff.Width - 1 do
    for v := 0 to buff.Height - 1 do begin
      col := bp[u, v];

      // забираем яркость, остальное нам не нужно
      r := Byte(col);
      // если это совсем непрозрачный пиксель, то ловить тут вообще нехуй
      if r = 255 then begin
        // вот только прозрачность ему пропишем
        g := 255;
        b := 0;
        bp[u, v] := TColor(r or (g shl 8) or (b shl 16));
        // и скипаем
        Continue;
      end;

      // обходим +/-L соседних пикселей и ищем кратчайшее расстояние до непрозрачного пикселя
      md := l + 1;
      // обход делаем только для совсем прозрачных пикселей (полупрозрачные явно попадут)
      if r = 0 then
      for uu := u - l to u + l do begin
        // скипаем заграничные пиксели
        if (uu >= 0) and (uu < buff.Width) and (md > 0) then
          for vv := v - l to v + l do begin
            // скпиаем заграничные
            if (vv < 0) or (vv >= buff.Height)
              then Continue;
            // достаём яркость (она же прозрачность)
            g := Byte(bp[uu, vv]);
            // нет яркости - скипаем
            if g < 1
              then Continue;
            // достаём из шпаргалки расстояние
            d := dist[Abs(uu - u), Abs(vv - v)];
            // добавляем к нему поправку за яркость
            d := d + (1 - g / 255);
            // проверяем меньше ли оно
            if d < md
              then md := d;
            // если мы впилились в ноль, то дальше искать нет смысла
            if md = 0
              then Break;
          end;
      end;

      // если пиксель полупрозрачный, то минимальное расстояние = 0
      if r > 0
        then md := 0;

      // сейчас у нас в MD расстояние до ближайшего непрозрачного пикселя
      // если оно меньше аутлайна - супер, это пиксель аутлайна
      // если оно в пределах аутлайн..аутлайн+1 - это полупрозрачный пиксель аутлайна
      // если оно больше аутлайн+1 - то это за пределами аутлайна

      // -- ОПРЕДЕЛЯЕМ СТЕПЕНЬ АУТЛАЙНОВОСТИ --
      md := md - outline;
      if md < 0
        then md := 0;
      md := 1 - md;
      if md < 0
        then md := 0;

      // на данный момент 1 - самый интенсивный, 0 - самый прозрачный
      g := Round(255 * md);

      // теперь у меня тупняк
      // если аутлайн ноль, то мы должны задать прозрачность = яркости, а яркость = 1 для полупрозрачных пикселей
      // если аутлайн больше нуля (уже хорошо) то мы должны задать прозрачность = g...

      if (outline > 0) then begin
        // если аутлайн есть, оставляем яркость как есть
        // а прозрачность... тоже =/
        // чё-т какой-то индусский код получается
      end else begin
        // если аутлайна нет
        // ставим прозрачность равную яркости
        g := r;
       // ставим максимальную яркость
        r := 255;
      end;
      // пишем наш пиксель обратно
      b := 0;
      bp[u, v] := TColor(r or (g shl 8) or (b shl 16));
    end;

  // ебашим наш буфер на канву
  dest.Draw(x, y, buff);
  // красный - яркость
  // зелёный - прозрачность

  // и освобождаем ресурсы
  bp.Free;
  buff.Free;
end;

end.
