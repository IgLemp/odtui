package symbols

Scrollbar_Set :: struct {
    track: rune,
    thumb: rune,
    begin: rune,
    end: rune,
}

SCROLL_DOUBLE_VERTICAL :: Scrollbar_Set {
    track = LINE_DOUBLE_VERTICAL,
    thumb = BLOCK_FULL,
    begin = '▲',
    end   = '▼',
};

SCROLL_DOUBLE_HORIZONTAL :: Scrollbar_Set {
    track = LINE_DOUBLE_HORIZONTAL,
    thumb = BLOCK_FULL,
    begin = '◄',
    end   = '►',
};

SCROLL_VERTICAL :: Scrollbar_Set {
    track = LINE_VERTICAL,
    thumb = BLOCK_FULL,
    begin = '↑',
    end   = '↓',
};

SCROLL_HORIZONTAL :: Scrollbar_Set {
    track = LINE_HORIZONTAL,
    thumb = BLOCK_FULL,
    begin = '←',
    end   = '→',
};
