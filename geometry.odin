package odtui

import "core:log"

Direction :: enum {
    Up, Down,
    Left, Right,
}

Padding :: [Direction]int
PADDING_ZERO :: Padding {.Left = 0, .Right = 0, .Down = 0, .Up = 0}
PADDING_ONE  :: Padding {.Left = 1, .Right = 1, .Down = 1, .Up = 1}
PADDING_BOX  :: PADDING_ONE

/// BASIC LAYOUT ///////////////////////////////////////////////////////////////////////////////////////////////////////
center_horizontal :: proc(win: rawptr, elem: rawptr) {
    w_rect := cast(^Rect)win
    e_rect := cast(^Rect)elem // funny

    e_rect.x = (w_rect.w - e_rect.w) / 2
}

center_vertical :: proc(win: rawptr, elem: rawptr) {
    w_rect := cast(^Rect)win
    e_rect := cast(^Rect)elem

    e_rect.y = (w_rect.h - e_rect.h) / 2
}


align_elem :: proc(win: rawptr, align: Direction, elem: rawptr) {
    switch align {
    case .Up:    align_top_elem   (win, elem)
    case .Down:  align_bottom_elem(win, elem)
    case .Left:  align_left_elem  (win, elem)
    case .Right: align_right_elem (win, elem)
    }
}


align_left_elem :: proc(win: rawptr, elem: rawptr) {
    (cast(^Rect)elem).x = (cast(^Rect)win).x
}

align_right_elem :: proc(win: rawptr, elem: rawptr) {
    w_rect := cast(^Rect)win
    e_rect := cast(^Rect)elem

    e_rect.x = (w_rect.x + w_rect.w) - e_rect.w
}

align_top_elem :: proc(win: rawptr, elem: rawptr) {
    (cast(^Rect)elem).y = (cast(^Rect)win).y
}

align_bottom_elem :: proc(win: rawptr, elem: rawptr) {
    w_rect := cast(^Rect)win
    e_rect := cast(^Rect)elem

    e_rect.y = (w_rect.y + w_rect.h) - e_rect.h
}

// Padding ---------------------------------------------------------------------------------------------------------- //
pad_elem :: proc(elem: rawptr, padding: Padding) {
    rect := cast(^Rect)elem

    rect.x += padding[.Left]
    rect.y += padding[.Up]
    rect.w -= padding[.Left] + padding[.Right]
    rect.h -= padding[.Up] + padding[.Down]
}


// Splits ----------------------------------------------------------------------------------------------------------- //
// NOTICE: Everything is calculated relative to `win` position (which is relative),
//         which means that if you plug a `Buffer` here the function will *not work as expected*.
split_horizontal :: proc(win: rawptr, elems: ..rawptr) {
    rect := cast(^Rect)win
    w, h := rect.w / len(elems), rect.h

    for e, i in elems {
        r := cast(^Rect)e
        r.x = rect.x + i * w
        r.y = rect.y

        r.w = w
        r.h = h
    }
}


split_vertical :: proc(win: rawptr, elems: ..rawptr) {
    rect := cast(^Rect)win
    w, h := rect.w, rect.h / len(elems)

    for e, i in elems {
        r := cast(^Rect)e
        r.y = rect.y + i * h
        r.x = rect.x

        r.h = h
        r.w = w
    }
}


// split_grid :: proc(win: rawptr, cols, rows: int, elems: ..rawptr) {
//     rect := cast(^Rect)win
//     w := rect.w / cols
//     h := rect.h / rows

//     for e, i in elems {
//         r    := cast(^Rect)e
//         col  := i % cols
//         row  := i / cols
//         r.x   = rect.x + col * w
//         r.y   = rect.y + row * h
//         r.w   = w
//         r.h   = h
//     }
// }


// Padded ----------------------------------------------------------------------------------------------------------- //
split_horizontal_padded :: proc(win: rawptr, padding: Padding, elems: ..rawptr) {
    rect := cast(^Rect)win
    x := rect.x
    y := rect.y + padding[.Up]
    // win.w = n*(pad_l + w + pad_r) -> solving for w we get:
    w := (rect.w / len(elems)) - (padding[.Left] + padding[.Right])
    h := rect.h - padding[.Down] - padding[.Up]

    for e, i in elems {
        r := cast(^Rect)e

        r.x = x + padding[.Left] + i*(padding[.Left] + w + padding[.Right])
        r.w = w
        
        r.y = y
        r.h = h
    }
}


split_vertical_padded :: proc(win: rawptr, padding: Padding, elems: ..rawptr) {
    rect := cast(^Rect)win
    x := rect.x + padding[.Left]
    y := rect.y
    w := rect.w - padding[.Left] - padding[.Right]
    // win.h = n*(pad_u + h + pad_d) -> solving for h we get:
    h := (rect.h / len(elems)) - (padding[.Up] + padding[.Down])

    for e, i in elems {
        r := cast(^Rect)e

        r.y = y + padding[.Up] + i*(padding[.Up] + h + padding[.Down])
        r.h = h
        
        r.x = x
        r.w = w
    }
}

