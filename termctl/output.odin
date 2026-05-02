package termctl

import "core:log"
import "core:fmt"
import "core:terminal"
import "core:terminal/ansi"
import str "core:strings"


print_rune :: proc(sb: ^str.Builder, r: rune) {
    // These characters should not be here anyways
    if (r == '\n') || (r == '\r') { return }
    str.write_rune(sb, r)
}

set_text_style :: proc(sb: ^str.Builder, styles: bit_set[Text_Style]) {
    SGR_BOLD      :: ansi.CSI + ansi.BOLD      + "m"
    SGR_DIM       :: ansi.CSI + ansi.FAINT     + "m"
    SGR_ITALIC    :: ansi.CSI + ansi.ITALIC    + "m"
    SGR_UNDERLINE :: ansi.CSI + ansi.UNDERLINE + "m"
    SGR_INVERTED  :: ansi.CSI + ansi.INVERT    + "m"
    SGR_CROSSED   :: ansi.CSI + ansi.STRIKE    + "m"

    if .Bold      in styles do str.write_string(sb, SGR_BOLD)
    if .Dim       in styles do str.write_string(sb, SGR_DIM)
    if .Italic    in styles do str.write_string(sb, SGR_ITALIC)
    if .Underline in styles do str.write_string(sb, SGR_UNDERLINE)
    if .Inverted  in styles do str.write_string(sb, SGR_INVERTED)
    if .Crossed   in styles do str.write_string(sb, SGR_CROSSED)
}

@(private)
_set_color_8 :: proc(builder: ^str.Builder, color: uint) {
    SGR_COLOR :: ansi.CSI + "%dm"
    str.write_string(builder, ansi.CSI)
    str.write_uint(builder, color)
    str.write_rune(builder, 'm')
}

@(private)
_get_color_8_code :: proc(c: Color_8, is_bg: bool) -> uint {
    code: uint
    switch c {
    case .Black:   code = 30
    case .Red:     code = 31
    case .Green:   code = 32
    case .Yellow:  code = 33
    case .Blue:    code = 34
    case .Magenta: code = 35
    case .Cyan:    code = 36
    case .White:   code = 37
    }

    if is_bg do code += 10
    return code
}

@(private)
_set_color_rgb :: proc(builder: ^str.Builder, color: Color_RGB, is_bg: bool) {
    str.write_string(builder, ansi.CSI)
    str.write_uint(builder, 48 if is_bg else 38)
    str.write_string(builder, ";2;")
    str.write_uint(builder, cast(uint)color.r)
    str.write_rune(builder, ';')
    str.write_uint(builder, cast(uint)color.g)
    str.write_rune(builder, ';')
    str.write_uint(builder, cast(uint)color.b)
    str.write_rune(builder, 'm')
}

set_fg_color_style :: proc(sb: ^str.Builder, fg: Any_Color) {
    DEFAULT_FG :: 39
    switch fg_color in fg {
    case Color_8:   _set_color_8(sb, _get_color_8_code(fg_color, false))
    case Color_RGB: _set_color_rgb(sb, fg_color, false)
    case:           _set_color_8(sb, DEFAULT_FG)
    }
}

set_bg_color_style :: proc(sb: ^str.Builder, bg: Any_Color) {
    DEFAULT_BG :: 49
    switch bg_color in bg {
    case Color_8:   _set_color_8(sb, _get_color_8_code(bg_color, true))
    case Color_RGB: _set_color_rgb(sb, bg_color, true)
    case:           _set_color_8(sb, DEFAULT_BG)
    }
}

reset_styles :: proc(bg: ^str.Builder) {
    str.write_string(bg, ansi.CSI + "0m")
}

