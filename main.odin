package odtui

import "core:unicode/utf8"
import tcl "termctl"
import sym "symbols"

import "core:fmt"
import "core:log"
import str "core:strings"

main :: proc() {
    context.logger = log.create_console_logger(.Debug, {.Level, .Procedure, .Terminal_Color})

    tui_ctx: TUI_Context
    default_context_make(&tui_ctx)

    tcl.set_term_mode(.Raw)

    main_w: Window
    secn_w: Window
    window_make(&tui_ctx.main_buffer, &main_w, -1, -1)
    window_make(&tui_ctx.main_buffer, &secn_w, -1, -1)

    split_horizontal_padded(&main_w, PADDING_BOX, false, &main_w, &secn_w)

    box_write_borders(&main_w)
    box_write_borders(&secn_w)

    m_writer := window_to_writer(&main_w, true)
    s_writer := window_to_writer(&secn_w, false)

    fmt.wprintln(s_writer, "pot")
    render_diff(&tui_ctx)
    fmt.wprintln(m_writer, "prt")
    render_diff(&tui_ctx)

    inp_buff: [1024]u8
    main_loop: for {
        input := read(inp_buff[:])

        #partial switch inp in input {
        case Keyboard_Input:
            if inp.key == 'q' && inp.mod == .Alt { break main_loop }
            if inp.key == 'c' && inp.mod == .Alt { window_fill(&secn_w, {' ', .None, nil, nil}); window_set_cursor(&secn_w, 0, 0) }
            if secn_w.cy == secn_w.h { window_fill(&secn_w, {' ', .None, nil, nil}); secn_w.cy = 0 }
            fmt.wprintfln(s_writer, "%v", inp)
            render_diff(&tui_ctx)
        case Mouse_Input:
            if main_w.cy == main_w.h { window_fill(&main_w, {' ', .None, nil, nil}); main_w.cy = 0 }
            fmt.wprintfln(m_writer, "%v", inp.pos)
            render_diff(&tui_ctx)
        }
    }

    tcl.set_term_mode(.Restored)
    tcl.show_cursor()
}
