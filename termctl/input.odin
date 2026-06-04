package termctl

import utf8 "core:unicode/utf8"
import unic "core:unicode"
import "core:os"
import "core:strconv"
import "core:unicode"

// TODO: Comment, Simplify, Rewrite

/// TYPES //////////////////////////////////////////////////////////////////////

Input :: union {
    Keyboard_Input,
    Mouse_Input,
}

Key :: rune

Special_Key :: enum {
    None,
    // Arrows
    Arrow_Left, Arrow_Right, Arrow_Up, Arrow_Down,
    // Special keys
    Page_Up, Page_Down,
    Home, End,
    Menu,
    Insert, Delete,
    Escape,
    Enter, Tab, Backspace,
    // Functions keys
    F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
}

Mod :: enum {
    None,
    Alt,
    Ctrl,
    Shift,
}

Keyboard_Input :: struct {
    mod: Mod,
    key: union { rune, Special_Key },
}

Mouse_Event :: enum {
    Pressed,
    Released,
}

Mouse_Key :: enum {
    None,
    Left,
    Right,
    Middle,
    Scroll_Up,
    Scroll_Down,
}

Mouse_Input :: struct {
    event: bit_set[Mouse_Event],
    mod:   bit_set[Mod],
    key: Mouse_Key,
    pos: [2]int,
}


/// FUNCTIONS //////////////////////////////////////////////////////////////////

read :: proc(buf: []u8) -> Input {
    input, has_input := raw_read(buf)
    if !has_input do return nil

    input_str := transmute(string)input


    mouse_input, mouse_ok := parse_mouse_input(input_str)
    if mouse_ok { return mouse_input }

    kb_input, kb_ok := parse_keyboard_input(input_str)
    if kb_ok { return kb_input }

    return nil
}

read_blocking :: proc(buf: []u8) -> Input {
    input, input_ok := read_raw_blocking(buf)
    if !input_ok do return nil


    mouse_input, mouse_ok := parse_mouse_input(input)
    if mouse_ok { return mouse_input }

    kb_input, kb_ok := parse_keyboard_input(input)
    if kb_ok { return kb_input }


    return nil
}


read_raw :: proc(buf: []u8) -> (input: string, ok: bool) {
    raw, input_ok := raw_read(buf)
    return cast(string)raw, input_ok
}

read_raw_blocking :: proc(buf: []u8) -> (input: string, ok: bool) {
    bytes_read, err := os.read(os.stdin, buf)
    if err != nil { panic("Failed to get user input!") }

    return cast(string)buf[:bytes_read], bytes_read > 0
}



