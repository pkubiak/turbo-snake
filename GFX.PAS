Unit Gfx;

interface
  procedure init_13h;
  procedure exit_13h;
  procedure put_pixel(x, y: word; color: byte);
  procedure clear_screen(color: byte);
  procedure box(x, y, w, h: word; color: byte);

implementation

  procedure init_13h;
  begin
    asm
      mov ax, 13h;
      int 10h; {Video BIOS interrupt}
    end;
  end;

  procedure exit_13h;
  begin
    asm
      mov ax, 3;
      int 10h;
    end;
  end;

  procedure put_pixel(x, y: word; color: byte);
  begin
    asm
      mov ax, 0A000h;
      mov es, ax;
      mov ax, y;
      mov bx, x;
      mov cx, 320;
      mul cx;
      add ax, bx;
      mov di, ax;
      mov dl, color;
      mov [es:di], dl;
    end;
  end;

  procedure clear_screen(color: byte);
  var
    x, y: word;
  begin
    for y:=0 to 199 do
      for x:=0 to 319 do
        put_pixel(x, y, color);

  end;

  procedure box(x, y, w, h: word; color: byte);
  var
    i, j: word;
  begin
    for i:=0 to w-1 do
      for j:=0 to h-1 do
        put_pixel(x+i, y+j, color);
  end;
end.
