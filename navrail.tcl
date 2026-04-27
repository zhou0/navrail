package require Tk
package require TclOO

namespace eval navrail {
    # Material Design 3 Navigation Rail Tokens (Light Theme)
    variable surface "#FEF7FF"
    variable onSurface "#1D1B20"
    variable onSurfaceVariant "#49454F"
    variable secondaryContainer "#E8DEF8"
    variable onSecondaryContainer "#1D192B"

    variable containerWidth 80
    variable iconSize 24
    variable indicatorWidth 56
    variable indicatorHeight 32
}

oo::class create NavRail {
    variable w container items selected

    constructor {path args} {
        set w $path
        set items {}
        set selected ""

        # Create the main container frame
        set container [ttk::frame $w -style NavRail.TFrame -width $navrail::containerWidth]
        pack propagate $container 0

        my SetupStyles

        # Main rail frame for destinations
        set f [ttk::frame $container.f -style NavRail.TFrame]
        pack $f -fill both -expand 1 -pady 10

        # Configure the widget based on args
        if {[llength $args] > 0} {
            $container configure {*}$args
        }

        # Rename the widget command to point to this object
        rename $w ${w}_real
        interp alias {} $w {} [self]
    }

    method SetupStyles {} {
        set s [ttk::style]
        $s configure NavRail.TFrame -background $navrail::surface

        # Label styles for navigation items
        $s configure NavRail.Item.TLabel -background $navrail::surface \
            -foreground $navrail::onSurfaceVariant -font {Helvetica 9} -anchor center
        $s configure NavRail.Active.TLabel -background $navrail::surface \
            -foreground $navrail::onSurface -font {Helvetica 9 bold} -anchor center
    }

    method add_item {id icon text} {
        set itemFrame [ttk::frame [set f [my f]].item_$id -style NavRail.TFrame -cursor hand2]

        # Wrapper for icon and active indicator pill
        set iconWrapper [canvas $itemFrame.wrapper -width $navrail::containerWidth \
            -height 44 -bg $navrail::surface -highlightthickness 0]

        # Placeholder for the icon (text or unicode)
        $iconWrapper create text 40 22 -text $icon -fill $navrail::onSurfaceVariant \
            -font {Helvetica 16} -tags icon

        set label [ttk::label $itemFrame.label -text $text -style NavRail.Item.TLabel]

        pack $iconWrapper -side top -fill x
        pack $label -side top -fill x -pady {0 12}
        pack $itemFrame -side top -fill x

        dict set items $id [list frame $itemFrame wrapper $iconWrapper label $label]

        # Bindings for selection
        foreach sub {frame wrapper label} {
            bind [dict get [dict get $items $id] $sub] <Button-1> [list [self] select $id]
        }

        # Bindings for hover effects
        bind $itemFrame <Enter> [list my OnHover $id 1]
        bind $itemFrame <Leave> [list my OnHover $id 0]

        # Default selection to first item
        if {$selected eq ""} {
            my select $id
        }

        return $itemFrame
    }

    method OnHover {id entering} {
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
        # Unselect previous item
        if {$selected ne ""} {
            set oldData [dict get $items $selected]
            set oldWrapper [dict get $oldData wrapper]
            $oldWrapper delete indicator
            $oldWrapper itemconfigure icon -fill $navrail::onSurfaceVariant
            [dict get $oldData label] configure -style NavRail.Item.TLabel
        }

        set selected $id
        set data [dict get $items $id]
        set wrapper [dict get $data wrapper]

        # Draw the active indicator pill
        set r 16
        set x1 12; set y1 6; set x2 68; set y2 38
        $wrapper create oval $x1 $y1 [expr {$x1+2*$r}] $y2 -fill $navrail::secondaryContainer -outline "" -tags indicator
        $wrapper create oval [expr {$x2-2*$r}] $y1 $x2 $y2 -fill $navrail::secondaryContainer -outline "" -tags indicator
        $wrapper create rectangle [expr {$x1+$r}] $y1 [expr {$x2-$r}] $y2 -fill $navrail::secondaryContainer -outline "" -tags indicator
        $wrapper lower indicator

        # Update colors and fonts
        $wrapper itemconfigure icon -fill $navrail::onSecondaryContainer
        [dict get $data label] configure -style NavRail.Active.TLabel

        # Generate virtual event for the user
        event generate $w <<NavRailSelected>> -data $id
    }

    method get_selection {} {
        return $selected
    }

    method f {} {
        return $container.f
    }

    # Delegate standard widget methods to the underlying frame
    method unknown {method args} {
        return [$container $method {*}$args]
    }
}
