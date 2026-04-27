package require Tk
lappend auto_path .
source navrail.tcl

# Root frame
set root [ttk::frame .root]
pack $root -fill both -expand 1

# Instantiate NavRail
set rail [NavRail $root.rail]
pack $rail -side left -fill y

# Add items
$rail add_item home "🏠" "Home"
$rail add_item search "🔍" "Search"
$rail add_item settings "⚙️" "Settings"

# Content area
set content [ttk::frame $root.content]
pack $content -side right -fill both -expand 1 -padx 20 -pady 20

set title [ttk::label $content.title -text "Home Screen" -font {Helvetica 18 bold}]
pack $title -anchor nw

# Handle selection
bind $rail <<NavRailSelected>> {
    set id [%W get_selection]
    switch $id {
        home { .root.content.title configure -text "Home Screen" }
        search { .root.content.title configure -text "Search Screen" }
        settings { .root.content.title configure -text "Settings Screen" }
    }
}

wm title . "Material Design 3 Navigation Rail Demo"
wm geometry . 600x400
