#+feature dynamic-literals
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

// TODO: Figure out how to do it more efficiently.
// All the box characters are one afret another starting at 0x2500 ending at 0x257f.
// This allows us to make a list out of this hashmap.
// Unfotunetly the conversion from `Lines` to boh char is more complicated.
// The same tactic would require a massive sparse LUT, which would be borderline inefficient.
// So that is a quest for me in the future.
// Ideas: Could `Line` be efficiently hashed or transformed to through some mapping that creates less sparse LUT?
//        Could there be a representation of a line that maps better while retaining the same properties as the current one?

// One side = 4 bits (0 none, 1 light, 2 heavy, 3 double).
//        modifier = (0 none, 1 dotted, 2 dashed, 3 rounded)
Lines :: bit_field u16 {
    n: u8 | 2,
    e: u8 | 2,
    s: u8 | 2,
    w: u8 | 2,
    m: u8 | 2,
}

line_decode_map: map[rune]u16 = {
    '─' = cast(u16)Lines{n=0,e=1,s=0,w=1,m=0}, '━' = cast(u16)Lines{n=0,e=2,s=0,w=2,m=0}, '│' = cast(u16)Lines{n=1,e=0,s=1,w=0,m=0}, '┃' = cast(u16)Lines{n=2,e=0,s=2,w=0,m=0},
    // dashed variants collapse onto plain light/heavy (dash style not tracked)
    '┄' = cast(u16)Lines{n=0,e=1,s=0,w=1,m=1}, '┅' = cast(u16)Lines{n=0,e=2,s=0,w=2,m=1}, '┆' = cast(u16)Lines{n=1,e=0,s=1,w=0,m=1}, '┇' = cast(u16)Lines{n=2,e=0,s=2,w=0,m=1},
    '┈' = cast(u16)Lines{n=0,e=1,s=0,w=1,m=1}, '┉' = cast(u16)Lines{n=0,e=2,s=0,w=2,m=1}, '┊' = cast(u16)Lines{n=1,e=0,s=1,w=0,m=1}, '┋' = cast(u16)Lines{n=2,e=0,s=2,w=0,m=1},

    '┌' = cast(u16)Lines{n=0,e=1,s=1,w=0,m=0}, '┍' = cast(u16)Lines{n=0,e=2,s=1,w=0,m=0}, '┎' = cast(u16)Lines{n=0,e=1,s=2,w=0,m=0}, '┏' = cast(u16)Lines{n=0,e=2,s=2,w=0,m=0},
    '┐' = cast(u16)Lines{n=0,e=0,s=1,w=1,m=0}, '┑' = cast(u16)Lines{n=0,e=0,s=1,w=2,m=0}, '┒' = cast(u16)Lines{n=0,e=0,s=2,w=1,m=0}, '┓' = cast(u16)Lines{n=0,e=0,s=2,w=2,m=0},
    '└' = cast(u16)Lines{n=1,e=1,s=0,w=0,m=0}, '┕' = cast(u16)Lines{n=1,e=2,s=0,w=0,m=0}, '┖' = cast(u16)Lines{n=2,e=1,s=0,w=0,m=0}, '┗' = cast(u16)Lines{n=2,e=2,s=0,w=0,m=0},
    '┘' = cast(u16)Lines{n=1,e=0,s=0,w=1,m=0}, '┙' = cast(u16)Lines{n=1,e=0,s=0,w=2,m=0}, '┚' = cast(u16)Lines{n=2,e=0,s=0,w=1,m=0}, '┛' = cast(u16)Lines{n=2,e=0,s=0,w=2,m=0},

    '├' = cast(u16)Lines{n=1,e=1,s=1,w=0,m=0}, '┝' = cast(u16)Lines{n=1,e=2,s=1,w=0,m=0}, '┞' = cast(u16)Lines{n=2,e=1,s=1,w=0,m=0}, '┟' = cast(u16)Lines{n=1,e=1,s=2,w=0,m=0},
    '┠' = cast(u16)Lines{n=2,e=1,s=2,w=0,m=0}, '┡' = cast(u16)Lines{n=2,e=2,s=1,w=0,m=0}, '┢' = cast(u16)Lines{n=1,e=2,s=2,w=0,m=0}, '┣' = cast(u16)Lines{n=2,e=2,s=2,w=0,m=0},
    '┤' = cast(u16)Lines{n=1,e=0,s=1,w=1,m=0}, '┥' = cast(u16)Lines{n=1,e=0,s=1,w=2,m=0}, '┦' = cast(u16)Lines{n=2,e=0,s=1,w=1,m=0}, '┧' = cast(u16)Lines{n=1,e=0,s=2,w=1,m=0},
    '┨' = cast(u16)Lines{n=2,e=0,s=2,w=1,m=0}, '┩' = cast(u16)Lines{n=2,e=0,s=1,w=2,m=0}, '┪' = cast(u16)Lines{n=1,e=0,s=2,w=2,m=0}, '┫' = cast(u16)Lines{n=2,e=0,s=2,w=2,m=0},
    '┬' = cast(u16)Lines{n=0,e=1,s=1,w=1,m=0}, '┭' = cast(u16)Lines{n=0,e=1,s=1,w=2,m=0}, '┮' = cast(u16)Lines{n=0,e=2,s=1,w=1,m=0}, '┯' = cast(u16)Lines{n=0,e=2,s=1,w=2,m=0},
    '┰' = cast(u16)Lines{n=0,e=1,s=2,w=1,m=0}, '┱' = cast(u16)Lines{n=0,e=1,s=2,w=2,m=0}, '┲' = cast(u16)Lines{n=0,e=2,s=2,w=1,m=0}, '┳' = cast(u16)Lines{n=0,e=2,s=2,w=2,m=0},
    '┴' = cast(u16)Lines{n=1,e=1,s=0,w=1,m=0}, '┵' = cast(u16)Lines{n=1,e=1,s=0,w=2,m=0}, '┶' = cast(u16)Lines{n=1,e=2,s=0,w=1,m=0}, '┷' = cast(u16)Lines{n=1,e=2,s=0,w=2,m=0},
    '┸' = cast(u16)Lines{n=2,e=1,s=0,w=1,m=0}, '┹' = cast(u16)Lines{n=2,e=1,s=0,w=2,m=0}, '┺' = cast(u16)Lines{n=2,e=2,s=0,w=1,m=0}, '┻' = cast(u16)Lines{n=2,e=2,s=0,w=2,m=0},

    '┼' = cast(u16)Lines{n=1,e=1,s=1,w=1,m=0}, '┽' = cast(u16)Lines{n=1,e=1,s=1,w=2,m=0}, '┾' = cast(u16)Lines{n=1,e=2,s=1,w=1,m=0}, '┿' = cast(u16)Lines{n=1,e=2,s=1,w=2,m=0},
    '╀' = cast(u16)Lines{n=2,e=1,s=1,w=1,m=0}, '╁' = cast(u16)Lines{n=1,e=1,s=2,w=1,m=0}, '╂' = cast(u16)Lines{n=2,e=1,s=2,w=1,m=0}, '╃' = cast(u16)Lines{n=2,e=1,s=1,w=2,m=0},
    '╄' = cast(u16)Lines{n=2,e=2,s=1,w=1,m=0}, '╅' = cast(u16)Lines{n=1,e=1,s=2,w=2,m=0}, '╆' = cast(u16)Lines{n=1,e=2,s=2,w=1,m=0}, '╇' = cast(u16)Lines{n=2,e=2,s=1,w=2,m=0},
    '╈' = cast(u16)Lines{n=1,e=2,s=2,w=2,m=0}, '╉' = cast(u16)Lines{n=2,e=1,s=2,w=2,m=0}, '╊' = cast(u16)Lines{n=2,e=2,s=2,w=1,m=0}, '╋' = cast(u16)Lines{n=2,e=2,s=2,w=2,m=0},

    '╌' = cast(u16)Lines{n=0,e=1,s=0,w=1,m=2}, '╍' = cast(u16)Lines{n=0,e=2,s=0,w=2,m=2}, '╎' = cast(u16)Lines{n=1,e=0,s=1,w=0,m=2}, '╏' = cast(u16)Lines{n=2,e=0,s=2,w=0,m=2},

    '═' = cast(u16)Lines{n=0,e=3,s=0,w=3,m=0}, '║' = cast(u16)Lines{n=3,e=0,s=3,w=0,m=0},
    '╒' = cast(u16)Lines{n=0,e=3,s=1,w=0,m=0}, '╓' = cast(u16)Lines{n=0,e=1,s=3,w=0,m=0}, '╔' = cast(u16)Lines{n=0,e=3,s=3,w=0,m=0},
    '╕' = cast(u16)Lines{n=0,e=0,s=1,w=3,m=0}, '╖' = cast(u16)Lines{n=0,e=0,s=3,w=1,m=0}, '╗' = cast(u16)Lines{n=0,e=0,s=3,w=3,m=0},
    '╘' = cast(u16)Lines{n=1,e=3,s=0,w=0,m=0}, '╙' = cast(u16)Lines{n=3,e=1,s=0,w=0,m=0}, '╚' = cast(u16)Lines{n=3,e=3,s=0,w=0,m=0},
    '╛' = cast(u16)Lines{n=1,e=0,s=0,w=3,m=0}, '╜' = cast(u16)Lines{n=3,e=0,s=0,w=1,m=0}, '╝' = cast(u16)Lines{n=3,e=0,s=0,w=3,m=0},
    '╞' = cast(u16)Lines{n=1,e=3,s=1,w=0,m=0}, '╟' = cast(u16)Lines{n=3,e=1,s=3,w=0,m=0}, '╠' = cast(u16)Lines{n=3,e=3,s=3,w=0,m=0},
    '╡' = cast(u16)Lines{n=1,e=0,s=1,w=3,m=0}, '╢' = cast(u16)Lines{n=3,e=0,s=3,w=1,m=0}, '╣' = cast(u16)Lines{n=3,e=0,s=3,w=3,m=0},
    '╤' = cast(u16)Lines{n=0,e=3,s=1,w=3,m=0}, '╥' = cast(u16)Lines{n=0,e=1,s=3,w=1,m=0}, '╦' = cast(u16)Lines{n=0,e=3,s=3,w=3,m=0},
    '╧' = cast(u16)Lines{n=1,e=3,s=0,w=3,m=0}, '╨' = cast(u16)Lines{n=3,e=1,s=0,w=1,m=0}, '╩' = cast(u16)Lines{n=3,e=3,s=0,w=3,m=0},
    '╪' = cast(u16)Lines{n=1,e=3,s=1,w=3,m=0}, '╫' = cast(u16)Lines{n=3,e=1,s=3,w=1,m=0}, '╬' = cast(u16)Lines{n=3,e=3,s=3,w=3,m=0},

    // round corners count as plain light corners (roundness not tracked)
    '╭' = cast(u16)Lines{n=0,e=1,s=1,w=0,m=3}, '╮' = cast(u16)Lines{n=0,e=0,s=1,w=1,m=3}, '╯' = cast(u16)Lines{n=1,e=0,s=0,w=1,m=3}, '╰' = cast(u16)Lines{n=1,e=1,s=0,w=0,m=3},

    '╴' = cast(u16)Lines{n=0,e=0,s=0,w=1,m=0}, '╵' = cast(u16)Lines{n=1,e=0,s=0,w=0,m=0}, '╶' = cast(u16)Lines{n=0,e=1,s=0,w=0,m=0}, '╷' = cast(u16)Lines{n=0,e=0,s=1,w=0,m=0},
    '╸' = cast(u16)Lines{n=0,e=0,s=0,w=2,m=0}, '╹' = cast(u16)Lines{n=2,e=0,s=0,w=0,m=0}, '╺' = cast(u16)Lines{n=0,e=2,s=0,w=0,m=0}, '╻' = cast(u16)Lines{n=0,e=0,s=2,w=0,m=0},
    '╼' = cast(u16)Lines{n=0,e=2,s=0,w=1,m=0}, '╽' = cast(u16)Lines{n=1,e=0,s=2,w=0,m=0}, '╾' = cast(u16)Lines{n=0,e=1,s=0,w=2,m=0}, '╿' = cast(u16)Lines{n=2,e=0,s=1,w=0,m=0},   
}