// https://sw.kovidgoyal.net/kitty/keyboard-protocol/#legacy-key-event-encoding
// TODO: Implement Kitty input protocol,
//       The struct fields probably will be adapted
parse_keyboard_input :: proc(inpt: string) -> (keyboard_input: Keyboard_Input, ok: bool) {
    take_rune :: proc(s: ^string) -> rune {
        r, l := utf8.decode_rune_in_string(s^)
        s^ = s^[l:]
        return r
    }

    inpt := inpt
    if len(inpt) == 0 { return {}, false }
    fst_r := take_rune(&inpt)

    // Non contrlol
    if !utf8.is_control(fst_r) {
        if unic.is_upper(fst_r) { return {.Shift, fst_r}, true }
        else                    { return {.None,  fst_r}, true }
    } else

    // Control character
    {
        switch fst_r {
        case '\u0000': return {.Ctrl,  ' '}, true
        case '\u000d': return {.None, .Enter}, true
        case '\u007f': return {.None, .Backspace}, true
        case '\u0008': return {.Ctrl, .Backspace}, true
        case '\u0009': return {.None, .Tab}, true
        case '\u001b':
            snd_r := take_rune(&inpt)
            switch snd_r {
            case '\u0000': return {.Ctrl + .Alt,  ' '}, true
            case '\u000d': return {.Alt,         .Enter}, true
            case '\u007f': return {.Alt,         .Backspace}, true
            case '\u0008': return {.Ctrl + .Alt, .Backspace}, true
            case '\u0009': return {.Alt,         .Tab}, true
            case '\u001b': return {.Alt,         .Escape}, true
            }

            // Non CSI
            if snd_r != '[' {
                if snd_r == 'O' {
                    switch inpt {
                    case "P": return {.None, .F1}, true
                    case "Q": return {.None, .F2}, true
                    case "R": return {.None, .F3}, true
                    case "S": return {.None, .F4}, true
                    }
                }

                if unic.is_upper(snd_r) { return {.Ctrl + .Shift, snd_r}, true }
                else                    { return {.Ctrl,          snd_r}, true }
            } else

            // CSI
            {
                switch inpt {
                case "2~":  return {.None, .Insert}, true
                case "3~":  return {.None, .Delete}, true
                case "5~":  return {.None, .Page_Up}, true
                case "6~":  return {.None, .Page_Down}, true
                case "A":   return {.None, .Arrow_Up}, true
                case "B":   return {.None, .Arrow_Down}, true
                case "C":   return {.None, .Arrow_Right}, true
                case "D":   return {.None, .Arrow_Left}, true
                case "H":   return {.None, .Home}, true
                case "F":   return {.None, .End}, true
                case "15~": return {.None, .F5}, true
                case "17~": return {.None, .F6}, true
                case "18~": return {.None, .F7}, true
                case "19~": return {.None, .F8}, true
                case "20~": return {.None, .F9}, true
                case "21~": return {.None, .F10}, true
                case "23~": return {.None, .F11}, true
                case "24~": return {.None, .F12}, true
                case "29~": return {.None, .Menu}, true
                }
            }
        }
    }

    return {}, false
}



// Note: mouse input is not always guaranteed. The user might be running the program from
//       a TTY or the terminal emulator might just not support mouse input.
// Parses the raw bytes sent by the terminal in `Input`
parse_mouse_input :: proc(input: string) -> (mouse_input: Mouse_Input, has_input: bool) {
    // the mouse input we support is SGR escape code based
    if len(input) < 6 do return

    if input[0] != '\x1b' && input[1] != '[' && input[2] != '<' do return

    consume_semicolon :: proc(input: ^string) -> bool {
        is_semicolon := len(input) >= 1 && input[0] == ';'
        if is_semicolon do input^ = input[1:]
        return is_semicolon
    }

    consumed: int
    input := cast(string)input[3:]

    mod, _ := strconv.parse_uint(input, n = &consumed)
    input = input[consumed:]
    consume_semicolon(&input) or_return

    x_coord, _ := strconv.parse_uint(input, n = &consumed)
    input = input[consumed:]
    consume_semicolon(&input) or_return

    y_coord, _ := strconv.parse_uint(input, n = &consumed)
    input = input[consumed:]

    mouse_key: Mouse_Key
    low_two_bits := mod & 0b11
    switch low_two_bits {
    case 0: mouse_key = .Left
    case 1: mouse_key = .Middle
    case 2: mouse_key = .Right
    }

    mouse_event: bit_set[Mouse_Event]
    if mouse_key != .None {
        if input[0] == 'm' do mouse_event |= {.Released}
        if input[0] == 'M' do mouse_event |= {.Pressed}
    }

    next_three_bits := mod & 0b11100
    mouse_mod: bit_set[Mod]
    if next_three_bits & 4  == 4  do mouse_mod |= {.Shift}
    if next_three_bits & 8  == 8  do mouse_mod |= {.Alt}
    if next_three_bits & 16 == 16 do mouse_mod |= {.Ctrl}

    if mod & 64 == 64 do mouse_key = .Scroll_Up
    if mod & 65 == 65 do mouse_key = .Scroll_Down

    return Mouse_Input {
        event = mouse_event,
        mod = mouse_mod,
        key = mouse_key,
        // coords are converted so it's 0 based index
        pos = {cast(int)x_coord - 1, cast(int)y_coord - 1},
    }, true
}

