package odtui

import sym "symbols"
import "core:log"

// TODO: Consider making a seperate type that is binary compatible with Window
//         instead of passing weird malformed windows.

// MAINTENANCE PROCEDURES //////////////////////////////////////////////////////////////////////////////////////////////
box_make :: proc(b: ^Buffer, win: ^Window, w: int = 0, h: int = 0, x: int = 0, y: int = 0) {
    win.backing = b

    win.x = x + 1 if x != 0 else x + 1
    win.y = y + 1 if y != 0 else y + 1
    win.w = w - 2 if w != 0 else b.w - 2 - x
    win.h = h - 2 if h != 0 else b.h - 2 - y

    if win.w < 0 { win.w = 0 }
    if win.h < 0 { win.h = 0 }
}


// WRITING PROCEDURES //////////////////////////////////////////////////////////////////////////////////////////////////

box_write_borders :: proc(w: ^Window, type: sym.Border_Set, style: Style = {.None, .None, .None}) {
    when SAFEGUARDS {
        assert(lin_to_buff(0, -1, -1, w.w + 2, w.backing.w) >= 0, "Box bounderies are outside the buffer!")
        // assert(lin_to_buff(0, w.w - 1, w.w - 1, w.w + 2, w.backing.w) <= 0, "Box bounderies are outside the buffer!")
    }

    // set horizontal
    for x in 0..<w.w {
        real_i_top := lin_to_buff(0, w.x + x, w.y - 1, w.w + 2, w.backing.w)
        w.backing.buff[real_i_top] = { type.horizontal_top, style.st, style.fg, style.bg }

        real_i_bot := lin_to_buff(0, w.x + x, w.y + w.h, w.w + 2, w.backing.w)
        w.backing.buff[real_i_bot] = { type.horizontal_bottom, style.st, style.fg, style.bg }
    }

    // set vertical
    for y in 0..<w.h {
        real_i_top := lin_to_buff(0, w.x - 1, w.y + y, w.w + 2, w.backing.w)
        w.backing.buff[real_i_top] = { type.vertical_left, style.st, style.fg, style.bg }

        real_i_bot := lin_to_buff(0, w.x + w.w, w.y + y, w.w + 2, w.backing.w)
        w.backing.buff[real_i_bot] = { type.vertical_right, style.st, style.fg, style.bg }
    }

    // set corners
    /* left  up  */ w.backing.buff[lin_to_buff(0, w.x - 1,   w.y - 1,   w.w + 2, w.backing.w)] = { type.top_left,     style.st, style.fg, style.bg }
    /* right up  */ w.backing.buff[lin_to_buff(0, w.x + w.w, w.y - 1,   w.w + 2, w.backing.w)] = { type.top_right,    style.st, style.fg, style.bg }
    /* left  bot */ w.backing.buff[lin_to_buff(0, w.x - 1,   w.y + w.h, w.w + 2, w.backing.w)] = { type.bottom_left,  style.st, style.fg, style.bg }
    /* right bot */ w.backing.buff[lin_to_buff(0, w.x + w.w, w.y + w.h, w.w + 2, w.backing.w)] = { type.bottom_right, style.st, style.fg, style.bg }
}


// OPERATIONS //////////////////////////////////////////////////////////////////////////////////////////////////////////