line_encode_map: map[u16]rune = {
    cast(u16)Lines{n=0,e=1,s=0,w=1,m=0} = '─', cast(u16)Lines{n=0,e=2,s=0,w=2,m=0} = '━', cast(u16)Lines{n=1,e=0,s=1,w=0,m=0} = '│', cast(u16)Lines{n=2,e=0,s=2,w=0,m=0} = '┃',
    // dashed variants collapse onto plain light/heavy (dash style not tracked)
    cast(u16)Lines{n=0,e=1,s=0,w=1,m=1} = '┄', cast(u16)Lines{n=0,e=2,s=0,w=2,m=1} = '┅', cast(u16)Lines{n=1,e=0,s=1,w=0,m=1} = '┆', cast(u16)Lines{n=2,e=0,s=2,w=0,m=1} = '┇',
    cast(u16)Lines{n=0,e=1,s=0,w=1,m=1} = '┈', cast(u16)Lines{n=0,e=2,s=0,w=2,m=1} = '┉', cast(u16)Lines{n=1,e=0,s=1,w=0,m=1} = '┊', cast(u16)Lines{n=2,e=0,s=2,w=0,m=1} = '┋',

    cast(u16)Lines{n=0,e=1,s=1,w=0,m=0} = '┌', cast(u16)Lines{n=0,e=2,s=1,w=0,m=0} = '┍', cast(u16)Lines{n=0,e=1,s=2,w=0,m=0} = '┎', cast(u16)Lines{n=0,e=2,s=2,w=0,m=0} = '┏',
    cast(u16)Lines{n=0,e=0,s=1,w=1,m=0} = '┐', cast(u16)Lines{n=0,e=0,s=1,w=2,m=0} = '┑', cast(u16)Lines{n=0,e=0,s=2,w=1,m=0} = '┒', cast(u16)Lines{n=0,e=0,s=2,w=2,m=0} = '┓',
    cast(u16)Lines{n=1,e=1,s=0,w=0,m=0} = '└', cast(u16)Lines{n=1,e=2,s=0,w=0,m=0} = '┕', cast(u16)Lines{n=2,e=1,s=0,w=0,m=0} = '┖', cast(u16)Lines{n=2,e=2,s=0,w=0,m=0} = '┗',
    cast(u16)Lines{n=1,e=0,s=0,w=1,m=0} = '┘', cast(u16)Lines{n=1,e=0,s=0,w=2,m=0} = '┙', cast(u16)Lines{n=2,e=0,s=0,w=1,m=0} = '┚', cast(u16)Lines{n=2,e=0,s=0,w=2,m=0} = '┛',

    cast(u16)Lines{n=1,e=1,s=1,w=0,m=0} = '├', cast(u16)Lines{n=1,e=2,s=1,w=0,m=0} = '┝', cast(u16)Lines{n=2,e=1,s=1,w=0,m=0} = '┞', cast(u16)Lines{n=1,e=1,s=2,w=0,m=0} = '┟',
    cast(u16)Lines{n=2,e=1,s=2,w=0,m=0} = '┠', cast(u16)Lines{n=2,e=2,s=1,w=0,m=0} = '┡', cast(u16)Lines{n=1,e=2,s=2,w=0,m=0} = '┢', cast(u16)Lines{n=2,e=2,s=2,w=0,m=0} = '┣',
    cast(u16)Lines{n=1,e=0,s=1,w=1,m=0} = '┤', cast(u16)Lines{n=1,e=0,s=1,w=2,m=0} = '┥', cast(u16)Lines{n=2,e=0,s=1,w=1,m=0} = '┦', cast(u16)Lines{n=1,e=0,s=2,w=1,m=0} = '┧',
    cast(u16)Lines{n=2,e=0,s=2,w=1,m=0} = '┨', cast(u16)Lines{n=2,e=0,s=1,w=2,m=0} = '┩', cast(u16)Lines{n=1,e=0,s=2,w=2,m=0} = '┪', cast(u16)Lines{n=2,e=0,s=2,w=2,m=0} = '┫',
    cast(u16)Lines{n=0,e=1,s=1,w=1,m=0} = '┬', cast(u16)Lines{n=0,e=1,s=1,w=2,m=0} = '┭', cast(u16)Lines{n=0,e=2,s=1,w=1,m=0} = '┮', cast(u16)Lines{n=0,e=2,s=1,w=2,m=0} = '┯',
    cast(u16)Lines{n=0,e=1,s=2,w=1,m=0} = '┰', cast(u16)Lines{n=0,e=1,s=2,w=2,m=0} = '┱', cast(u16)Lines{n=0,e=2,s=2,w=1,m=0} = '┲', cast(u16)Lines{n=0,e=2,s=2,w=2,m=0} = '┳',
    cast(u16)Lines{n=1,e=1,s=0,w=1,m=0} = '┴', cast(u16)Lines{n=1,e=1,s=0,w=2,m=0} = '┵', cast(u16)Lines{n=1,e=2,s=0,w=1,m=0} = '┶', cast(u16)Lines{n=1,e=2,s=0,w=2,m=0} = '┷',
    cast(u16)Lines{n=2,e=1,s=0,w=1,m=0} = '┸', cast(u16)Lines{n=2,e=1,s=0,w=2,m=0} = '┹', cast(u16)Lines{n=2,e=2,s=0,w=1,m=0} = '┺', cast(u16)Lines{n=2,e=2,s=0,w=2,m=0} = '┻',

    cast(u16)Lines{n=1,e=1,s=1,w=1,m=0} = '┼', cast(u16)Lines{n=1,e=1,s=1,w=2,m=0} = '┽', cast(u16)Lines{n=1,e=2,s=1,w=1,m=0} = '┾', cast(u16)Lines{n=1,e=2,s=1,w=2,m=0} = '┿',
    cast(u16)Lines{n=2,e=1,s=1,w=1,m=0} = '╀', cast(u16)Lines{n=1,e=1,s=2,w=1,m=0} = '╁', cast(u16)Lines{n=2,e=1,s=2,w=1,m=0} = '╂', cast(u16)Lines{n=2,e=1,s=1,w=2,m=0} = '╃',
    cast(u16)Lines{n=2,e=2,s=1,w=1,m=0} = '╄', cast(u16)Lines{n=1,e=1,s=2,w=2,m=0} = '╅', cast(u16)Lines{n=1,e=2,s=2,w=1,m=0} = '╆', cast(u16)Lines{n=2,e=2,s=1,w=2,m=0} = '╇',
    cast(u16)Lines{n=1,e=2,s=2,w=2,m=0} = '╈', cast(u16)Lines{n=2,e=1,s=2,w=2,m=0} = '╉', cast(u16)Lines{n=2,e=2,s=2,w=1,m=0} = '╊', cast(u16)Lines{n=2,e=2,s=2,w=2,m=0} = '╋',

    cast(u16)Lines{n=0,e=1,s=0,w=1,m=2} = '╌', cast(u16)Lines{n=0,e=2,s=0,w=2,m=2} = '╍', cast(u16)Lines{n=1,e=0,s=1,w=0,m=2} = '╎', cast(u16)Lines{n=2,e=0,s=2,w=0,m=2} = '╏',

    cast(u16)Lines{n=0,e=3,s=0,w=3,m=0} = '═', cast(u16)Lines{n=3,e=0,s=3,w=0,m=0} = '║',
    cast(u16)Lines{n=0,e=3,s=1,w=0,m=0} = '╒', cast(u16)Lines{n=0,e=1,s=3,w=0,m=0} = '╓', cast(u16)Lines{n=0,e=3,s=3,w=0,m=0} = '╔',
    cast(u16)Lines{n=0,e=0,s=1,w=3,m=0} = '╕', cast(u16)Lines{n=0,e=0,s=3,w=1,m=0} = '╖', cast(u16)Lines{n=0,e=0,s=3,w=3,m=0} = '╗',
    cast(u16)Lines{n=1,e=3,s=0,w=0,m=0} = '╘', cast(u16)Lines{n=3,e=1,s=0,w=0,m=0} = '╙', cast(u16)Lines{n=3,e=3,s=0,w=0,m=0} = '╚',
    cast(u16)Lines{n=1,e=0,s=0,w=3,m=0} = '╛', cast(u16)Lines{n=3,e=0,s=0,w=1,m=0} = '╜', cast(u16)Lines{n=3,e=0,s=0,w=3,m=0} = '╝',
    cast(u16)Lines{n=1,e=3,s=1,w=0,m=0} = '╞', cast(u16)Lines{n=3,e=1,s=3,w=0,m=0} = '╟', cast(u16)Lines{n=3,e=3,s=3,w=0,m=0} = '╠',
    cast(u16)Lines{n=1,e=0,s=1,w=3,m=0} = '╡', cast(u16)Lines{n=3,e=0,s=3,w=1,m=0} = '╢', cast(u16)Lines{n=3,e=0,s=3,w=3,m=0} = '╣',
    cast(u16)Lines{n=0,e=3,s=1,w=3,m=0} = '╤', cast(u16)Lines{n=0,e=1,s=3,w=1,m=0} = '╥', cast(u16)Lines{n=0,e=3,s=3,w=3,m=0} = '╦',
    cast(u16)Lines{n=1,e=3,s=0,w=3,m=0} = '╧', cast(u16)Lines{n=3,e=1,s=0,w=1,m=0} = '╨', cast(u16)Lines{n=3,e=3,s=0,w=3,m=0} = '╩',
    cast(u16)Lines{n=1,e=3,s=1,w=3,m=0} = '╪', cast(u16)Lines{n=3,e=1,s=3,w=1,m=0} = '╫', cast(u16)Lines{n=3,e=3,s=3,w=3,m=0} = '╬',

    // round corners count as plain light corners (roundness not tracked)
    cast(u16)Lines{n=0,e=1,s=1,w=0,m=3} = '╭', cast(u16)Lines{n=0,e=0,s=1,w=1,m=3} = '╮', cast(u16)Lines{n=1,e=0,s=0,w=1,m=3} = '╯', cast(u16)Lines{n=1,e=1,s=0,w=0,m=3} = '╰',

    cast(u16)Lines{n=0,e=0,s=0,w=1,m=0} = '╴', cast(u16)Lines{n=1,e=0,s=0,w=0,m=0} = '╵', cast(u16)Lines{n=0,e=1,s=0,w=0,m=0} = '╶', cast(u16)Lines{n=0,e=0,s=1,w=0,m=0} = '╷',
    cast(u16)Lines{n=0,e=0,s=0,w=2,m=0} = '╸', cast(u16)Lines{n=2,e=0,s=0,w=0,m=0} = '╹', cast(u16)Lines{n=0,e=2,s=0,w=0,m=0} = '╺', cast(u16)Lines{n=0,e=0,s=2,w=0,m=0} = '╻',
    cast(u16)Lines{n=0,e=2,s=0,w=1,m=0} = '╼', cast(u16)Lines{n=1,e=0,s=2,w=0,m=0} = '╽', cast(u16)Lines{n=0,e=1,s=0,w=2,m=0} = '╾', cast(u16)Lines{n=2,e=0,s=1,w=0,m=0} = '╿',   
}

