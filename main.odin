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
    default_context_make(&tui_ctx, 140, 10)

    tcl.set_term_mode(.Raw)

    main_w: Window
    secn_w: Window
    window_make(&tui_ctx.main_buffer, &main_w, -1, -1)
    window_make(&tui_ctx.main_buffer, &secn_w, -1, -1)

    split_horizontal_padded(&main_w, PADDING_BOX, &main_w, &secn_w)

    bot_w: Window
    window_make(&tui_ctx.main_buffer, &bot_w, -1, -1)
    split_horizontal_padded(&main_w, PADDING_ZERO, &main_w, &bot_w)
    // pad_elem(&bot_w, PADDING_BOX)
    // pad_elem(&main_w, PADDING_BOX)

    box_write_borders(&main_w)
    box_write_borders(&secn_w)
    box_write_borders(&bot_w)
    window_fill(&main_w, {' ', .None, nil, .Red})
    window_fill(&bot_w, {' ', .None, nil, .Cyan})
    window_fill(&secn_w, {' ', .None, nil, .Blue})

    m_writer := window_to_writer(&main_w, true)
    s_writer := window_to_writer(&secn_w, false)
    b_writer := window_to_writer(&bot_w, false)

    writer_set_style(m_writer, {.None, nil, nil})
    writer_set_style(s_writer, {.None, nil, nil})
    fmt.wprintln(s_writer, "pot")
    fmt.wprintln(m_writer, "prt")
    render(&tui_ctx)

    inp_buff: [1024]u8
    main_loop: for {
        input := read(inp_buff[:])

        #partial switch inp in input {
        case Keyboard_Input:
            if inp.key == 'q' && inp.mod == .Alt { break main_loop }
            if inp.key == 'c' && inp.mod == .Alt { window_clear(&secn_w); writer_set_position(s_writer) }
            if secn_w.cy == secn_w.h             { window_clear(&secn_w); writer_set_position(s_writer) }
            fmt.wprintfln(s_writer, "%v", inp)
            writer_set_position(b_writer)
            window_clear(&bot_w)
            fmt.wprintln(b_writer, secn_w.backing.buff[lin_to_buff(secn_w.w + 1, secn_w.x, secn_w.y, secn_w.w, secn_w.backing.w)].bg)
            render(&tui_ctx)
        case Mouse_Input:
            if main_w.cy == main_w.h { window_clear(&main_w); main_w.cy = 0 }
            fmt.wprintfln(m_writer, "%v", inp.pos)
            render(&tui_ctx)
        }
    }

    tcl.set_term_mode(.Restored)
    tcl.show_cursor()
}
