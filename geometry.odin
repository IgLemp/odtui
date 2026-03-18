package odtui

import "core:log"

Rect :: struct {
    using sz:  struct { w, h: int },
    using pos: struct { x, y: int },
}

Direction :: enum {
    Up, Down,
    Left, Right,
}

Padding :: [Direction]int
PADDING_ZERO :: Padding {.Left = 0, .Right = 0, .Down = 0, .Up = 0}
PADDING_ONE  :: Padding {.Left = 1, .Right = 1, .Down = 1, .Up = 1}
PADDING_BOX  :: PADDING_ONE

/// BASIC LAYOUT ///////////////////////////////////////////////////////////////////////////////////////////////////////
center_elem :: proc(win: rawptr, elem: rawptr) { }
align_left_elem :: proc(win: rawptr, elem: rawptr) { }
align_right_elem :: proc(win: rawptr, elem: rawptr) { }
align_top_elem :: proc(win: rawptr, elem: rawptr) { }
align_bottom_elem :: proc(win: rawptr, elem: rawptr) { }

// Splits ----------------------------------------------------------------------------------------------------------- //
split_horizontal :: proc(win: rawptr, elems: ..rawptr) {
    rect := cast(^Rect)win
    w, h := rect.w / len(elems), rect.h

    for e, i in elems {
        r := cast(^Rect)e
        r.x = i * w
        r.w = w

        r.h = h
    }
}


split_vertical :: proc(win: rawptr, elems: ..rawptr) {
    rect := cast(^Rect)win
    w, h := rect.w, rect.h / len(elems)

    for e, i in elems {
        r := cast(^Rect)e
        r.y = i * h
        r.h = h

        r.w = w
    }
}


// Padded ----------------------------------------------------------------------------------------------------------- //
// NOTICE: Everything is calculated relative to `win` position (which is relative),
//         which means that if you plug a `Buffer` here the function will *not work as expected*.
split_horizontal_padded :: proc(win: rawptr, padding: Padding, inner_padded: bool = true, elems: ..rawptr) {
    rect := cast(^Rect)win
    x := rect.x
    y := rect.y + padding[.Up]
    // win.w = n*(pad_l + w + pad_r) -> solving for w we get:
    w := (rect.w / len(elems)) - (padding[.Left] + padding[.Right])
    h := rect.h - padding[.Down] - padding[.Up]

    for e, i in elems {
        r := cast(^Rect)e

        if i == 0 { // First box
            r.x = x + padding[.Left]
            r.w = w
        } else {    // Other boxes
            r.x = x + padding[.Left] + i*(padding[.Left] + w + padding[.Right])
            r.w = w
        }
        
        r.y = y
        r.h = h
    }
}


split_vertical_padded :: proc(win: rawptr, padding: Padding, inner_padded: bool = true, elems: ..rawptr) {
    rect := cast(^Rect)win
    x := rect.x + padding[.Left]
    y := rect.y
    w := rect.w - padding[.Left] - padding[.Right]
    // win.h = n*(pad_u + h + pad_d) -> solving for h we get:
    h := (rect.h / len(elems)) - (padding[.Up] + padding[.Down])

    for e, i in elems {
        r := cast(^Rect)e

        if i == 0 { // First box
            r.y = y + padding[.Up]
            r.h = h
        } else {    // Other boxes
            r.y = y + padding[.Up] + i*(padding[.Up] + h + padding[.Down])
            r.h = h
        }
        
        r.x = x
        r.w = w
    }
}

