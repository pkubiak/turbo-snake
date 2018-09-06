Program TurboSnake;
uses
    Fonts, Gfx;
var
  x,y:word;
  s: string;
begin
  init_13h;

  put_pixel(10, 10, 10);
  clear_screen(11);

  (*for x:=0 to 319 do
  begin
      for y:=0 to 199 do
      begin
          put_pixel(x, y, (x+y) mod 256);
      end;
  end;*)

  for x:=0 to 15 do
    begin
      Str(x, s);
      put_text(BoldFont, 10, 10*(x+1)+10, 1, s);
      put_text(BoldFont, 10+16*(x+1), 10+0, 1, s);
      for y:=0 to 15 do
      begin
        {put_text(BoldFont, 10+16*(x+1), 10+10*(y+1), 16*x + y, '#');}
        box(10 + 16*(x+1) -1, 10+10*(y+1) -2, 9, 9, 0);
        box(10 + 16*(x+1), 10+10*(y+1) -1, 7, 7, 16*x+y);
      end;
    end;
  (* put_text(BoldFont, 10, 10, 41, 'int main() {\n  printf("Hello World!");\n}\n'); *)
  (* put_text(BoldFont, 10, 10, 102, 'int main() {\n  printf("Hello World!");\n}\n'); *)
  {put_text(BoldFont, 10, 9, 12, 'Hello World!');}

  readln(x);
  exit_13h;
end.
