package odtui

import "symbols"
import "core:log"


text_overflow :: proc() {
    b: Buffer
    buffer_make(&b, 12, 12, 1, 1)
    defer buffer_delete(&b)
    buffer_fill(&b, {' ', .Bold, .Black, .White})

    // buffer_write_line(&b, "potato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis", .None, .None, .None, 8)
    buffer_write_line_wrapping(&b, "potato salad is very tasty\npotato salad is very tasty\n", .None, .None, .None, 2)

    buffer_render(&b)
}

blit_behavour :: proc() {
    b1: Buffer
    buffer_make(&b1, 12, 12, 6, 6)
    defer buffer_delete(&b1)
    buffer_fill(&b1, {'a', .Bold, .Red, .White})

    b2: Buffer
    buffer_make(&b2, 12, 12, 1, 1)
    defer buffer_delete(&b2)
    buffer_fill(&b2, {'b', .Bold, .Black, .White})

    buffer_blit(b1, b2)
    buffer_render(&b2)

    cursor_move(0, 18)
}

window_behaviour_pos_wrap :: proc() {
    b: Buffer
    buffer_make(&b, 8, 10, 2, 2)
    defer buffer_delete(&b)
    buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: Window
    window_make(&b, &w, b.w - 2, b.h - 2, 1, 1)

    window_fill(&w, {' ', .None, .None, .None})
    window_write_line_pos_wrapping(&w, "potato salad is very tasty\nakjsdkhasdkhaskdh", x = 1)

    buffer_render(&b)
}

window_behaviour_pos :: proc() {
    b: Buffer
    buffer_make(&b, 8, 10, 5, 5)
    defer buffer_delete(&b)
    buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: Window
    window_make(&b, &w, b.w - 2, b.h - 2, 1, 1)

    window_fill(&w, {' ', .None, .None, .None})
    window_write_line_pos(&w, "potato\nsalad\nis very tasty\nakjsdkhasdkhaskdh", x = 1)

    buffer_render(&b)
}

window_behaviour_cursor_wrap :: proc() {
    b: Buffer
    buffer_make(&b, 8, 8, 2, 2)
    defer buffer_delete(&b)
    buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: Window
    window_make(&b, &w, b.w - 2, b.h - 2, 1, 1)

    window_fill(&w, {' ', .None, .None, .None})
    window_write_line_wrapping(&w, "far land\n")
    window_write_line_wrapping(&w, "123456789\n")
    window_write_line_wrapping(&w, "abc")
    window_write_line_wrapping(&w, "qwertyuiopasdfg")
    // window_write_line_wrapping(&w, "12345678901234567890")
    // window_write_line_wrapping(&w, "abcdef")

    buffer_render(&b)
}

window_behaviour_cursor :: proc() {
    b: Buffer
    buffer_make(&b, 16, 9, 2, 1)
    defer buffer_delete(&b)
    buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: Window
    window_make(&b, &w, b.w - 4, b.h - 5, 2, 2)
    window_fill(&w, {' ', .None, .None, .None})

    log.debug(w)

    window_write_line(&w, "potato salad")
    window_write_line(&w, "\nxyzwfg 12345\n")
    window_write_line(&w, "abcdef")

    buffer_render(&b)
}


box_behaviour_borders :: proc() {
    b: Buffer
    buffer_make(&b, 16, 8, 2, 9)
    defer buffer_delete(&b)
    buffer_fill(&b, {'.', .None, .None, .None})

    w: Window
    box_make(&b, &w, b.w - 2, b.h - 2, 1, 1)
    window_fill(&w, {' ', .None, .None, .Red})

    log.debug(w)

    box_write_borders(&w, symbols.BORDER_DOUBLE)

    window_write_line(&w, "potato salad")
    window_write_line(&w, "\nxyzwfg 12345")
    window_write_line(&w, "\nabcdef")

    buffer_render(&b)
}


split_test :: proc() {
    b: Buffer
    buffer_make(&b, 9*6, 9, 0, 1)
    defer buffer_delete(&b)
    buffer_fill(&b, {'.', .None, .None, .None})

    w1: Window; window_make(&b, &w1, 0, 0)
    w2: Window; window_make(&b, &w2, 0, 0)
    w3: Window; window_make(&b, &w3, 0, 0)

    split_horizontal(&b, &w1, &w2, &w3)
    window_fill(&w1, {' ', .None, .None, .Red})
    window_fill(&w2, {' ', .None, .None, .Blue})
    window_fill(&w3, {' ', .None, .None, .Yellow})

    window_write_line_wrapping(&w1, "potato salad is very tasty after a day or two")

    buffer_render(&b)
}


split_padded_test :: proc() {
    b: Buffer
    buffer_make(&b, 14, 9, 0, 1)
    defer buffer_delete(&b)
    buffer_fill(&b, {'.', .None, .None, .None})

    // Will shit itself if position doesnt allow for w > 0
    // Doesn't seem to addect the vertical split for some reason
    // TODO: investigate and write safeguards
    // m: Window; window_make(&b, &m, -1, -1, 6, 0)
    // m: Window; window_make(&b, &m, -1, -1, 2, 17)
    m: Window; window_make(&b, &m, -1, -1, 0, 0)
    w1: Window; window_make(&b, &w1, 0, 0)
    w2: Window; window_make(&b, &w2, 0, 0)
    w3: Window; window_make(&b, &w3, 0, 0)
    
    p: Padding = {.Left = 1, .Right = 1, .Down = 1, .Up = 1}
    split_horizontal_padded(&m, p, true, &w1, &w2, &w3)
    // split_vertical_padded(&m, p, true, &w1, &w2, &w3)

    // log.debug(m)
    // log.debug(w1)
    // log.debug(w2)
    // log.debug(w3)
    
    window_fill(&w1, {' ', .None, .None, .Red})
    window_fill(&w2, {' ', .None, .None, .Blue})
    window_fill(&w3, {' ', .None, .None, .Yellow})

    window_write_line_wrapping(&w1, "potato salad is very tasty after a day or two")

    buffer_render(&b)
}



