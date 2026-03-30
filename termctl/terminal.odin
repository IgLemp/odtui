package termctl

import "core:fmt"
import "core:os"
import "core:strings"
import "core:terminal/ansi"

@(private)
orig_termstate: Terminal_State

Term_Mode :: enum {
     Raw,
     Cbreak,
     Restored
}

Rect :: struct {
     using pos: struct { x, y: int },
     using sz:  struct { w, h: int },
}

Text_Style :: enum {
    None,
    Bold,
    Italic,
    Underline,
    Crossed,
    Inverted,
    Dim,
}

Color_8 :: enum {
    None,
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
}

Color_RGB :: [3]u8

Any_Color :: union {
    Color_8,
    Color_RGB,
}

Style :: struct {
    st: Text_Style,
    fg: Any_Color,
    bg: Any_Color,
}

Graph :: struct {
    r: rune,
    st: Text_Style,
    fg: Any_Color,
    bg: Any_Color,
}


set_term_mode :: proc(mode: Term_Mode) {
     change_terminal_mode(mode)

     #partial switch mode {
     case .Restored:
          disable_alt_buffer()
          disable_mouse()

     case .Raw:
          enable_alt_buffer()
          enable_mouse()
     }

     hide_cursor()

     // when changing modes some OSes (like windows) might put garbage that we don't care about
     // in stdin potentially causing nonblocking reads to block on the first read, so to avoid this,
     // stdin is always flushed when the mode is changed
     os.flush(os.stdin)
}


cursor_move :: proc(x, y: int) { fmt.printf(ansi.CSI + "%d;%dH", y, x + 1) }

hide_cursor        :: proc() { fmt.print(ansi.CSI + "?25l") }
show_cursor        :: proc() { fmt.print(ansi.CSI + "?25h") }
restore_screen     :: proc() { fmt.print(ansi.CSI + "?47l") }
save_screen        :: proc() { fmt.print(ansi.CSI + "?47h") }
enable_alt_buffer  :: proc() { fmt.print(ansi.CSI + "?1049h") }
disable_alt_buffer :: proc() { fmt.print(ansi.CSI + "?1049l") }
enable_mouse       :: proc() { fmt.print(ansi.CSI + "?1003h", ansi.CSI + "?1006h") }
disable_mouse      :: proc() { fmt.print(ansi.CSI + "?1003l", ansi.CSI + "?1006l") }

