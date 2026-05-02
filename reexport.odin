package odtui

import tcl "termctl"

// Input ///////////////////////////////////////////////////////////////////////
Input                :: tcl.Input
Mouse_Event          :: tcl.Mouse_Event
Mouse_Input          :: tcl.Mouse_Input
Mouse_Key            :: tcl.Mouse_Key
Keyboard_Input       :: tcl.Keyboard_Input
Key                  :: tcl.Key
Mod                  :: tcl.Mod

read_raw_blocking    :: tcl.read_raw_blocking
read_blocking        :: tcl.read_blocking
read_raw             :: tcl.read_raw
read                 :: tcl.read

parse_keyboard_input :: tcl.parse_keyboard_input
parse_mouse_input    :: tcl.parse_mouse_input


// Output //////////////////////////////////////////////////////////////////////
print_rune         :: tcl.print_rune
set_text_style     :: tcl.set_text_style
set_fg_color_style :: tcl.set_fg_color_style
set_bg_color_style :: tcl.set_bg_color_style
reset_styles       :: tcl.reset_styles

// Terminal ////////////////////////////////////////////////////////////////////
Any_Color          :: tcl.Any_Color
Style              :: tcl.Style
Text_Style         :: tcl.Text_Style
Color_8            :: tcl.Color_8
Color_RGB          :: tcl.Color_RGB
Rect               :: tcl.Rect
Graph              :: tcl.Graph
Term_Mode          :: tcl.Term_Mode

move_cursor        :: tcl.move_cursor
show_cursor        :: tcl.show_cursor
hide_cursor        :: tcl.hide_cursor

enable_alt_buffer  :: tcl.enable_alt_buffer
disable_alt_buffer :: tcl.disable_alt_buffer

enable_mouse       :: tcl.enable_mouse
disable_mouse      :: tcl.disable_mouse

set_term_mode      :: tcl.set_term_mode
restore_screen     :: tcl.restore_screen
