package odtui

import "core:log"
import "termctl"

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



// The most basic primitive that can be displayed.
// A foundation for other forms of displayable elements.
Buffer :: struct {
    using pos: struct { x, y: int },
    using sz:  struct { w, h: int },
    buff: []Graph `fmt:"-"`,
}


// WRITING PROCEDURES /////////////////////////////////////////////////////////////////////////////////////////////////

// Fills the buffer with a desired graph.
buffer_fill :: proc(buffer: ^Buffer, g: Graph) {
    for i in 0..<len(buffer.buff) { buffer.buff[i] = g }
}

// Renders everything to screen.
buffer_render :: proc(buffer: ^Buffer) {
    for i in 0..<len(buffer.buff) {
        if buffer.x + (i % buffer.w) < 0 { continue }
        if buffer.y + (i / buffer.w) < 0 { continue }

        // TODO: Save everything in string_builder and print everything at once
        if i % buffer.w == 0
            { termctl.cursor_move(buffer.x + (i % buffer.w), buffer.y + (i / buffer.w)) }

        print_graph(buffer.buff[i])
    }
}

// Renders only changed regions.
// NOTICE: Without a `temp` buffer this function will allocate using default allocator.
// and then deallocate a temporary buffer, wich may be an unwanted behaviour.
buffer_render_diff :: proc(src, dest: ^Buffer, temp: ^Buffer = nil) {
    temp_b: Buffer
    if temp == nil { buffer_make(&temp_b, dest.w, dest.h) }
    
    // TODO: Save everything in string_builder and print everything at once
    buffer_diff(src, dest, &temp_b)
    log.debug(temp_b)
    buffer_render(&temp_b)

    buffer_delete(&temp_b)
}

// Writes a single graph at x, y.
buffer_write_graph :: proc(b: ^Buffer, g: Graph, x, y: int) {
    if x > b.w ||
       y > b.w { return }

    b.buff[lin_to_buff(0, x, y, b.w, b.w)] = g
}

// Writes text to a buffer cutting the overflowing part that didn't fit.
// Newline character as expected, starts a new line.
buffer_write_line :: proc(b: ^Buffer, str: string, st: Text_Style, fg, bg: Any_Color, x: int = 0, y: int = 0) {
    if x >= b.w || y >= b.h { return }
    y := y
    i_offs := 0

    for r, i in str {
        if lin_to_buff(i - i_offs, x, y, b.w, b.w) > b.w * b.h { return }
        if r == '\n' { y += 1; i_offs = i + 1; continue }
        if x + i - i_offs >= b.w { continue }
        b.buff[lin_to_buff(i - i_offs, x, y, b.w, b.w)] = {r, st, fg, bg}
    }
}

// Writes text to a buffer wrapping the overflowing part to the next line.
// Newline character as expected, starts a new line.
buffer_write_line_wrapping :: proc(b: ^Buffer, str: string, st: Text_Style, fg, bg: Any_Color, x: int = 0, y: int = 0) {
    if x >= b.w || y >= b.h { return }
    x, y := x, y
    i_offs := 0

    for r, i in str {
        if lin_to_buff(i - i_offs, x, y, b.w, b.w) > b.w * b.h { return }
        if r == '\n' { y += 1; i_offs = i + 1; continue }
        b.buff[lin_to_buff(i, x, y, b.w, b.w)] = {r, st, fg, bg}
    }
}


// MAINTENANCE PROCEDURES /////////////////////////////////////////////////////////////////////////////////////////////

// Initializes a buffer with a backing graph array.
// Provided with no backing slice it will make its own with default allocator.
buffer_make :: proc(buffer: ^Buffer, w, h: int, x: int = 0, y: int = 0, buff: []Graph = nil) {
    buffer.w = w
    buffer.h = h

    buffer.x = x
    buffer.y = y

    if buff == nil {
        new_buff := make([]Graph, w * h)
        buffer.buff = new_buff
    } else {
        when SAFEGUARDS { assert(cast(int)len(buff) >= w * h, "Buffer not too small!") }
        buffer.buff = buff
    }
}


