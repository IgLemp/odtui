package odtui

import tcl "termctl"

import "core:fmt"
import "core:log"
import itr "base:intrinsics"

main :: proc() {
    context.logger = log.create_console_logger()

    main_b: Buffer
    term_sz := tcl.get_term_size()
    buffer_make(&main_b, term_sz.w, term_sz.h) 

    diff_b: Buffer
    buffer_make(&diff_b, main_b.w, main_b.h)

    render_b: Buffer
    buffer_make(&render_b, main_b.w, main_b.h)
    
    main_w: Window
    window_make(&main_b, &main_w, -1, -1)

    window_write_line(&main_w, "AAAAAaaaaaaaaaaaaaaaaa", {.None, .White, .None})
    buffer_render_diff(&main_b, &render_b, &diff_b)
    // buffer_render(&main_b)
}
