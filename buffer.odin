package odtui

import "core:log"
import str "core:strings"
import slc "core:slice"
import ctl "termctl"
import "core:os"


// The most basic primitive that can be displayed.
// A foundation for other forms of displayable elements.
Buffer :: struct {
    using pos: struct { x, y: int },
    using sz:  struct { w, h: int },
    buff: []Graph `fmt:"-"`,
}


// WRITING PROCEDURES /////////////////////////////////////////////////////////////////////////////////////////////////

// Fills the buffer with a desired graph.
buffer_fill :: #force_inline proc(buffer: ^Buffer, g: Graph) {
    slc.fill(buffer.buff, g)
}

// Zeroes the buffer.
buffer_zero :: #force_inline proc(buffer: ^Buffer) {
    slc.zero(buffer.buff)
}

// Renders everything to screen.
buffer_render :: proc(buffer: ^Buffer, sb: ^str.Builder) {
    if buffer.w == 0 || buffer.h == 0 { return }
    void: bool = false

    for g, i in buffer.buff[:] {
        if buffer.x + (i % buffer.w) < 0 { continue }
        if buffer.y + (i / buffer.w) < 0 { continue }

        // Nothing to print. Behaviour also needed for render_diff
        if g.r == rune(0) { void = true; continue }

        // Move cursor to next line
        if i % buffer.w == 0
            { move_cursor(sb, buffer.x + (i % buffer.w), buffer.y + (i / buffer.w)) }

        if void == true && g.r != rune(0)
            { move_cursor(sb, buffer.x + (i % buffer.w), buffer.y + (i / buffer.w)); void = false }

        // First rune
        if i == 0 {
            set_text_style(sb, { g.st })
            set_fg_color_style(sb, g.fg)
            set_bg_color_style(sb, g.bg)
            print_rune(sb, g.r);
            continue
        }

        if buffer.buff[i - 1].st != g.st
            { set_text_style(sb, { g.st }) }
        if buffer.buff[i - 1].fg != g.fg
            { set_fg_color_style(sb, g.fg) }
        if buffer.buff[i - 1].bg != g.bg
            { set_bg_color_style(sb, g.bg) }

        print_rune(sb, g.r)
    }

    os.write_strings(os.stdout, str.to_string(sb^))
    str.builder_reset(sb)
}

// Renders only changed regions.
// BUG: Still doesnt work and I don't know why.
buffer_render_diff :: proc(src, dest: ^Buffer, diff: ^Buffer, sb: ^str.Builder) {
    assert(diff != nil, "The diff buffer is nil!")

    buffer_zero(diff)
    retb := buffer_diff(src, dest, diff)
    // log.debug(retb)
    buffer_render(&retb, sb)
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
buffer_make :: proc(buffer: ^Buffer, w, h: int, x: int = 0, y: int = 0, backing: []Graph = nil) {
    buffer.w = w
    buffer.h = h

    buffer.x = x
    buffer.y = y

    if backing == nil {
        new_buff := make([]Graph, w * h)
        buffer.buff = new_buff
    } else {
        when SAFEGUARDS { assert(cast(int)len(backing) >= w * h, "Buffer not too small!") }
        buffer.buff = backing
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
        if s != d { mask.buff[p_mask] = s }
    }
}


// IMPORTANT: Expects the dest and diff buffers to be the same size.
// Calculates diff od `src` and `dest` buffer, saving the result in `diff`.
buffer_diff :: proc(src: ^Buffer, dest: ^Buffer, diff: ^Buffer) -> (retb: Buffer) {
    x0, y0, w, h := buffer_intersect(src^, dest^)
    assert(cast(int)len(diff.buff) >= w*h, "Mask size too small!")

    retb.x = x0
    retb.y = y0
    retb.w = w
    retb.h = h
    retb.buff = diff.buff

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

    if first_change == -1 {
        // Nothing was changed
        retb.pos = { 0, 0 }
        retb.sz  = { 0, 0 }
        return
    }

    retb.buff = diff.buff[first_change:last_change + 1]

    x_min, y_min := buff_to_lin(first_change, 0, 0, dest.w)
    x_max, y_max := buff_to_lin(last_change,  0, 0, dest.w)

    // TODO: I don't know or remember why it doesn't work without `+ 1`,
    //       so check why that is.
    retb.pos = { x_min,             y_min }
    retb.sz  = { x_max - x_min + 1, y_max - y_min + 1 }

    return
}

// Blits the `src` buffer onto the `dest` buffer.
buffer_blit :: proc(src: Buffer, dest: Buffer) {
    x0, y0, w, h := buffer_intersect(src, dest)

    if w <= 0 || h <= 0 { return }

    // TODO: This can by optimised by doing `memcpy` on every row
    for i in 0..<w*h {
        p_src  := lin_to_buff(i, abs_to_win(x0, y0, src.x,  src.y),  w, src.w)
        p_dest := lin_to_buff(i, abs_to_win(x0, y0, dest.x, dest.y), w, dest.w)

        dest.buff[p_dest] = src.buff[p_src]
    }
}

// Resizes the buffer. Requires everything to be rerendered after resize.
buffer_resize :: proc(buffer: ^Buffer, w, h: int, backing: []Graph = nil) {
    buffer_delete(buffer)
    buffer_make(buffer, w, h, buffer.x, buffer.y, backing)
}