// Stacks ----------------------------------------------------------------------------------------------------------- //
// Elements share their adjacent border so it isn't doubled.
// `border` is the thickness of the shared edge (usually 1).
stack_horizontal :: proc(win: rawptr, border: int, elems: ..rawptr) {
    rect := cast(^Rect)win

    n := len(elems)
    w := (rect.w + (n - 1) * border) / n

    for e, i in elems {
        r := cast(^Rect)e

        r.x = rect.x + i * (w - border)
        r.y = rect.y
        r.w = w
        r.h = rect.h
    }
}

stack_vertical :: proc(win: rawptr, border: int, elems: ..rawptr) {
    rect := cast(^Rect)win

    n := len(elems)
    h := (rect.h + (n - 1) * border) / n

    for e, i in elems {
        r := cast(^Rect)e

        r.x = rect.x
        r.y = rect.y + i * (h - border)
        r.w = rect.w
        r.h = h
    }
}

// Padded ----------------------------------------------------------------------------------------------------------- //
// stack_horizontal_padded :: proc(win: rawptr, padding: Padding, border: int, elems: ..rawptr) {
//     rect := cast(^Rect)win

//     n := len(elems)
//     // Available width after outer padding, then collapsed across n cells
//     avail := rect.w - padding[.Left] - padding[.Right]
//     w := (avail + (n - 1) * border) / n
//     h := rect.h - padding[.Up] - padding[.Down]

//     for e, i in elems {
//         r := cast(^Rect)e

//         r.x = rect.x + padding[.Left] + i * (w - border)
//         r.y = rect.y + padding[.Up]
//         r.w = w
//         r.h = h
//     }
// }

// stack_vertical_padded :: proc(win: rawptr, padding: Padding, border: int, elems: ..rawptr) {
//     rect := cast(^Rect)win

//     n     := len(elems)
//     avail := rect.h - padding[.Up] - padding[.Down]
//     h     := (avail + (n - 1) * border) / n
//     w     := rect.w - padding[.Left] - padding[.Right]

//     for e, i in elems {
//         r := cast(^Rect)e

//         r.x = rect.x + padding[.Left]
//         r.y = rect.y + padding[.Up] + i * (h - border)
//         r.h = h
//     }
// }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// CHECK CODE BELOW !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// I'm lazy and this was written by a clanker !!!
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// // Flex grid -------------------------------------------------------------------------------------------------------- //
// // Pass 0 for an element's size to make it greedy (fills remaining space equally)
// flex_horizontal :: proc(win: rawptr, sizes: []int, elems: ..rawptr) {
//     rect   := cast(^Rect)win
//     fixed  := 0
//     greedy := 0

//     for s in sizes {
//         if s == 0 do greedy += 1
//         else       do fixed  += s
//     }

//     greedy_w := (rect.w - fixed) / max(greedy, 1)
//     x := rect.x

//     for e, i in elems {
//         r   := cast(^Rect)e
//         w   := greedy_w if sizes[i] == 0 else sizes[i]
//         r.x  = x
//         r.y  = rect.y
//         r.w  = w
//         r.h  = rect.h
//         x   += w
//     }
// }

// // Utilities -------------------------------------------------------------------------------------------------------- //
// point_in_rect :: proc(win: rawptr, x, y: int) -> bool {
//     r := cast(^Rect)win
//     return x >= r.x && x < r.x + r.w &&
//            y >= r.y && y < r.y + r.h
// }

// rect_contains :: proc(outer: rawptr, inner: rawptr) -> bool {
//     o, i := cast(^Rect)outer, cast(^Rect)inner
//     return i.x >= o.x && i.y >= o.y &&
//            i.x + i.w <= o.x + o.w &&
//            i.y + i.h <= o.y + o.h
// }

// rect_intersect :: proc(a: rawptr, b: rawptr) -> (Rect, bool) {
//     r1, r2 := cast(^Rect)a, cast(^Rect)b
//     x := max(r1.x, r2.x)
//     y := max(r1.y, r2.y)
//     w := min(r1.x + r1.w, r2.x + r2.w) - x
//     h := min(r1.y + r1.h, r2.y + r2.h) - y
//     if w <= 0 || h <= 0 do return {}, false
//     return {{x, y}, {w, h}}, true
// }

// // Fit: largest rect with given ratio that fits inside win (letterbox)
// fit_aspect :: proc(win: rawptr, elem: rawptr, ratio_w, ratio_h: int) {
//     w_rect := cast(^Rect)win
//     e_rect := cast(^Rect)elem

//     if w_rect.w * ratio_h < w_rect.h * ratio_w {
//         e_rect.w = w_rect.w
//         e_rect.h = w_rect.w * ratio_h / ratio_w
//     } else {
//         e_rect.h = w_rect.h
//         e_rect.w = w_rect.h * ratio_w / ratio_h
//     }
//     // Center it
//     e_rect.x = w_rect.x + (w_rect.w - e_rect.w) / 2
//     e_rect.y = w_rect.y + (w_rect.h - e_rect.h) / 2
// }

