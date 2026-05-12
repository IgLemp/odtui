package odtui

import "core:log"
import "core:io"

// TODO: Add `io.Writer` interface for ease of use,
//       mainly so we can use `fmt` package


Window :: struct {
    using pos: struct { x, y: int }, // <= backing buffer w, h
    using sz:  struct { w, h: int }, // relative to backing buffer
    backing: ^Buffer `fmt:"-"`,
    using crs: struct { cx, cy: int }, // internal cursor
}



// MAINTENANCE PROCEDURES //////////////////////////////////////////////////////////////////////////////////////////////
window_make :: proc(b: ^Buffer, window: ^Window, w: int = 0, h: int = 0, x: int = 0, y: int = 0) {
    window.backing = b
    window.x = x
    window.y = y
    window.w = w if w != -1 else window.backing.w - x
    window.h = h if h != -1 else window.backing.h - y

    when SAFEGUARDS {
        assert(w <= window.backing.w, "Window width cannot be bigger than that of the backing buffer!")
        assert(h <= window.backing.h, "Window height cannot be bigger than that of the backing buffer!")
    }
}



// WRITING PROCEDURES //////////////////////////////////////////////////////////////////////////////////////////////////
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
window_write_line_pos :: proc(w: ^Window, str: string, st: Style = {.None, nil, nil}, x: int = 0, y: int = 0) {
    if x >= w.w || y >= w.h { return }
    y := y
    col := 0

    for r, i in str {
        real_i := lin_to_buff(col, w.x + x, w.y + y, w.w, w.backing.w)

        if real_i > w.backing.w * w.backing.h { return }
        if r == '\r' { continue }
        if r == '\n' { y += 1; col = 0; continue }
        if x + col >= w.w { continue }

        w.backing.buff[real_i].st = st.st
        w.backing.buff[real_i].fg = st.fg
        w.backing.buff[real_i].bg = st.bg
        w.backing.buff[real_i].r = r

        col += 1
    }
}

// TODO: This has inconsistent behaviour with the function above
window_write_line_pos_wrapping :: proc(w: ^Window, str: string, st: Style = {.None, nil, nil}, x: int = 0, y: int = 0) {
    if x >= w.w || y >= w.h { return }
    x, y := x, y
    col := 0

    for r, i in str {
        if r == '\r' { continue }
        if r == '\n' {
            y += i / w.w + 1
            col = 0
            x = 0
            continue
        }

        real_i := lin_to_buff(col, w.x + x, w.y + y, w.w, w.backing.w)
        if real_i > lin_to_buff(w.w*w.h, w.x, w.y, w.w, w.backing.w) { return }

        w.backing.buff[real_i].st = st.st
        w.backing.buff[real_i].fg = st.fg
        w.backing.buff[real_i].bg = st.bg
        w.backing.buff[real_i].r = r

        col += 1
    }
}


// Cursor dependent ------------------------------------------------------------------------------------------------- //
window_write_line :: proc(w: ^Window, str: string, st: Style = {.None, nil, nil}) {
    col := 0

    for r in str {
        if r == '\r' { continue }
        if r == '\n' {
            w.cy += 1
            w.cx = 0
            col = 0
            continue
        }

        if w.x + w.cx + col > w.w { continue }
        if w.cy > w.h - 1 { break }

        real_i := lin_to_buff(col, w.x + w.cx, w.y + w.cy, w.w, w.backing.w)
        w.backing.buff[real_i].st = st.st
        w.backing.buff[real_i].fg = st.fg
        w.backing.buff[real_i].bg = st.bg
        w.backing.buff[real_i].r = r

        col += 1
    }

    w.cx += col
}

window_write_line_wrapping :: proc(w: ^Window, str: string, st: Style = {.None, nil, nil}) {
    col := 0

    for r, i in str {
        if r == '\r' { continue }
        if r == '\n' {
            w.cy += i / w.w + 1 // we are on the line that we ended the writing on
            w.cx  = 0
            col = 0
            continue
        }

        real_i := lin_to_buff(col, w.x + w.cx, w.y + w.cy, w.w, w.backing.w)
        if real_i > lin_to_buff(w.w * w.h - 1, w.x, w.y, w.w, w.backing.w) { break }

        w.backing.buff[real_i].st = st.st
        w.backing.buff[real_i].fg = st.fg
        w.backing.buff[real_i].bg = st.bg
        w.backing.buff[real_i].r = r

        col += 1
    }

    w.cy += (w.cx + col) / w.w
    w.cx  = (w.cx + col) % w.w
}


// ADAPTERS ///////////////////////////////////////////////////////////////////////////////////////////////////////////
// TODO: Make it work with UTF-8
// Currently works for ASCII, next implementation wold need to check if we're in the center of UTF-8 codepoint
// to correctly move the cursor. NOTICE: We can do that by checking the first 2 bits, refer to the page below:
// https://en.wikipedia.org/wiki/UTF-8#Description

// Non wrapping window stream proc
window_stream_proc :: proc(stream_data: rawptr, mode: io.Stream_Mode, p: []u8, offset: i64, whence: io.Seek_From) -> (n: i64, err: io.Error) {
    win := cast(^Window)stream_data
    _ = mode
    _ = p
    _ = offset
    _ = whence

    if mode != .Write { return 0, .Unsupported }
    window_write_line(win, string(p))
    return 0, nil
}

// Wrapping window stream proc
window_stream_proc_wrapping :: proc(stream_data: rawptr, mode: io.Stream_Mode, p: []u8, offset: i64, whence: io.Seek_From) -> (n: i64, err: io.Error) {
    win := cast(^Window)stream_data
    _ = mode
    _ = p
    _ = offset
    _ = whence

    if mode != .Write { return 0, .Unsupported }
    window_write_line_wrapping(win, string(p))
    return 0, nil
}

// Returns an `io.Writer`
window_to_writer :: proc(w: ^Window, wrapping: bool = false) -> io.Writer {
    return io.Writer { window_stream_proc_wrapping if wrapping else window_stream_proc, w }
}

