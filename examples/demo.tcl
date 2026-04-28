encoding system utf-8

package require Tk
lappend auto_path ..
package require ttk::m3::navrail

# Root frame
set root [ttk::frame .root]
pack $root -fill both -expand 1

# Optional: Override styles to test extensibility
# ttk::style configure M3NavRail.TFrame -background "#EADDFF"
# ttk::style configure M3NavRail.Indicator.TFrame -background "#21005D"

# Navigation Rail
set rail [ttk::m3::navrail $root.rail -state collapsed]
pack $rail -side left -fill y

# Toggle button
# Corrected: use the style name, not the background color value
set menuBtn [ttk::frame $rail.top -style M3NavRail.TFrame]
set railBg [ttk::style lookup M3NavRail.TFrame -background]
set btn [ttk::label $menuBtn.btn -text "\u2261" -font {Helvetica 18} -background $railBg -cursor hand2]
pack $btn -pady 10 -padx 24 -side left
pack $menuBtn -side top -fill x -before [$rail f]

bind $btn <Button-1> {
    set current [$rail cget -state]
    if {$current eq "collapsed"} {
        $rail configure -state expanded
    } else {
        $rail configure -state collapsed
    }
}

# Add items
$rail add_item home "\u2302" "Home"
$rail add_item search "\u2315" "Search"
$rail add_item settings "\u2699" "Settings"

# Content
set content [ttk::frame $root.content]
pack $content -side right -fill both -expand 1 -padx 20 -pady 20

set title [ttk::label $content.title -text "Home Screen" -font {Helvetica 18 bold}]
pack $title -anchor nw

bind $rail <<NavRailSelected>> {
    set id [%W get_selection]
    .root.content.title configure -text "[string totitle $id] Screen"
}

wm title . "Material Design 3 NavRail Package"
wm geometry . 800x500
