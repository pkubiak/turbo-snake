(* 21/08/2018 Pawel Kubiak *)
program turbo_snake;
uses Dos;

const
  WIDTH = 20; { map width in 5x5 tiles }
  HEIGHT = 16; { map height in 5x5 tiles }
  MAP_SIZE = WIDTH * HEIGHT;
  BORDER_COLOR = 11;
  KEY_ESC = 1; KEY_LEFT = 75; KEY_RIGHT = 77; KEY_UP = 72; KEY_DOWN = 80;

type
  BITMAP_FONT = array[char] of word;
  MAP_TYPE = record
    torus: boolean;
    tiles: array[0..MAP_SIZE] of char;
  end;
  SNAKE_TYPE = record
    sx, sy: word; { head position }
    dir: word; { movement direction }
    length: word;
    tails: array[0..MAP_SIZE] of word;
    t_start, t_end: word;
  end;

var
  font: BITMAP_FONT;
  map: MAP_TYPE;
  time, score, level: word; { variables to show in HUD }
  keys: array[byte] of boolean;
  snake: SNAKE_TYPE;
  game_state: byte; { GAME_STATE: 0 -> playable, 1 -> died, 2 -> exit }

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

procedure put_hline(x, y, w: word; color: byte; dashed: boolean);
var i: word;
begin
  for i:=0 to w-1 do
    if ((not dashed) or ((((x+i) xor y) and 1) <> 0)) then put_pixel(x+i, y, color);
end;

procedure put_vline(x, y, h: word; color: byte; dashed: boolean);
var i: word;
begin
  for i := 0 to h - 1 do
    if((not dashed) or ((x xor (y+i)) and 1 <> 0)) then put_pixel(x, y+i, color);
end;

procedure put_box(x, y, w, h: word; color: byte);
var i,j: word;
begin
  for i := 0 to w - 1 do
    for j := 0 to h - 1 do
      put_pixel(x + i, y + j, color);
end;

procedure put_obox(x, y, w, h: word; color: byte; dashed: boolean); { draw box outline }
begin
 put_hline(x, y, w, color, dashed);
 put_hline(x, y+h-1, w, color, dashed);
 put_vline(x, y, h, color, dashed);
 put_vline(x+w-1, y, h, color, dashed);
end;
(* ----- TEXT PROCEDURED ----- *)

procedure init_font;
begin
  font['0'] := 31599;
  font['1'] := 11415;
  font['2'] := 29671;
  font['3'] := 29391;
  font['4'] := 19401;
  font['5'] := 31183;
  font['6'] := 31215;
  font['7'] := 29257;
  font['8'] := 31727;
  font['9'] := 31695;
  font[':'] := 1040;
  font['-'] := 448;
end;

procedure put_char(x, y: word; color: byte; char: word);
Var i: word; c: byte;
begin
  for i:=0 to 15 do
  begin
    if ((char and (1 shl (14-i))) <> 0) then c := color else c := 0;
    put_pixel(x + (i mod 3), y + (i div 3), c);
  end;
end;

procedure put_text(x, y: word; color: byte; text: string);
Var i: byte;
begin
  for i:=1 to byte(text[0]) do put_char(x + 4*i - 4, y, color, font[text[i]]);
end;

(* ----- KEYBOARD SETUP ----- *)
procedure set_keyboard(enabled: boolean);
begin
  if (enabled) then
  begin
    port[$21] := $02;
    asm
      mov ah, 03h;
      mov bl, 1Fh;
      mov bh, 00h;
      int 16h;
    end;
  end else
  begin
    port[$21] := $00;
  end;
end;

procedure check_keys;
var temp: byte;
begin
  temp := port[$64];
  if ((temp and 1) = 0) then exit;
  if ((temp and 32) = 32) then
  begin
    temp := port[$60];
    exit;
  end;

  temp := port[$60];
  if temp = 0 then exit;
  if temp >= 128 then keys[temp-128] := False
  else keys[temp] := True;
end;

(* ----- MAP PROCEDURES ----- *)
procedure generate_map;
var x, y: word; tile: char;
begin
  map.torus := boolean(random(2));
  for y:=0 to HEIGHT - 1 do
    for x:=0 to WIDTH - 1 do
    begin
      if random(40) = 0 then tile := 'x' else tile := ' ';
      map.tiles[y * WIDTH + x] := tile;
    end;
  { place cherry }
  map.tiles[random(HEIGHT) * WIDTH + random(WIDTH)] := 'c';
  inc(level);
  snake.sx := random(WIDTH);
  snake.sy := random(HEIGHT);
  snake.dir := random(4);
end;

procedure draw_cherry(x, y: word);
begin
  put_box(x, y, 5, 5, 40);

  { make box round }
  put_pixel(x, y, 0); put_pixel(x+4, y, 0); put_pixel(x, y+4, 0); put_pixel(x+4, y+4, 0);

  { draw leaf}
  put_pixel(x+2, y, 47); put_pixel(x+2, y-1, 47); put_pixel(x+3, y-1, 47);
