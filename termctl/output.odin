package termctl

import "core:log"
import "core:fmt"
import "core:terminal"
import "core:terminal/ansi"

// TODO: Nuke this
print_line :: proc(str: string, style: Style = {.None, .None, .None}) {
    for r in str { print_graph(Graph{r, style.st, style.fg, style.bg}) }
}

print_rune :: proc(r: rune) { fmt.print(r) }

print_graph :: proc(g: Graph) {
    if (g.r == '\n') || (g.r == '\r') { return }

    fmt.print(ansi.CSI)
    _print_style(g.st)

    fg_c, fg_is_color_8 := g.fg.(Color_8)
    bg_c, bg_is_color_8 := g.bg.(Color_8)

    if fg_is_color_8 { _print_fg_8(fg_c) }
    if bg_is_color_8 { _print_bg_8(bg_c) }
    fmt.print("m")

    if !fg_is_color_8 { c, _ := g.fg.(Color_RGB); fmt.printf(ansi.CSI + "38;2;%d;%d;%dm", c.r, c.g, c.b) }
    if !fg_is_color_8 { c, _ := g.bg.(Color_RGB); fmt.printf(ansi.CSI + "48;2;%d;%d;%dm", c.r, c.g, c.b) }

    fmt.print(g.r)
    fmt.print(ansi.CSI + "0m")
}

_print_style :: #force_inline proc(st: Text_Style) {
    switch st {
    case .None:      fmt.print("0")
    case .Bold:      fmt.print("1")
    case .Italic:    fmt.print("3")
    case .Underline: fmt.print("4")
    case .Crossed:   fmt.print("9")
    case .Inverted:  fmt.print("7")
    case .Dim:       fmt.print("2")
    }
    fmt.print("")
}

_print_fg_8 :: #force_inline proc(c: Color_8) {
    switch c {
    case .None:
    case .Black:   fmt.print(";30")
    case .Red:     fmt.print(";31")
    case .Green:   fmt.print(";32")
    case .Yellow:  fmt.print(";33")
    case .Blue:    fmt.print(";34")
    case .Magenta: fmt.print(";35")
    case .Cyan:    fmt.print(";36")
    case .White:   fmt.print(";37")
    }
    fmt.print("")
}

_print_bg_8 :: #force_inline proc(c: Color_8) {
    switch c {
    case .None:
    case .Black:   fmt.print(";100")
    case .Red:     fmt.print(";101")
    case .Green:   fmt.print(";102")
    case .Yellow:  fmt.print(";103")
    case .Blue:    fmt.print(";104")
    case .Magenta: fmt.print(";105")
    case .Cyan:    fmt.print(";106")
    case .White:   fmt.print(";107")
    }
    fmt.print("")
}

