package odtui

import tcl "termctl"
import sym "symbols"

import "core:fmt"
import "core:log"
import str "core:strings"

main :: proc() {
    context.logger = log.create_console_logger(.Debug, {.Level, .Procedure, .Terminal_Color})

    tui_ctx: TUI_Context
    default_context_make(&tui_ctx, 20, 20)

    tcl.set_term_mode(.Raw)

    main_w: Window
    window_make(&tui_ctx.main_buffer, &main_w, -1, -1)

    window_write_line(&main_w, "1234567890abcdef\n", {.None, nil, nil})

    writer := window_to_writer(&main_w, true)

    render(&tui_ctx)

    inp_buff: [1024]u8
    main_loop: for {
        input := tcl.read(inp_buff[:])
        #partial switch inp in input {
        case Keyboard_Input:
            if inp.key == .Q { break main_loop }
            fmt.wprintf(writer, "%v", inp.key)
            render(&tui_ctx)
        }
    }

    tcl.set_term_mode(.Restored)
    tcl.show_cursor()
}
