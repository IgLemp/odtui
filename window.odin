package odtui

Text_Style :: enum {
    None,
    Bold,
    Italic,
    Underline,
    Crossed,
    Inverted,
    Dim,
}

/*
Colors from the original 8-color palette.
These should be supported everywhere this library is supported.
*/
Color_8 :: enum {
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
}

/*
RGB color. This is should be supported by every modern terminal.
In case you need to support an older terminals, use `Color_8` instead
*/
Color_RGB :: [3]u8

Any_Color :: union {
    Color_8,
    Color_RGB,
}

Style :: enum u8 {
    None,
    Bold,
    Italic,
    Underline,
    Crossed,
    Inverted,
    Dim,
}

Graph :: struct {
    r: rune,
    st: Style,
    bg: Any_Color,
    fg: Any_Color,
}

Window :: struct {
    buff: []Graph,
    using pos: struct { x, y: int },
    using sz:  struct { w, h: int }
}


// WRITING PROCEDURES /////////////////////////////////////////////////////////////////////////////////////////////////
window_fill :: proc(window: ^Window, g: Graph) {
    for i in 0..<len(window.buff) { window.buff[i] = g }
}

// Renders everything
window_render :: proc(window: ^Window) {
    for i in 0..<len(window.buff) {
        // TODO: Handle negative position case
        cursor_move(window.x + (i % window.w), window.y + (i / window.w))
        print_graph(window.buff[i])
    }
}

// Renders only changed regions
window_render_diff :: proc(src, dest: ^Window) {
    
}

// MAINTENANCE PROCEDURES /////////////////////////////////////////////////////////////////////////////////////////////
window_make :: proc(window: ^Window, w, h: int, x: int = 0, y: int = 0, buff: []Graph = nil) {
    window.w = w
    window.h = h

    window.x = x
    window.y = y

    if buff == nil {
        new_buff := make([]Graph, w * h)
        window.buff = new_buff
    } else {
        assert(cast(int)len(buff) >= w * h, "Buffer not too small!")
        window.buff = buff
    }
}


window_delete :: proc(window: ^Window) {
   delete(window.buff)
}


// OPERATIONS /////////////////////////////////////////////////////////////////////////////////////////////////////////
window_intersect :: proc(a, b: Window) -> (x, y, w, h: int) {
    x = max(a.x, b.x)
    y = max(a.y, b.y)

    w = min(a.x + a.w, b.x + b.w)
    h = min(a.y + a.h, b.y + b.h)

    return
}


lin_to_buff :: #force_inline proc(i, x0, y0, w, orig_w: int) -> (xp, yp: int) {
    xp = x0 + (i % w)
    yp = y0 + (i / w) * orig_w
    return
}


window_mask :: proc(src: Window, dest: Window, mask: Window) {
    x0, y0, w, h := window_intersect(src, dest)
    assert(w != 0 && h != 0, "Windows do not overlap!")
    assert(mask.w >= w && mask.h >= h, "Mask size too small!")
    
    for i in 0..=w*h {
        src_x,  src_y  := lin_to_buff(i, x0, y0, w, src.w)
        dest_x, dest_y := lin_to_buff(i, x0, y0, w, dest.w)
        mask_x, mask_y := lin_to_buff(i, x0, y0, w, mask.w)

        p_src  := src_x  + src_y
        p_dest := dest_x + dest_y
        p_mask := mask_x + mask_y

        s := src.buff[p_src]
        d := src.buff[p_dest]
        if s != d {
            if s.r  != d.r  { mask.buff[p_mask].r  = s.r  }
            if s.st != d.st { mask.buff[p_mask].st = s.st }
            if s.bg != d.bg { mask.buff[p_mask].bg = s.bg }
            if s.fg != d.fg { mask.buff[p_mask].fg = s.fg }
        }
    }
}


window_diff :: proc(src: Window, dest: Window, diff: ^Window) -> (changes: int) {
    x0, y0, w, h := window_intersect(src, dest)
    assert(w != 0 && h != 0, "Windows do not overlap!")
    assert(cast(int)len(diff.buff) <= w*h, "Mask size too small!")

    diff.x = x0
    diff.y = y0
    
    for i in 0..=w*h {
        src_x,  src_y  := lin_to_buff(i, x0, y0, w, src.w)
        dest_x, dest_y := lin_to_buff(i, x0, y0, w, dest.w)

        p_src  := src_x  + src_y
        p_dest := dest_x + dest_y

        s := src.buff[p_src]
        d := src.buff[p_dest]
        if s != d {
            if s.r  != d.r  { diff.buff[i].r  = s.r  }
            if s.st != d.st { diff.buff[i].st = s.st }
            if s.bg != d.bg { diff.buff[i].bg = s.bg }
            if s.fg != d.fg { diff.buff[i].fg = s.fg }
            changes += 1
        }
    }

    return
}


window_blit :: proc(src: Window, dest: Window) {
    x0, y0, w, h := window_intersect(src, dest)

    for i in 0..=w*h {
        src_x,  src_y  := lin_to_buff(i, x0, y0, w, src.w)
        dest_x, dest_y := lin_to_buff(i, x0, y0, w, dest.w)

        p_src  := src_x  + src_y
        p_dest := dest_x + dest_y

        s := src.buff[p_src]
        d := src.buff[p_dest]
        if s != d {
            if s.r  != d.r  { dest.buff[i].r  = s.r  }
            if s.st != d.st { dest.buff[i].st = s.st }
            if s.bg != d.bg { dest.buff[i].bg = s.bg }
            if s.fg != d.fg { dest.buff[i].fg = s.fg }
        }
    }
}