decode_line :: proc(r: rune) -> Lines {
    b, ok := line_decode_map[r]
    if !ok do return Lines{}
    return transmute(Lines)b
}

encode_line :: proc(l: Lines) -> rune {
    if r, ok := line_encode_map[transmute(u16)l]; ok do return r
    // no exact glyph (e.g. double clashing with heavy): demote and retry
    d := l
    if d.n == 3 do d.n = 1
    if d.e == 3 do d.e = 1
    if d.s == 3 do d.s = 1
    if d.w == 3 do d.w = 1
    if r, ok := line_encode_map[transmute(u16)d]; ok do return r
    if d.n == 2 do d.n = 1
    if d.e == 2 do d.e = 1
    if d.s == 2 do d.s = 1
    if d.w == 2 do d.w = 1
    if r, ok := line_encode_map[transmute(u16)d]; ok do return r
    return '+'
}

// merge two box-line runes at a junction: strongest side wins per direction
combine_lines :: proc(a, b: rune) -> rune {
    la := decode_line(a)
    lb := decode_line(b)
    if u8(la) == 0 do return encode_line(lb)
    if u8(lb) == 0 do return encode_line(la)
    out: Lines
    out.n = max(la.n, lb.n)
    out.e = max(la.e, lb.e)
    out.s = max(la.s, lb.s)
    out.w = max(la.w, lb.w)
    return encode_line(out)
}
