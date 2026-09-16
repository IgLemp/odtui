package termctl

import "core:c"
import "core:sys/freebsd"


get_term_size :: proc() -> Rect {
   winsize :: struct {
        ws_row, ws_col:       c.ushort,
        ws_xpixel, ws_ypixel: c.ushort,
    }

    ws: winsize
    if freebsd.ioctl(freebsd.STDOUT_FILENO, freebsd.TIOCGWINSZ, cast(uintptr)&ws) != 0 {
        panic("Failed to get terminal size!")
    }

    h := int(ws.ws_row)
    w := int(ws.ws_col)

    return { {0, 0}, {w, h} }
}

