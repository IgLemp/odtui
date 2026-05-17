package odtui

import tcl "termctl"
import str "core:strings"


// TODO: Set up a watch for `SIGWINCH` to check for terminal resizes lazily.
//       Give user `on_size_change` function or a volatile variable to check in main loop.
//       Well... I can actually both.


TUI_Context :: struct {
    main_buffer: Buffer,
    prev_buffer: Buffer,
    diff_buffer: Buffer,
    render_sb: str.Builder
}


default_context_make :: proc(ctx: ^TUI_Context, w: int = -1, h: int = -1) {
    term_sz: Rect
    if w == -1 || h == -1 { term_sz = tcl.get_term_size() }
    else                  { term_sz = {{0, 0}, {w, h}} }

    buffer_make(&ctx.main_buffer, term_sz.w, term_sz.h)
    buffer_make(&ctx.prev_buffer, term_sz.w, term_sz.h)
    buffer_make(&ctx.diff_buffer, term_sz.w, term_sz.h)

    render_sb, _ := str.builder_make()
    ctx.render_sb = render_sb
}


default_context_delete :: proc(ctx: ^TUI_Context) {
    buffer_delete(&ctx.main_buffer)
    buffer_delete(&ctx.prev_buffer)
    buffer_delete(&ctx.diff_buffer)

    str.builder_destroy(&ctx.render_sb)
}


context_render :: proc(ctx: ^TUI_Context) {
    buffer_render(&ctx.main_buffer, &ctx.render_sb) 
}

context_render_diff :: proc(ctx: ^TUI_Context) {
    buffer_render_diff(&ctx.main_buffer, &ctx.prev_buffer, &ctx.diff_buffer, &ctx.render_sb) 
    buffer_blit(ctx.main_buffer, ctx.prev_buffer)
}

// OVERLOADS //////////////////////////////////////////////////////////////////////////////////////////////////////////
render :: proc{ context_render, buffer_render }
render_diff :: proc{ context_render_diff, buffer_render_diff }

