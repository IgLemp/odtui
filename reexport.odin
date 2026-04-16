package odtui

import tcl "termctl"

// Input ///////////////////////////////////////////////////////////////////////
Mouse_Input          :: tcl.Mouse_Input
Input                :: tcl.Input
Mod                  :: tcl.Mod
Mouse_Event          :: tcl.Mouse_Event
read_raw_blocking    :: tcl.read_raw_blocking
read_blocking        :: tcl.read_blocking
parse_keyboard_input :: tcl.parse_keyboard_input
read_raw             :: tcl.read_raw
parse_mouse_input    :: tcl.parse_mouse_input
read                 :: tcl.read
Keyboard_Input       :: tcl.Keyboard_Input
Mouse_Key            :: tcl.Mouse_Key
Key                  :: tcl.Key


// Output //////////////////////////////////////////////////////////////////////
print_graph  :: tcl.print_graph
_print_fg_8  :: tcl._print_fg_8
_print_style :: tcl._print_style
_print_bg_8  :: tcl._print_bg_8
print_line   :: tcl.print_line

// Terminal ////////////////////////////////////////////////////////////////////
Any_Color          :: tcl.Any_Color
save_screen        :: tcl.save_screen
Style              :: tcl.Style
Text_Style         :: tcl.Text_Style
hide_cursor        :: tcl.hide_cursor
Color_8            :: tcl.Color_8
Color_RGB          :: tcl.Color_RGB
Rect               :: tcl.Rect
cursor_move        :: tcl.cursor_move
enable_alt_buffer  :: tcl.enable_alt_buffer
show_cursor        :: tcl.show_cursor
set_term_mode      :: tcl.set_term_mode
disable_alt_buffer :: tcl.disable_alt_buffer
enable_mouse       :: tcl.enable_mouse
Graph              :: tcl.Graph
Term_Mode          :: tcl.Term_Mode
disable_mouse      :: tcl.disable_mouse
restore_screen     :: tcl.restore_screen
