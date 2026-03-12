package odtui

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
    window_write_line_pos_wrapping(&w, "potato salad is very tasty\nakjsdkhasdkhaskdh", .None, .None, .None, 1)

    buffer_render(&b)
}

window_behaviour_pos :: proc() {
    b: Buffer
    buffer_make(&b, 8, 10, 2, 2)
    defer buffer_delete(&b)
    buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: Window
    window_make(&b, &w, b.w - 2, b.h - 2, 1, 1)

    window_fill(&w, {' ', .None, .None, .None})
    window_write_line_pos(&w, "potato\nsalad\nis very tasty\nakjsdkhasdkhaskdh", .None, .None, .None, 1)

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
    window_write_line_wrapping(&w, "far land", .None, .None, .None)
    window_write_line_wrapping(&w, "1234567", .None, .None, .None)
    window_write_line_wrapping(&w, "abc", .None, .None, .None)
    // window_write_line_wrapping(&w, "12345678901234567890", .None, .None, .None)
    // window_write_line_wrapping(&w, "abcdef", .None, .None, .None)

    buffer_render(&b)
}

window_behaviour_cursor :: proc() {
    b: Buffer
    buffer_make(&b, 7, 4, 2, 2)
    defer buffer_delete(&b)
    buffer_fill(&b, {' ', .Bold, .Red, .White})

    w: Window
    window_make(&b, &w, b.w - 2, b.h - 2, 1, 1)
    window_fill(&w, {' ', .None, .None, .None})

    window_write_line(&w, "potato", .None, .None, .None)
    window_write_line(&w, "\nxyzwfg\n", .None, .None, .None)
    window_write_line(&w, "abcdef", .None, .None, .None)

    buffer_render(&b)
}

