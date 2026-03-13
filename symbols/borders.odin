package symbols

Border_Set :: struct {
    top_left: rune,
    top_right: rune,
    bottom_left: rune,
    bottom_right: rune,
    vertical_left: rune,
    vertical_right: rune,
    horizontal_top: rune,
    horizontal_bottom: rune,
}

BORDER_PLAIN :: Border_Set {
    top_left          = LINE_TOP_LEFT,
    top_right         = LINE_TOP_RIGHT,
    bottom_left       = LINE_BOTTOM_LEFT,
    bottom_right      = LINE_BOTTOM_RIGHT,
    vertical_left     = LINE_VERTICAL,
    vertical_right    = LINE_VERTICAL,
    horizontal_top    = LINE_HORIZONTAL,
    horizontal_bottom = LINE_HORIZONTAL,
}

BORDER_ROUNDED :: Border_Set {
    top_left          = LINE_ROUNDED_TOP_LEFT,
    top_right         = LINE_ROUNDED_TOP_RIGHT,
    bottom_left       = LINE_ROUNDED_BOTTOM_LEFT,
    bottom_right      = LINE_ROUNDED_BOTTOM_RIGHT,
    vertical_left     = LINE_VERTICAL,
    vertical_right    = LINE_VERTICAL,
    horizontal_top    = LINE_HORIZONTAL,
    horizontal_bottom = LINE_HORIZONTAL,
}

BORDER_DOUBLE :: Border_Set {
    top_left          = LINE_DOUBLE_TOP_LEFT,
    top_right         = LINE_DOUBLE_TOP_RIGHT,
    bottom_left       = LINE_DOUBLE_BOTTOM_LEFT,
    bottom_right      = LINE_DOUBLE_BOTTOM_RIGHT,
    vertical_left     = LINE_DOUBLE_VERTICAL,
    vertical_right    = LINE_DOUBLE_VERTICAL,
    horizontal_top    = LINE_DOUBLE_HORIZONTAL,
    horizontal_bottom = LINE_DOUBLE_HORIZONTAL,
}

BORDER_THICK :: Border_Set {
    top_left          = LINE_THICK_TOP_LEFT,
    top_right         = LINE_THICK_TOP_RIGHT,
    bottom_left       = LINE_THICK_BOTTOM_LEFT,
    bottom_right      = LINE_THICK_BOTTOM_RIGHT,
    vertical_left     = LINE_THICK_VERTICAL,
    vertical_right    = LINE_THICK_VERTICAL,
    horizontal_top    = LINE_THICK_HORIZONTAL,
    horizontal_bottom = LINE_THICK_HORIZONTAL,
}