end;

function zfill(number, places: word): string;
var out: string;
begin
  Str(number, out);
  while byte(out[0]) < places do out := '0' + out;
  zfill := out;
{  zfill := '00005';}
end;

procedure draw_snake(ox, oy: word);
var i, x, y: word;
begin
  i := snake.t_end;
  while True do
  begin
    x := snake.tails[i] mod WIDTH;
    y := snake.tails[i] div WIDTH;
    put_box(ox + 5*x, oy + 5*y, 5, 5, 40);
    if i = snake.t_start then break;
    i := (i+1) mod MAP_SIZE;
  end
end;

procedure draw_map; { size of output is (5*WIDTH+2)x(5*HEIGHT+2) }
var x, y, ox, oy, wx, wy, px, py: word; color: byte; tile: char;
begin
  wx := 5 * WIDTH + 2; wy := 5 * HEIGHT + 2;
  ox := (320 - wx) div 2;
  oy := (200 - wy) div 2;

  put_obox(ox, oy, wx, wy, BORDER_COLOR, map.torus);
  for y := 0 to HEIGHT - 1 do
    for x := 0 to WIDTH - 1 do
      begin
        tile := map.tiles[y * WIDTH + x];
        px := ox + 1 + 5*x; py := oy + 1 + 5*y;
        if tile = 'x' then put_box(px, py, 5, 5, BORDER_COLOR);
        if tile = ' ' then put_box(px, py, 5, 5, 0);
        if tile = 'c' then draw_cherry(px, py);
      end;
  draw_snake(ox + 1, oy + 1);
  put_text(ox, oy - 7, 36, zfill(time div 60, 2) + ':' + zfill(time mod 60, 2));
  put_text(ox + wx div 2 - 2 * 4, oy - 7, 40, '-' + zfill(level, 2) + '-');
  put_text(ox + 1 + wx - 4 * 6, oy - 7, 44, zfill(score, 6));
end;

procedure die(soft: boolean); { soft means display end screen }
begin
  if soft then game_state := 1
  else game_state := 2;
end;

procedure handle_keys;
begin
  if keys[KEY_ESC] then die(False);
  if keys[KEY_UP] and (snake.dir <> 2) then snake.dir := 0;
  if keys[KEY_RIGHT] and (snake.dir <> 3) then snake.dir := 1;
  if keys[KEY_DOWN] and (snake.dir <> 0) then snake.dir := 2;
  if keys[KEY_LEFT] and (snake.dir <> 1) then snake.dir := 3;
end;

procedure pop_tail;
begin
  snake.t_end := (snake.t_end + 1) mod MAP_SIZE;
end;

procedure push_tail(value: word);
begin
  snake.t_start := (snake.t_start + 1) mod MAP_SIZE;
  snake.tails[snake.t_start] := value;
end;


procedure generate_cherry;
var x, y: word;
begin
  while True do
  begin
    x := random(WIDTH);
    y := random(HEIGHT);
    if map.tiles[y*WIDTH+x] = ' ' then break;
  end;
  map.tiles[y*WIDTH+x] := 'c';
end;

procedure loop;
var h, m, s, ss, last_ss: word; tile: char;
begin
  while game_state <> 2 do
  begin
    check_keys;
    handle_keys;

    GetTime(h, m, s, ss);
    if (game_state = 0) and (100 * s + ss - last_ss > 30) then
    begin
      last_ss := 100 * s + ss;
      if snake.dir = 1 then snake.sx := snake.sx + 1;
      if snake.dir = 3 then snake.sx := snake.sx - 1;
      if snake.dir = 0 then snake.sy := snake.sy - 1;
      if snake.dir = 2 then snake.sy := snake.sy + 1;

      if ((snake.sx < 0) or (snake.sx >= WIDTH) or (snake.sy < 0) or (snake.sy >= HEIGHT)) and (not map.torus) then
      begin
         die(True);
         break;
      end;
      snake.sx := (snake.sx + WIDTH) mod WIDTH;
      snake.sy := (snake.sy + HEIGHT) mod HEIGHT;

      tile := map.tiles[snake.sy * WIDTH  + snake.sx];
      if tile = 'c' then
      begin
        score := score + 100;
        map.tiles[snake.sy * WIDTH + snake.sx] := ' ';
        generate_cherry;
      end else pop_tail;

      if tile = 'x' then
      begin
        die(True);
        break;
      end;

      push_tail(snake.sy * WIDTH + snake.sx);
      score := score + 1;
      time := time + 1;
      draw_map;
    end;
  end;
end;


begin
  init_font; init_13h; randomize;
  set_keyboard(True);

  generate_map;

  loop;

  set_keyboard(False);
  exit_13h;
  writeln('Thank You for playing turbo-snake!');
end.