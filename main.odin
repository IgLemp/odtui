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
    // default_context_make(&tui_ctx, 140, 10)
    default_context_make(&tui_ctx, -1, -1)

    tcl.set_term_mode(.Raw)

    mainu_w: Window
    maind_w: Window
    secn_w: Window
    window_make(&tui_ctx.main_buffer, &mainu_w, -1, -1)
    window_make(&tui_ctx.main_buffer, &maind_w, -1, -1)
    window_make(&tui_ctx.main_buffer, &secn_w, -1, -1)

    stack_horizontal(&mainu_w, 1, &mainu_w, &secn_w)
    stack_vertical(&mainu_w, 1, &mainu_w, &maind_w)

    pad_elem(&secn_w, PADDING_BOX)
    pad_elem(&mainu_w, PADDING_BOX)
    pad_elem(&maind_w, PADDING_BOX)

    box_write_borders(&mainu_w)
    box_write_borders(&maind_w)
    box_write_borders(&secn_w)
    window_fill(&mainu_w, {' ', .None, nil, .Red})
    window_fill(&maind_w, {' ', .None, nil, .Cyan})
    window_fill(&secn_w, {' ', .None, nil, .Blue})

    m_writer := window_to_writer(&mainu_w, true)
    b_writer := window_to_writer(&maind_w, true)
    s_writer := window_to_writer(&secn_w, false)

    writer_set_style(m_writer, {.None, nil, nil})
    writer_set_style(s_writer, {.None, nil, nil})
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
            fmt.wprint(b_writer, inp.raw)
            render(&tui_ctx)
        case Mouse_Input:
            if mainu_w.cy == mainu_w.h { window_clear(&mainu_w); mainu_w.cy = 0 }
            fmt.wprintfln(m_writer, "%v", inp.pos)
            render(&tui_ctx)
        }
    }

    tcl.set_term_mode(.Restored)
    tcl.show_cursor()
}
