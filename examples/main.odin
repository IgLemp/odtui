package examples

import "core:log"

import t "../"
import tctl "../termctl"

main :: proc() {
    context.logger = log.create_console_logger(log.Level.Debug, {.Line, .Procedure, .Terminal_Color, .Short_File_Path})

    term_size := tctl.get_term_size()

    main_b: t.Buffer
    buff_b: t.Buffer
    t.buffer_make(&main_b, 2, 2, 0, 1)
    t.buffer_make(&buff_b, 2, 2, 0, 1)

    main_w: t.Window
    t.window_make(&main_b, &main_w, -1, -1)
    t.window_fill(&main_w, {' ', .None, .None, .None})

    t.window_write_line_wrapping(&main_w, "Potato salad", {.None, .Red, .White})

    // t.buffer_render(&main_b)
    // t.buffer_blit(main_b, buff_b)

    t.buffer_render_diff(&main_b, &buff_b)
    // t.buffer_blit(main_b, buff_b)

    // input_buffer: [1024]u8
    // main_loop: for {
        // input := t.read_blocking(input_buffer[:])

        // kb, kb_ok := input.(t.Keyboard_Input)
        // if kb_ok { if kb.key == .Q { break main_loop } }

    // }

}


run_test :: proc() {
    // cursor_move(0, 0)
    // hide_cursor()
    // defer show_cursor()
    // enable_alt_buffer()

    // text_overflow()
    // window_behaviour_pos()
    // window_behaviour_pos_wrap()
    // window_behaviour_cursor()
    // window_behaviour_cursor_wrap()
    // box_behaviour_borders()
    // split_test()
    // split_padded_test()
    // alignment_test()

    // time.sleep(time.Second * 2)
    // disable_alt_buffer()
}
