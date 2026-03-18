package odtui

import "core:fmt"
import "core:terminal"
import "core:terminal/ansi"
import "core:os"
import "core:time"
import "core:log"


SAFEGUARDS :: false


main :: proc() {
    context.logger = log.create_console_logger(log.Level.Debug, {.Line, .Procedure, .Terminal_Color, .Short_File_Path})

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

