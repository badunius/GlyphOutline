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
  // ��������� � ������������
  dist: array of array of double;
  // �������� ������
  buff: TBitMap;
  // � ���� ��� ���� ���������, ������� QP
  bp: TQuickPixels;
  // ����
  col: TColor;
  // ���������� �����
  r, g, b: byte;
  // ���������� � �������
  u, v,
  uu, vv,
  l: integer;
  // ���������� ����������
  d, md: double;
begin
  // �������� �� ��������� �����, ��������� � �����, � ��������� �����

  // ������� ���������
  l := Ceil(outline);
  setLength(dist, l + 1);
  for u := 0 to l do begin
    setLength(dist[u], l + 1);
    for v := 0 to l do
      dist[u, v] := SQRT(u * u + v * v);
  end;

  // ������� �����
  buff := TBitMap.Create;
  buff.PixelFormat := pf32bit;
  buff.Canvas.Font := dest.Font;
  buff.Canvas.Font.Color := clBlack;
  buff.Width := dest.TextWidth(chr(glyph)) + l * 2;
  buff.Height := dest.TextHeight(chr(glyph)) + l * 2;

  // ������� QP
  bp := TQuickPixels.Create;
  bp.Attach(buff);

  // ������� � ����� ���� ������������ ����������
  buff.Canvas.TextOut(l, l, chr(glyph));

  // ������ � ������ ����� ������� (������� �����)
  for u := 0 to buff.Width - 1 do
    for v := 0 to buff.Height - 1 do begin
      col := bp[u, v];
      r := Byte(col);
      g := Byte(col shr 8);
      b := Byte(col shr 16);
      // ������� ������� � ����� � � R
      r := 255 - Round(r * 0.2126 + g * 0.7152 + b * 0.0722);
      g := 0;
      b := 0;
      // � rgb R - ������� ����
      bp[u, v] := TColor(r or (g shl 8) or (b shl 16));
    end;

  // ������ � ������ ����� ������������ (������ �����)
  for u := 0 to buff.Width - 1 do
    for v := 0 to buff.Height - 1 do begin
      col := bp[u, v];

      // �������� �������, ��������� ��� �� �����
      r := Byte(col);
      // ���� ��� ������ ������������ �������, �� ������ ��� ������ �����
      if r = 255 then begin
        // ��� ������ ������������ ��� ��������
        g := 255;
        b := 0;
        bp[u, v] := TColor(r or (g shl 8) or (b shl 16));
        // � �������
        Continue;
      end;

      // ������� +/-L �������� �������� � ���� ���������� ���������� �� ������������� �������
      md := l + 1;
      // ����� ������ ������ ��� ������ ���������� �������� (�������������� ���� �������)
      if r = 0 then
      for uu := u - l to u + l do begin
        // ������� ����������� �������
        if (uu >= 0) and (uu < buff.Width) and (md > 0) then
          for vv := v - l to v + l do begin
            // ������� �����������
            if (vv < 0) or (vv >= buff.Height)
              then Continue;
            // ������ ������� (��� �� ������������)
            g := Byte(bp[uu, vv]);
            // ��� ������� - �������
            if g < 1
              then Continue;
            // ������ �� ��������� ����������
            d := dist[Abs(uu - u), Abs(vv - v)];
            // ��������� � ���� �������� �� �������
            d := d + (1 - g / 255);
            // ��������� ������ �� ���
            if d < md
              then md := d;
            // ���� �� ��������� � ����, �� ������ ������ ��� ������
            if md = 0
              then Break;
          end;
      end;

      // ���� ������� ��������������, �� ����������� ���������� = 0
      if r > 0
        then md := 0;

      // ������ � ��� � MD ���������� �� ���������� ������������� �������
      // ���� ��� ������ �������� - �����, ��� ������� ��������
      // ���� ��� � �������� �������..�������+1 - ��� �������������� ������� ��������
      // ���� ��� ������ �������+1 - �� ��� �� ��������� ��������

      // -- ���������� ������� ������������� --
      md := md - outline;
      if md < 0
        then md := 0;
      md := 1 - md;
      if md < 0
        then md := 0;

      // �� ������ ������ 1 - ����� �����������, 0 - ����� ����������
      g := Round(255 * md);

      // ������ � ���� ������
      // ���� ������� ����, �� �� ������ ������ ������������ = �������, � ������� = 1 ��� �������������� ��������
      // ���� ������� ������ ���� (��� ������) �� �� ������ ������ ������������ = g...

      if (outline > 0) then begin
        // ���� ������� ����, ��������� ������� ��� ����
        // � ������������... ���� =/
        // ��-� �����-�� ��������� ��� ����������
      end else begin
        // ���� �������� ���
        // ������ ������������ ������ �������
        g := r;
       // ������ ������������ �������
        r := 255;
      end;
      // ����� ��� ������� �������
      b := 0;
      bp[u, v] := TColor(r or (g shl 8) or (b shl 16));
    end;

  // ������ ��� ����� �� �����
  dest.Draw(x, y, buff);
  // ������� - �������
  // ������ - ������������

  // � ����������� �������
  bp.Free;
  buff.Free;
end;

end.
