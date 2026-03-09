package odtui

text_overflow :: proc() {
    w: Buffer
    buffer_make(&w, 12, 12, 1, 1)
    defer buffer_delete(&w)
    buffer_fill(&w, {'b', .Bold, .Black, .White})

    buffer_write_line(&w, "potato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntastypotato\nsalad\nis\ntasty", .None, .None, .None, 8)
    buffer_write_line_wrapping(&w, "potato salad is very tasty\npotato salad is very tasty\n", .None, .None, .None, 2)
}

blit_behavour :: proc() {
    w1: Buffer
    buffer_make(&w1, 12, 12, 6, 6)
    defer buffer_delete(&w1)
    buffer_fill(&w1, {'a', .Bold, .Red, .White})

    w2: Buffer
    buffer_make(&w2, 12, 12, 1, 1)
    defer buffer_delete(&w2)
    buffer_fill(&w2, {'b', .Bold, .Black, .White})

    buffer_blit(w1, w2)
    buffer_render(&w2)

    cursor_move(0, 18)
}
