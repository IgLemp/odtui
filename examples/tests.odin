package examples

import "../symbols"
import "core:log"

import tctl "../termctl"
import t ".."

text_overflow :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 12, 12, 1, 1)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {' ', .Bold, .Black, .White})

    // t.buffer_write_line(&b, "potato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis", .None, .None, .None, 8)
    t.buffer_write_line_wrapping(&b, "potato salad is very tasty\npotato salad is very tasty\n", .None, .None, .None, 2)

    t.buffer_render(&b)
}

blit_behavour :: proc() {
    b1: t.Buffer
    t.buffer_make(&b1, 12, 12, 6, 6)
    defer t.buffer_delete(&b1)
    t.buffer_fill(&b1, {'a', .Bold, .Red, .White})

    b2: t.Buffer
    t.buffer_make(&b2, 12, 12, 1, 1)
    defer t.buffer_delete(&b2)
    t.buffer_fill(&b2, {'b', .Bold, .Black, .White})

    t.buffer_blit(b1, b2)
    t.buffer_render(&b2)

    tctl.cursor_move(0, 18)
}

window_behaviour_pos_wrap :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 8, 10, 2, 2)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: t.Window
    t.window_make(&b, &w, b.w - 2, b.h - 2, 1, 1)

    t.window_fill(&w, {' ', .None, .None, .None})
    t.window_write_line_pos_wrapping(&w, "potato salad is very tasty\nakjsdkhasdkhaskdh", x = 1)

    t.buffer_render(&b)
}

window_behaviour_pos :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 8, 10, 5, 5)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: t.Window
    t.window_make(&b, &w, b.w - 2, b.h - 2, 1, 1)

    t.window_fill(&w, {' ', .None, .None, .None})
    t.window_write_line_pos(&w, "potato\nsalad\nis very tasty\nakjsdkhasdkhaskdh", x = 1)

    t.buffer_render(&b)
}

window_behaviour_cursor_wrap :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 8, 8, 2, 2)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: t.Window
    t.window_make(&b, &w, b.w - 2, b.h - 2, 1, 1)

    t.window_fill(&w, {' ', .None, .None, .None})
    t.window_write_line_wrapping(&w, "far land\n")
    t.window_write_line_wrapping(&w, "123456789\n")
    t.window_write_line_wrapping(&w, "abc")
    t.window_write_line_wrapping(&w, "qwertyuiopasdfg")
    // t.window_write_line_wrapping(&w, "12345678901234567890")
    // t.window_write_line_wrapping(&w, "abcdef")

    t.buffer_render(&b)
}

window_behaviour_cursor :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 16, 9, 2, 1)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: t.Window
    t.window_make(&b, &w, b.w - 4, b.h - 5, 2, 2)
    t.window_fill(&w, {' ', .None, .None, .None})

    log.debug(w)

    t.window_write_line(&w, "potato salad")
    t.window_write_line(&w, "\nxyzwfg 12345\n")
    t.window_write_line(&w, "abcdef")

    t.buffer_render(&b)
}


box_behaviour_borders :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 16, 8, 2, 9)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {'.', .None, .None, .None})

    w: t.Window
    t.box_make(&b, &w, b.w - 2, b.h - 2, 1, 1)
    t.window_fill(&w, {' ', .None, .None, .Red})

    log.debug(w)

    t.box_write_borders(&w, symbols.BORDER_DOUBLE)

    t.window_write_line(&w, "potato salad")
    t.window_write_line(&w, "\nxyzwfg 12345")
    t.window_write_line(&w, "\nabcdef")

    t.buffer_render(&b)
}


split_test :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 9*6, 9, 0, 1)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {'.', .None, .None, .None})

    w1: t.Window; t.window_make(&b, &w1, 0, 0)
    w2: t.Window; t.window_make(&b, &w2, 0, 0)
    w3: t.Window; t.window_make(&b, &w3, 0, 0)

    t.split_horizontal(&b, &w1, &w2, &w3)
    t.window_fill(&w1, {' ', .None, .None, .Red})
    t.window_fill(&w2, {' ', .None, .None, .Blue})
    t.window_fill(&w3, {' ', .None, .None, .Yellow})

    t.window_write_line_wrapping(&w1, "potato salad is very tasty after a day or two")

    t.buffer_render(&b)
}


split_padded_test :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 14, 9, 0, 1)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {'.', .None, .None, .None})

    // Will shit itself if position doesnt allow for w > 0
    // Doesn't seem to addect the vertical split for some reason
    // TODO: investigate and write safeguards
    // m: Window; t.window_make(&b, &m, -1, -1, 6, 0)
    // m: Window; t.window_make(&b, &m, -1, -1, 2, 17)
    m: t.Window; t.window_make(&b, &m, -1, -1, 0, 0)
    w1: t.Window; t.window_make(&b, &w1, 0, 0)
    w2: t.Window; t.window_make(&b, &w2, 0, 0)
    w3: t.Window; t.window_make(&b, &w3, 0, 0)
    
    p: t.Padding = {.Left = 1, .Right = 1, .Down = 1, .Up = 1}
    t.split_horizontal_padded(&m, p, true, &w1, &w2, &w3)
    // split_vertical_padded(&m, p, true, &w1, &w2, &w3)

    // log.debug(m)
    // log.debug(w1)
    // log.debug(w2)
    // log.debug(w3)
    
    t.window_fill(&w1, {' ', .None, .None, .Red})
    t.window_fill(&w2, {' ', .None, .None, .Blue})
    t.window_fill(&w3, {' ', .None, .None, .Yellow})

    t.window_write_line_wrapping(&w1, "potato salad is very tasty after a day or two")

    t.buffer_render(&b)
}


alignment_test :: proc() {
    b: t.Buffer
    t.buffer_make(&b, 14, 9, 0, 1)
    defer t.buffer_delete(&b)
    t.buffer_fill(&b, {'.', .None, .None, .None})

    m: t.Window; t.window_make(&b, &m, -1, -1, 0, 0)

    w: t.Window; t.window_make(&b, &w, 6, 7)
    t.center_horizontal(&m, &w)
    t.center_vertical(&m, &w)
    // align_right_elem(&m, &w)
    t.window_fill(&w, {' ', .None, .None, .Blue})

    t.buffer_render(&b)
}

