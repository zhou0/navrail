# ttk::m3::navrail

A Material Design 3 Navigation Rail widget for Tcl/Tk.

## Features
- **Responsive**: Supports `collapsed` (80px) and `expanded` (240px) states.
- **Themed**: Fully customizable via `ttk::style`.
- **Standard API**: Supports `cget`, `configure`, and `add_item`.

## Usage
```tcl
package require ttk::m3::navrail
set rail [ttk::m3::navrail .rail -state collapsed]
$rail add_item home "🏠" "Home"
pack $rail -side left -fill y
```

## Methods
- `add_item id icon text`: Adds a destination.
- `select id`: Activates an item.
- `get_selection`: Returns active ID.

## Events
- `<<NavRailSelected>>`: Triggered on item selection.

## Installation
Add the package directory to your `auto_path`.
