package odtui

import "core:os"
import "core:strconv"
import "core:unicode"

import "termctl"

// TODO: Comment, Simplify, Rewrite

/// TYPES //////////////////////////////////////////////////////////////////////

Input :: union {
    Keyboard_Input,
    Mouse_Input,
}

Key :: enum {
    None,
    // Arrows
    Arrow_Left, Arrow_Right, Arrow_Up, Arrow_Down,
    // Special keys
    Page_Up, Page_Down,
    Home, End,
    Insert, Delete,
    Escape,
    Enter, Tab, Backspace,
    // Functions keys
    F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
    // Keys
    Num_0, Num_1, Num_2, Num_3, Num_4,
    Num_5, Num_6, Num_7, Num_8, Num_9,
    A, B, C, D, E, F, G, H,
    I, J, K, L, M, N, O, P,
    Q, R, S, T, U, V, W, X,
    Y, Z,
    Minus, Plus, Equal,
    // Parens
    Open_Paren, Close_Paren,
    Open_Curly_Bracket, Close_Curly_Bracket,
    Open_Square_Bracket, Close_Square_Bracket,
    // Other keys
    Colon, Semicolon,
    Slash, Backslash,
    Single_Quote, Double_Quote,
    Period,
    Asterisk,
    Backtick,
    Space,
    Dollar,
    Exclamation,
    Hash,
    Percent,
    Ampersand,
    Tick,
    Underscore,
    Caret,
    Comma,
    Pipe,
    At,
    Tilde,
    Less_Than, Greater_Than,
    Question_Mark,
}

Mod :: enum {
    None,
    Alt,
    Ctrl,
    Shift,
}

Keyboard_Input :: struct {
    mod: Mod,
    key: Key,
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
    input, has_input := termctl.raw_read(buf)
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
    raw, input_ok := termctl.raw_read(buf)
    return cast(string)raw, input_ok
}

read_raw_blocking :: proc(buf: []u8) -> (input: string, ok: bool) {
    bytes_read, err := os.read(os.stdin, buf)
    if err != nil { panic("Failed to get user input!") }

    return cast(string)buf[:bytes_read], bytes_read > 0
}