buffer_delete :: proc(buffer: ^Buffer) {
   delete(buffer.buff)
}


// OPERATIONS /////////////////////////////////////////////////////////////////////////////////////////////////////////

// Calculates intersection rectangle of two buffers
buffer_intersect :: proc(a, b: Buffer) -> (x, y, w, h: int) {
    x = max(a.x, b.x)
    y = max(a.y, b.y)

    w = min(a.x + a.w, b.x + b.w) - x
    h = min(a.y + a.h, b.y + b.h) - y

    return
}

// NOTICE: inline
// Calculates window coordinates from absolute coordinates
abs_to_win :: #force_inline proc(xa, ya: int, x0, y0: int) -> (int, int)
    { return xa - x0, ya - y0 }

// NOTICE: inline
// This function is the backbone of the entire library.
// Calculates an index of graph given the coordinates, window size, and original buffer size.
// Visualisation of the principle: https://www.desmos.com/calculator/b0vih6gtkn
// NOTICE: The mapping to new_w from buff_w is omitted in the visualization.
lin_to_buff :: #force_inline proc(i, x0, y0, new_w, buff_w: int) -> int {
    xp :=  x0 + (i % new_w)
    yp := (y0 + (i / new_w)) * buff_w
    return xp + yp
}

buff_to_lin :: #force_inline proc(i, x0, y0, buff_w: int) -> (int, int) {
    x := (i % buff_w) - x0
    y := (i / buff_w) - y0
    return x, y
}

// TODO: IMPLEMENT PROPER BEHAVIOUR!!!
// Writes the position, size and changed graphs of the changed region to `mask` buffer.
buffer_mask :: proc(src: ^Buffer, dest: ^Buffer, mask: ^Buffer) {
    x0, y0, w, h := buffer_intersect(src^, dest^)
    when SAFEGUARDS { assert(w != 0 && h != 0, "buffers do not overlap!") }
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


// IMPORTANT: Expects the dest and diff buffers to be the same size.
// Calculates diff od `src` and `dest` buffer, saving the result in `diff`.
buffer_diff :: proc(src: ^Buffer, dest: ^Buffer, diff: ^Buffer) {
    x0, y0, w, h := buffer_intersect(src^, dest^)
    assert(cast(int)len(diff.buff) <= w*h, "Mask size too small!")

    diff.x = x0
    diff.y = y0
    diff.w = w
    diff.h = h

    log.debug(buffer_intersect(src^, dest^))

    first_change: int = -1
    last_change:  int = -1

    for i in 0..<w*h {
        p_src  := lin_to_buff(i, x0, y0, w, src.w)
        p_dest := lin_to_buff(i, x0, y0, w, dest.w)

        s := src.buff[p_src]
        d := dest.buff[p_dest]
        if s != d {
            if first_change == -1 { first_change = i }
            last_change = i

            diff.buff[i] = s
        }
    }

    x_min, y_min := buff_to_lin(first_change, 0, 0, dest.w)
    x_max, y_max := buff_to_lin(last_change,  0, 0, dest.w)

    log.debug(buff_to_lin(first_change, 0, 0, dest.w))
    log.debug(buff_to_lin(last_change,  0, 0, dest.w))

    diff.pos = { x_min,         y_min }
    diff.sz  = { x_max - x_min, y_max - y_min }

    return
}

// Blits the `src` buffer onto the `dest` buffer.
buffer_blit :: proc(src: Buffer, dest: Buffer) {
    x0, y0, w, h := buffer_intersect(src, dest)

    if w <= 0 || h <= 0 { return }

    for i in 0..<w*h {
        p_src  := lin_to_buff(i, abs_to_win(x0, y0, src.x,  src.y),  w, src.w)
        p_dest := lin_to_buff(i, abs_to_win(x0, y0, dest.x, dest.y), w, dest.w)

        dest.buff[p_dest] = src.buff[p_src]
    }
}

