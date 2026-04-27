package require Tk
package require TclOO

namespace eval navrail {
    # Material Design 3 Navigation Rail Tokens (Light Theme)
    variable surface "#FEF7FF"
    variable onSurface "#1D1B20"
    variable onSurfaceVariant "#49454F"
    variable secondaryContainer "#E8DEF8"
    variable onSecondaryContainer "#1D192B"

    variable collapsedWidth 80
    variable expandedWidth 240
    variable iconSize 24
    variable indicatorWidth 56
    variable indicatorHeight 32
}

# The actual implementation class
oo::class create navrail_class {
    variable w container items selected state

    constructor {path args} {
        set w $path
        set items {}
        set selected ""
        set state "collapsed"

        # 1. Create the real frame using the requested path
        ttk::frame $w -style NavRail.TFrame -width $navrail::collapsedWidth
        pack propagate $w 0

        # 2. Rename the frame command
        set container ${w}_widget
        rename $w $container

        my SetupStyles

        # 3. Create children
        set f [ttk::frame $w.f -style NavRail.TFrame]
        pack $f -fill both -expand 1 -pady 10

        # Configure based on args
        if {[llength $args] > 0} {
            my configure {*}$args
        }
    }

    method SetupStyles {} {
        ttk::style configure NavRail.TFrame -background $navrail::surface
        ttk::style configure NavRail.Item.TFrame -background $navrail::surface

        # Label styles
        ttk::style configure NavRail.Item.TLabel -background $navrail::surface \
            -foreground $navrail::onSurfaceVariant -font {Helvetica 9} -anchor center
        ttk::style configure NavRail.Active.TLabel -background $navrail::surface \
            -foreground $navrail::onSurface -font {Helvetica 9 bold} -anchor center

        # Expanded label styles
        ttk::style configure NavRail.Expanded.TLabel -background $navrail::surface \
            -foreground $navrail::onSurfaceVariant -font {Helvetica 10} -anchor w
        ttk::style configure NavRail.ExpandedActive.TLabel -background $navrail::surface \
            -foreground $navrail::onSurface -font {Helvetica 10 bold} -anchor w
    }

    method add_item {id icon text} {
        set itemFrame [ttk::frame [my f].item_$id -style NavRail.TFrame -cursor hand2]

        # Wrapper for icon and indicator
        set iconWrapper [canvas $itemFrame.wrapper -width $navrail::collapsedWidth \
            -height 44 -bg $navrail::surface -highlightthickness 0]

        $iconWrapper create text 40 22 -text $icon -fill $navrail::onSurfaceVariant \
            -font {Helvetica 16} -tags icon

        set label [ttk::label $itemFrame.label -text $text -style NavRail.Item.TLabel]

        dict set items $id [list frame $itemFrame wrapper $iconWrapper label $label icon_char $icon text $text]

        # Initial layout
        my update_item_layout $id

        pack $itemFrame -side top -fill x

        # Bindings
        foreach sub {frame wrapper label} {
            bind [dict get [dict get $items $id] $sub] <Button-1> [list $w select $id]
        }
        bind $itemFrame <Enter> [list $w on_hover $id 1]
        bind $itemFrame <Leave> [list $w on_hover $id 0]

        if {$selected eq ""} {
            my select $id
        }

        return $itemFrame
    }

    method update_item_layout {id} {
        set data [dict get $items $id]
        set frame [dict get $data frame]
        set wrapper [dict get $data wrapper]
        set label [dict get $data label]

        pack forget $wrapper
        pack forget $label

        if {$state eq "collapsed"} {
            $wrapper configure -width $navrail::collapsedWidth
            $wrapper coords icon 40 22
            $label configure -style [expr {$id eq $selected ? "NavRail.Active.TLabel" : "NavRail.Item.TLabel"}]
            pack $wrapper -side top -fill x
            pack $label -side top -fill x -pady {0 12}
        } else {
            $wrapper configure -width 72
            $wrapper coords icon 36 22
            $label configure -style [expr {$id eq $selected ? "NavRail.ExpandedActive.TLabel" : "NavRail.Expanded.TLabel"}]
            pack $wrapper -side left
            pack $label -side left -fill both -expand 1 -padx {0 16}
        }
    }

    method update_layout {} {
        $container configure -width [expr {$state eq "collapsed" ? $navrail::collapsedWidth : $navrail::expandedWidth}]
        foreach id [dict keys $items] {
            my update_item_layout $id
        }
        # Redraw indicator for selected item
        my select $selected
    }

    method configure {args} {
        if {[llength $args] == 0} {
            return [$container configure]
        }
        if {[llength $args] == 1} {
            return [$container configure [lindex $args 0]]
        }

        foreach {opt val} $args {
            switch -- $opt {
                -state {
                    if {$val in {collapsed expanded}} {
                        set state $val
                        my update_layout
                    }
                }
                default {
                    $container configure $opt $val
                }
            }
        }
    }

    method on_hover {id entering} {
        set data [dict get $items $id]
        set wrapper [dict get $data wrapper]
        if {$id ne $selected} {
            if {$entering} {
                $wrapper configure -bg "#f0f0f0"
            } else {
                $wrapper configure -bg $navrail::surface
            }
        }
    }

    method select {id} {
        if {$id eq ""} return

        # Unselect previous
        if {$selected ne "" && [dict exists $items $selected]} {
            set oldData [dict get $items $selected]
            set oldWrapper [dict get $oldData wrapper]
            $oldWrapper delete indicator
            $oldWrapper itemconfigure icon -fill $navrail::onSurfaceVariant
            [dict get $oldData label] configure -style [expr {$state eq "collapsed" ? "NavRail.Item.TLabel" : "NavRail.Expanded.TLabel"}]
        }

        set selected $id
        set data [dict get $items $id]
        set wrapper [dict get $data wrapper]

        # Draw indicator
        set r 16
        if {$state eq "collapsed"} {
            set x1 12; set y1 6; set x2 68; set y2 38
        } else {
            set x1 8; set y1 6; set x2 64; set y2 38
        }

        $wrapper delete indicator
        $wrapper create oval $x1 $y1 [expr {$x1+2*$r}] $y2 -fill $navrail::secondaryContainer -outline "" -tags indicator
        $wrapper create oval [expr {$x2-2*$r}] $y1 $x2 $y2 -fill $navrail::secondaryContainer -outline "" -tags indicator
        $wrapper create rectangle [expr {$x1+$r}] $y1 [expr {$x2-$r}] $y2 -fill $navrail::secondaryContainer -outline "" -tags indicator
        $wrapper lower indicator

        $wrapper itemconfigure icon -fill $navrail::onSecondaryContainer
        [dict get $data label] configure -style [expr {$state eq "collapsed" ? "NavRail.Active.TLabel" : "NavRail.ExpandedActive.TLabel"}]

        event generate $w <<NavRailSelected>> -data $id
    }

    method get_selection {} {
        return $selected
    }

    method f {} {
        return $w.f
    }

    method unknown {method args} {
        return [$container $method {*}$args]
    }
}

proc NavRail {path args} {
    package require Tk
    set obj [navrail_class create ${path}_obj $path {*}$args]
    interp alias {} $path {} $obj
    return $path
}