// Note: The terminal processes some inputs making them be treated the same,
//       so if you're checking for a certain input and always .None,
//       check what value it is processed into.
//       For example, `.Escape` is either Esc, Ctrl + [ and Ctrl + 3 to the terminal.
// TODO: Make some test to determine which inputs are processed
//       to implement parsing mechanism for them to make the API more consistent.
// Parses the termctl.raw bytes sent by the terminal in `Input`.
parse_keyboard_input :: proc( input: string ) -> ( keyboard_input: Keyboard_Input, ok: bool) {
    _alnum_to_key :: proc(r: rune) -> (key: Key, ok: bool) {
        switch r {
        case '\x1b': key = .Escape
        case '\r', '\n': key = .Enter
        case '\t': key = .Tab
        case 8, 127: key = .Backspace
        case '1': key = .Num_1
        case '2': key = .Num_2
        case '3': key = .Num_3
        case '4': key = .Num_4
        case '5': key = .Num_5
        case '6': key = .Num_6
        case '7': key = .Num_7
        case '8': key = .Num_8
        case '9': key = .Num_9
        case '0': key = .Num_0
        case 'a', 'A': key = .A
        case 'b', 'B': key = .B
        case 'c', 'C': key = .C
        case 'd', 'D': key = .D
        case 'e', 'E': key = .E
        case 'f', 'F': key = .F
        case 'g', 'G': key = .G
        case 'h', 'H': key = .H
        case 'i', 'I': key = .I
        case 'j', 'J': key = .J
        case 'k', 'K': key = .K
        case 'l', 'L': key = .L
        case 'm', 'M': key = .M
        case 'n', 'N': key = .N
        case 'o', 'O': key = .O
        case 'p', 'P': key = .P
        case 'q', 'Q': key = .Q
        case 'r', 'R': key = .R
        case 's', 'S': key = .S
        case 't', 'T': key = .T
        case 'u', 'U': key = .U
        case 'v', 'V': key = .V
        case 'w', 'W': key = .W
        case 'x', 'X': key = .X
        case 'y', 'Y': key = .Y
        case 'z', 'Z': key = .Z
        case ',': key = .Comma
        case ':': key = .Colon
        case ';': key = .Semicolon
        case '-': key = .Minus
        case '+': key = .Plus
        case '=': key = .Equal
        case '{': key = .Open_Curly_Bracket
        case '}': key = .Close_Curly_Bracket
        case '(': key = .Open_Paren
        case ')': key = .Close_Paren
        case '[': key = .Open_Square_Bracket
        case ']': key = .Close_Square_Bracket
        case '/': key = .Slash
        case '\'': key = .Single_Quote
        case '"': key = .Double_Quote
        case '.': key = .Period
        case '*': key = .Asterisk
        case '`': key = .Backtick
        case '\\': key = .Backslash
        case ' ': key = .Space
        case '$': key = .Dollar
        case '!': key = .Exclamation
        case '#': key = .Hash
        case '%': key = .Percent
        case '&': key = .Ampersand
        case '´': key = .Tick
        case '_': key = .Underscore
        case '^': key = .Caret
        case '|': key = .Pipe
        case '@': key = .At
        case '~': key = .Tilde
        case '<': key = .Less_Than
        case '>': key = .Greater_Than
        case '?': key = .Question_Mark
        case: ok = false; return
        }

        ok = true; return
    }

    input := input
    seq: Keyboard_Input

    if len(input) == 0 do return

    if len(input) == 1 {
        input_rune := cast(rune)input[0]
        if unicode.is_upper(input_rune) {
            seq.mod = .Shift
        }

        if unicode.is_control(input_rune) {
        switch input_rune {
        case:
            seq.mod = .Ctrl
            input_rune += 64
        case '\b', '\n':
            seq.mod = .Ctrl
        case '\r', '\t', '\x1b', 127: /* backspace */
        }
    }

    key, ok := _alnum_to_key(input_rune)
    if !ok do return {}, false
    seq.key = key
    return seq, true
    }

    if input[0] != '\x1b' do return

    if len(input) > 3 {
        input_len := len(input)

        if input[input_len - 3] == ';' {
            switch input[input_len - 2] {
            case '2': seq.mod = .Shift
            case '3': seq.mod = .Alt
            case '5': seq.mod = .Ctrl
            }
        }
    }

    if len(input) >= 2 {
        switch input[len(input) - 1] {
        case 'P': seq.key = .F1
        case 'Q': seq.key = .F2
        case 'R': seq.key = .F3
        case 'S': seq.key = .F4
        }

        if input[1] == 'O' do return seq, true
    }

    if input[1] == '[' {
        input = input[2:]

    if len(input) > 2 && input[0] == '1' && input[1] == ';' {
         switch input[2] {
         case '2': seq.mod = .Shift
         case '3': seq.mod = .Alt
         case '5': seq.mod = .Ctrl
        }

        input = input[3:]
    }


    if len(input) == 1 {
        switch input[0] {
        case 'H': seq.key = .Home
        case 'F': seq.key = .End
        case 'A': seq.key = .Arrow_Up
        case 'B': seq.key = .Arrow_Down
        case 'C': seq.key = .Arrow_Right
        case 'D': seq.key = .Arrow_Left
        case 'Z': seq.key = .Tab
                  seq.mod = .Shift
        }
    }


    if len(input) >= 2 {
        switch input[0] {
        case 'O':
            switch input[1] {
            case 'H': seq.key = .Home
            case 'F': seq.key = .End
            }
        case '1':
            switch input[1] {
            case 'P': seq.key = .F1
            case 'Q': seq.key = .F2
            case 'R': seq.key = .F3
            case 'S': seq.key = .F4
            }
        }
    }


    if input[len(input) - 1] == '~' {
        switch input[0] {
        case '1', '7': seq.key = .Home
        case '2':      seq.key = .Insert
        case '3':      seq.key = .Delete
        case '4', '8': seq.key = .End
        case '5':      seq.key = .Page_Up
        case '6':      seq.key = .Page_Down
        }

        switch input[0] {
        case '1':
            switch input[1] {
            case '1': seq.key = .F1
            case '2': seq.key = .F2
            case '3': seq.key = .F3
            case '4': seq.key = .F4
            case '5': seq.key = .F5
            case '7': seq.key = .F6
            case '8': seq.key = .F7
            case '9': seq.key = .F8
            }
        case '2':
            switch input[1] {
            case '0': seq.key = .F9
            case '1': seq.key = .F10
            case '3': seq.key = .F11
            case '4': seq.key = .F12
            }
        }
    }


    if seq != {} do return seq, true
    }

    // alt is ESC + <char>
    if len(input) == 2 {
        key, ok := _alnum_to_key(cast(rune)input[1])
        if ok {
            seq.mod = .Alt
            seq.key = key
            return seq, true
        }
    }

    return
}

// Note: mouse input is not always guaranteed. The user might be running the program from
//       a TTY or the terminal emulator might just not support mouse input.
// Parses the termctl.raw bytes sent by the terminal in `Input`
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

