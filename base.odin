package odtui

import tcl "termctl"
import str "core:strings"

Context :: struct {
    render_buffer: Buffer,
    diff_buffer:   Buffer,
    render_sb: str.Builder
}


default_context_make :: proc(ctx: ^Context) {
    term_sz := tcl.get_term_size()
    buffer_make(&ctx.render_buffer, term_sz.w, term_sz.h)
    buffer_make(&ctx.diff_buffer, term_sz.w, term_sz.h)

    render_sb, _ := str.builder_make()
    ctx.render_sb = render_sb
}


default_context_delete :: proc(ctx: ^Context) {
    buffer_delete(&ctx.render_buffer)
    buffer_delete(&ctx.diff_buffer)

    str.builder_destroy(&ctx.render_sb)
}


context_render :: proc(ctx: Context)
context_render_diff :: proc(ctx: Context)

// TODO: `render` and `render_diff` overloads for `Buffer` and `Context`

