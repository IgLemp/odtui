package termctl

import t ".."
import "core:c"
import "core:sys/darwin"

get_term_size :: proc() -> t.Rect {
    winsize :: struct {
        ws_row, ws_col:       c.ushort,
        ws_xpixel, ws_ypixel: c.ushort,
    }

    ws: winsize
    if darwin.syscall_ioctl(1, darwin.TIOCGWINSZ, &ws) != 0 {
        panic("Failed to get terminal size")
    }

    h := int(ws.ws_row)
    w := int(ws.ws_col)

    return { {0, 0}, {w, h} }
}

