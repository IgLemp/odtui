package odtui

import tcl "termctl"

import "core:fmt"
import "core:log"
import str "core:strings"

main :: proc() {
    context.logger = log.create_console_logger()

    tui_ctx: TUI_Context
    default_context_make(&tui_ctx)

    tcl.set_term_mode(.Raw)

    main_w: Window
    box_make(&tui_ctx.main_buffer, &main_w)
    box_write_borders(&main_w)

    window_write_line(&main_w, "1234567890", {.None, nil, nil})
    render(&tui_ctx)

    inp_buff: [1024]u8
    main_loop: for {
        input := tcl.read(inp_buff[:])
        #partial switch inp in input {
        case Keyboard_Input:
            if inp.key == .Q { break main_loop }
        }
    }

    tcl.set_term_mode(.Restored)
    tcl.show_cursor()
}
