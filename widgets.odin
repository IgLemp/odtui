package odtui

import sym "symbols"
import "core:log"

// TODO: Make the procedures work on `Window` type and intended widget type like `Box`
//       All types should be binary compatible with `Window`, so box woul be just `Box :: Window`

// MAINTENANCE PROCEDURES //////////////////////////////////////////////////////////////////////////////////////////////

// Taked a potentially empty window and initialises it.
box_make :: proc(b: ^Buffer, win: ^Window, w: int = 0, h: int = 0, x: int = 0, y: int = 0) {
    win.backing = b

    win.x = x + 1 if x != -1 else x + 1
    win.y = y + 1 if y != -1 else y + 1
    win.w = w - 2 if w != -1 else b.w - 2 - x
    win.h = h - 2 if h != -1 else b.h - 2 - y

    if win.w < 0 { win.w = 0 }
    if win.h < 0 { win.h = 0 }
}


// WRITING PROCEDURES //////////////////////////////////////////////////////////////////////////////////////////////////

box_write_borders :: proc(w: ^Window, type: sym.Border_Set = sym.BORDER_PLAIN, style: Style = {.None, nil, nil}) {
    when SAFEGUARDS {
        assert(lin_to_buff(0, -1, -1, w.w + 2, w.backing.w) >= 0, "Box bounderies are outside the buffer!")
        // assert(lin_to_buff(0, w.w - 1, w.w - 1, w.w + 2, w.backing.w) <= 0, "Box bounderies are outside the buffer!")
    }

    // set horizontal
    for x in 0..<w.w {
        real_i_top := lin_to_buff(0, w.x + x, w.y - 1, w.w + 2, w.backing.w)
        if w.y > 0 && w.y <= w.backing.h {
            b := sym.combine_lines(w.backing.buff[real_i_top].r, type.horizontal_top)
            w.backing.buff[real_i_top] = {{b, style.st, style.fg, style.bg}, false}
        }

        real_i_bot := lin_to_buff(0, w.x + x, w.y + w.h, w.w + 2, w.backing.w)
        if w.y + w.h > 0 && w.y + w.h < w.backing.h {
            b := sym.combine_lines(w.backing.buff[real_i_bot].r, type.horizontal_bottom)
            w.backing.buff[real_i_bot] = {{b, style.st, style.fg, style.bg}, false}
        }
    }

    // set vertical
    for y in 0..<w.h {
        real_i_left := lin_to_buff(0, w.x - 1, w.y + y, w.w + 2, w.backing.w)
        if w.x > 0 && w.x < w.backing.w {
            b := sym.combine_lines(w.backing.buff[real_i_left].r, type.vertical_left)
            w.backing.buff[real_i_left] = {{b, style.st, style.fg, style.bg}, false}
        }

        real_i_right := lin_to_buff(0, w.x + w.w, w.y + y, w.w + 2, w.backing.w)
        if w.x + w.w > 0 && w.x + w.w < w.backing.w {
            b := sym.combine_lines(w.backing.buff[real_i_right].r, type.vertical_right)
            w.backing.buff[real_i_right] = {{b, style.st, style.fg, style.bg}, false}
        }
    }

    // set corners
    if w.y > 0 && w.y <= w.backing.h {
        if w.x > 0 && w.x < w.backing.w {
            b := sym.combine_lines(w.backing.buff[lin_to_buff(0, w.x - 1, w.y - 1, w.w + 2, w.backing.w)].r, type.top_left)
            /* left  up  */ w.backing.buff[lin_to_buff(0, w.x - 1,   w.y - 1,   w.w + 2, w.backing.w)] = {{b,  style.st, style.fg, style.bg}, false}
        }
        if w.x + w.w > 0 && w.x + w.w < w.backing.w {
            b := sym.combine_lines(w.backing.buff[lin_to_buff(0, w.x + w.w, w.y - 1, w.w + 2, w.backing.w)].r, type.top_right)
            /* right up  */ w.backing.buff[lin_to_buff(0, w.x + w.w, w.y - 1,   w.w + 2, w.backing.w)] = {{b, style.st, style.fg, style.bg}, false}
        }
    }

    if w.y + w.h > 0 && w.y + w.h < w.backing.h {
        if w.x > 0 && w.x <= w.backing.w {
            b := sym.combine_lines(w.backing.buff[lin_to_buff(0, w.x - 1,   w.y + w.h, w.w + 2, w.backing.w)].r, type.bottom_left)
            /* left  bot */ w.backing.buff[lin_to_buff(0, w.x - 1,   w.y + w.h, w.w + 2, w.backing.w)] = {{b,  style.st, style.fg, style.bg}, false}
        }
        if w.x + w.w > 0 && w.x + w.w < w.backing.w {
            b := sym.combine_lines(w.backing.buff[lin_to_buff(0, w.x + w.w, w.y + w.h, w.w + 2, w.backing.w)].r, type.bottom_right)
            /* right bot */ w.backing.buff[lin_to_buff(0, w.x + w.w, w.y + w.h, w.w + 2, w.backing.w)] = {{b, style.st, style.fg, style.bg}, false}
        }
    }
}


// OPERATIONS //////////////////////////////////////////////////////////////////////////////////////////////////////////

