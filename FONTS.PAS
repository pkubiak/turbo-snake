unit Fonts;

interface
type
  FontChar = string[16];
  Font = array[char] of FontChar;
  Aligment = (LEFT, CENTER, RIGHT);
const
  BoldFont: Font = (
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'xx', '',
    'kFFkFFk', 'xxDFxDD', 'tBmgBz', 'BFvFlCu', 'dd', 'oFrr', 'rrFo', 'fhchf',
    'eeFFee', '44', 'eeeeee', 'yy', 'qymgdb', 'FFrrFF', 'bFF', 'DDvvxx',
    'vvvvFF', 'ppiFFi', 'xxvvDD', 'FFvvDD', 'brznhd', 'FFvvFF', 'xxvvFF',
    'kk', 'AA', 'eoBr', 'kkkkkk', 'rBoe', 'bbvvhh', 'FFrDDvFF', 'FFffFF',
    'FFvvFo', 'FFrrrr', 'FFrrFo', 'FFvvvv', 'FFffff', 'FFrvDD', 'FFeeFF',
    'FF', 'yyrrFF', 'FFeoBr', 'FFqqqq', 'FFbFFbFF', 'FFgmFF', 'FFrrFF',
    'FFffhh', 'FFXXFF', 'FFfDFx', 'xxvvDD', 'bbFFbb', 'FFqqFF', 'hpyyph',
    'FFqFFqFF', 'rBooBr', 'dhCChd', 'rzDxtr', 'FFrr', 'bdgmyq', 'rrFF',
    'cddc', 'qqqqqq', 'cddb', 'CCssEE', 'EEssEE', 'EEssss', 'EEssFF',
    'EEAAww', 'eFFfff', 'UUQ6+E', 'FFccFF', 'DD', 'G99', 'FFeEEs', 'FF',
    'EEcEEcEE', 'EEccEE', 'EEssEE', '++ssEE', 'EEss++', 'EEcccc', 'wwwAAA',
    'cFFsss', 'EEqqEE', 'goyyog', 'EEqEEqEE', 'sEmEEs', 'ooOO++', 'sAEEws',
    'eFFrr', 'FF', 'rrFFe', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', ''
  );



var
  {* builtin fonts *}
  RegularFont: Font;
  SmallFont: Font;
  MonsterFont: Font;

  (* display text on screen *)
  procedure put_text(font: Font; x, y: word; color: byte; text: string);

  (* display text in box *)
  procedure put_text_box(font: Font; x, y, w, h: word; fg, bg: byte; text: string; align: Aligment);

  (* compute width of text in given font *)
  function text_width(font: Font; text: string): word;

implementation
uses Gfx;
  function _decode64(c: char): byte;
  var
    x: word;
  begin
    x := ord(c);
    if (ord('a') <= x) and (x <= ord('z')) then _decode64 := x - ord('a')
    else if (ord('A') <= x) and (x <= ord('Z')) then _decode64 := x - ord('A') + 26
    else if (ord('0') <= x) and (x <= ord('9')) then _decode64 := x - ord('0') + 52
    else if c = '+' then _decode64 := 62
    else _decode64 := 63;
  end;

  procedure put_text(font: Font; x, y: word; color: byte; text: string);
  var
    py, v, px, i, j, k: word;
    c: string;
  begin
    px := 0; py := 0;
    for i:=1 to byte(text[0]) do
      begin
        if text[i] = ' ' then px := px + 4
        else if (text[i] = '\') and (text[i+1] = 'n') then
        begin
          py := py + 7;
          i:=i+1;
          px := 0;
        end else
        begin
          c := font[text[i]];
          for j:=1 to byte(c[0]) do
            begin
              v := _decode64(c[j]);
              for k:=0 to 5 do
                  if (v and (1 shl k)) <> 0 then
                  begin
                    put_pixel(x+px+j, y+py+k, color);
                  end;
            end;
          px := px + byte(c[0]) + 2;
        end;
      end;
  end;

  procedure put_text_box(font: Font; x, y, w, h: word; fg, bg: byte; text: string; align: Aligment);
  begin
  end;

  function text_width(font: Font; text: string): word;
  begin
  end;

end.
