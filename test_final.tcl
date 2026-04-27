package require TclOO

namespace eval ttk {
    proc frame {path args} {
        proc ::$path {args} { return "" }
        return $path
    }
    proc label {path args} {
        proc ::$path {args} { return "" }
        return $path
    }
    proc style {args} {
        set s [namespace current]::style_mock
        proc ::$s {args} { return "" }
        return $s
    }
}
proc canvas {path args} {
    proc ::$path {args} { return "" }
    return $path
}
proc pack {args} {}
proc bind {args} {}
proc event {args} {}
proc wm {args} {}

# Mock package require Tk
rename package _orig_package
proc package {subcmd args} {
    if {$subcmd eq "require" && [lindex $args 0] eq "Tk"} { return "8.6" }
    return [uplevel 1 [list _orig_package $subcmd {*}$args]]
}

source navrail.tcl

puts "Instantiating NavRail..."
set rail [NavRail .rail]
$rail add_item home "H" "Home"
puts "Selection is: [$rail get_selection]"
puts "Test PASSED"
