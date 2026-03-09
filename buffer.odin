package odtui

import "core:log"

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

Buffer :: struct {
    buff: []Graph,
    using sz:  struct { w, h: int },
    using pos: struct { x, y: int },
}


// WRITING PROCEDURES /////////////////////////////////////////////////////////////////////////////////////////////////
buffer_fill :: proc(buffer: ^Buffer, g: Graph) {
    for i in 0..<len(buffer.buff) { buffer.buff[i] = g }
}

// Renders everything
buffer_render :: proc(buffer: ^Buffer) {
    for i in 0..<len(buffer.buff) {
        if buffer.x + (i % buffer.w) < 0 { continue }
        if buffer.y + (i / buffer.w) < 0 { continue }
        // TODO: This is stupid, the cursor needs to move only at the end of the buffer
        cursor_move(buffer.x + (i % buffer.w), buffer.y + (i / buffer.w))
        print_graph(buffer.buff[i])
    }
}

buffer_write_graph :: proc(b: ^Buffer, g: Graph, x, y: int) {
    if x > b.w ||
       y > b.w { return }

    b.buff[lin_to_buff(0, x, y, b.w, b.w)] = g
}

buffer_write_line :: proc(b: ^Buffer, str: string, st: Style, bg, fg: Any_Color, x: int = 0, y: int = 0) {
    if x >= b.w || y >= b.h { return }
    y := y
    i_offs := 0

    for r, i in str {
        if lin_to_buff(i - i_offs, x, y, b.w, b.w) > b.w * b.h { return }
        if r == '\n' { y += 1; i_offs = i + 1; continue }
        if x + i - i_offs >= b.w { continue }
        b.buff[lin_to_buff(i - i_offs, x, y, b.w, b.w)] = {r, st, bg, fg}
    }
}

buffer_write_line_wrapping :: proc(b: ^Buffer, str: string, st: Style, bg, fg: Any_Color, x: int = 0, y: int = 0) {
    if x >= b.w || y >= b.h { return }
    x, y := x, y
    i_offs := 0

    for r, i in str {
        if lin_to_buff(i - i_offs, x, y, b.w, b.w) > b.w * b.h { return }
        // TODO: Fix this so the text overflows to proper x position.
        //       The new line behaviour is also not as expected.
        if r == '\n' { y += 1; i_offs = i + 1; continue }
        b.buff[lin_to_buff(i, x, y, b.w, b.w)] = {r, st, bg, fg}
    }
}


// Renders only changed regions
buffer_render_diff :: proc(src, dest: ^Buffer) {
    
}

// MAINTENANCE PROCEDURES /////////////////////////////////////////////////////////////////////////////////////////////
buffer_make :: proc(buffer: ^Buffer, w, h: int, x: int = 0, y: int = 0, buff: []Graph = nil) {
    buffer.w = w
    buffer.h = h

    buffer.x = x
    buffer.y = y

    if buff == nil {
        new_buff := make([]Graph, w * h)
        buffer.buff = new_buff
    } else {
        assert(cast(int)len(buff) >= w * h, "Buffer not too small!")
        buffer.buff = buff
    }
}


buffer_delete :: proc(buffer: ^Buffer) {
   delete(buffer.buff)
}


view_make :: proc(buffer: ^Buffer, view: ^Buffer) {
    view^ = buffer^
}

// OPERATIONS /////////////////////////////////////////////////////////////////////////////////////////////////////////
buffer_intersect :: proc(a, b: Buffer) -> (x, y, w, h: int) {
    x = max(a.x, b.x)
    y = max(a.y, b.y)

    w = min(a.x + a.w, b.x + b.w) - x
    h = min(a.y + a.h, b.y + b.h) - y

    return
}


abs_to_win :: #force_inline proc(xa, ya: int, x0, y0: int) -> (int, int)
    { return xa - x0, ya - y0 }

lin_to_buff :: #force_inline proc(i, x0, y0, new_w, buff_w: int) -> int {
    xp :=  x0 + (i % new_w)
    yp := (y0 + (i / new_w)) * buff_w
    return xp + yp
}


buffer_mask :: proc(src: ^Buffer, dest: ^Buffer, mask: ^Buffer) {
    x0, y0, w, h := buffer_intersect(src^, dest^)
    assert(w != 0 && h != 0, "buffers do not overlap!")
    assert(mask.w >= w && mask.h >= h, "Mask size too small!")

    for i in 0..=w*h {
        p_src  := lin_to_buff(i, x0, y0, w, src.w)
        p_dest := lin_to_buff(i, x0, y0, w, dest.w)
        p_mask := lin_to_buff(i, x0, y0, w, mask.w)

        s := src.buff[p_src]
        d := src.buff[p_dest]
        if s != d { mask.buff[p_mask].fg = s.fg }
    }
}


buffer_diff :: proc(src: ^Buffer, dest: ^Buffer, diff: ^Buffer) {
    x0, y0, w, h := buffer_intersect(src^, dest^)
    assert(cast(int)len(diff.buff) <= w*h, "Mask size too small!")

    diff.x = x0
    diff.y = y0
    
    for i in 0..=w*h {
        p_src  := lin_to_buff(i, x0, y0, w, src.w)
        p_dest := lin_to_buff(i, x0, y0, w, dest.w)

        s := src.buff[p_src]
        d := src.buff[p_dest]
        if s != d { diff.buff[i] = s }
    }

    return
}


buffer_blit :: proc(src: Buffer, dest: Buffer) {
    x0, y0, w, h := buffer_intersect(src, dest)

    if w <= 0 || h <= 0 { return }

    for i in 0..<w*h {
        p_src  := lin_to_buff(i, abs_to_win(x0, y0, src.x,  src.y),  w, src.w)
        p_dest := lin_to_buff(i, abs_to_win(x0, y0, dest.x, dest.y), w, dest.w)

        dest.buff[p_dest] = src.buff[p_src]
    }
}

