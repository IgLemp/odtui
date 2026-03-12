package odtui

import "core:log"



Window :: struct {
    backing: ^Buffer `fmt:"-"`,
    using sz:  struct {  w,  h: int }, // relative to backing buffer
    using pos: struct {  x,  y: int }, // <= backing buffer w, h
    using crs: struct { cx, cy: int }, // internal cursor
}



window_make :: proc(b: ^Buffer, window: ^Window, w: int = 0, h: int = 0, x: int = 0, y: int = 0) {
    window.backing = b
    window.x = x
    window.y = y
    window.w = w if w != 0 else window.backing.w
    window.h = h if h != 0 else window.backing.h

    when SAFEGUARDS {
        assert(w <= window.backing.w, "Window width cannot be bigger than tat if the backing buffer!")
        assert(h <= window.backing.h, "Window height cannot be bigger than tat if the backing buffer!")
    }
}




// WRITING PROCEDURES /////////////////////////////////////////////////////////////////////////////////////////////////
window_fill :: proc(w: ^Window, g: Graph) {
    for i in 0..<w.w*w.h {
        w.backing.buff[lin_to_buff(i, w.x, w.y, w.w, w.backing.w)] = g
    }
}

window_write_graph :: proc(w: ^Window, g: Graph, x, y: int) {
    if x > w.backing.w ||
       y > w.backing.w { return }

    w.backing.buff[lin_to_buff(0, w.x + x, w.y + y, w.w, w.backing.w)] = g
}

// Cursor independent //----------------------------------------------------------------------------------------------//
window_write_line_pos :: proc(w: ^Window, str: string, st: Style, bg, fg: Any_Color, x: int = 0, y: int = 0) {
    if x >= w.w || y >= w.h { return }
    y := y
    i_offs := 0

    for r, i in str {
        real_i := lin_to_buff(i - i_offs, w.x + x, w.y + y, w.w, w.backing.w)

        if real_i > w.backing.w * w.backing.h { return }
        if r == '\n' { y += 1; i_offs = i + 1; continue }
        if x + i - i_offs >= w.w { continue }

        if st != .None { w.backing.buff[real_i].st = st }
        if fg != .None { w.backing.buff[real_i].fg = fg }
        if bg != .None { w.backing.buff[real_i].bg = bg }
        w.backing.buff[real_i].r = r
    }
}

window_write_line_pos_wrapping :: proc(w: ^Window, str: string, st: Style, bg, fg: Any_Color, x: int = 0, y: int = 0) {
    if x >= w.w || y >= w.h { return }
    x, y := x, y
    i_offs := 0

    for r, i in str {
        real_i := lin_to_buff(
            i - i_offs + x,
            w.x,
            w.y + y,
            w.w,
            w.backing.w
        )

        if r == '\n' {
            y += i / w.w + 1
            i_offs += i + 1
            x = 0
            continue
        }
        if real_i > lin_to_buff(w.w*w.h, w.x, w.y, w.w, w.backing.w) { return }

        if st != .None { w.backing.buff[real_i].st = st }
        if fg != .None { w.backing.buff[real_i].fg = fg }
        if bg != .None { w.backing.buff[real_i].bg = bg }
        w.backing.buff[real_i].r = r
    }
}


// Cursor dependent --------------------------------------------------------------------------------------------------//
window_write_line :: proc(w: ^Window, str: string, st: Style, bg, fg: Any_Color) {
    i_str_offs := 0
    i_offs := 0
    i_end := 0

    for r, i in str {
        real_i := lin_to_buff(
            i - i_str_offs + w.cx,
            w.x,
            w.y + w.cy,
            w.w,
            w.backing.w
        )

        i_end = i

        if r == '\n' {
            w.cy += 1; w.cx = 0 // set cursor position
            i_str_offs = i + 1  // offset of runes in string
            i_offs = i          // offset of shown characters needed to set the cx position
            continue
        }

        if w.x + w.cx + i - i_str_offs > w.w { continue }
        if w.cy > w.h - 1 { break }

        if st != .None { w.backing.buff[real_i].st = st }
        if fg != .None { w.backing.buff[real_i].fg = fg }
        if bg != .None { w.backing.buff[real_i].bg = bg }
        w.backing.buff[real_i].r = r
    }

    w.cx = i_end - i_offs
}

window_write_line_wrapping :: proc(w: ^Window, str: string, st: Style, bg, fg: Any_Color) {
    i_str_offs := 0
    i_offs := 0
    i_end := 0

    for r, i in str {
        real_i := lin_to_buff(
            i - i_str_offs + w.cx,
            w.x,
            w.y + w.cy,
            w.w,
            w.backing.w
        )

        if real_i > lin_to_buff(w.w * w.h - 1, w.x, w.y, w.w, w.backing.w) { break }
        i_end = i

        if r == '\n' {
            w.cy += i / w.w + 1 // we are on the line that we ended the writing on
            w.cx  = 0
            i_str_offs = i + 1  // reset string position index to 0
            i_offs = i
            continue
        }

        if st != .None { w.backing.buff[real_i].st = st }
        if fg != .None { w.backing.buff[real_i].fg = fg }
        if bg != .None { w.backing.buff[real_i].bg = bg }
        w.backing.buff[real_i].r = r
    }

    w.cy += (i_end - i_offs + w.cx) / w.w
    w.cx  = (i_end - i_offs + w.cx) % w.w
}


