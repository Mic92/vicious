Vicious
=======
Vicious is a modular widget library for window managers, but mostly
catering to users of the *awesome* window manager. It was derived from
the old *Wicked* widget library, and has some of the old *Wicked* widget
types, a few of them rewritten, and a good number of new ones:

* https://github.com/vicious-widgets/vicious

Vicious widget types are a framework for creating your own
widgets. Vicious contains modules that gather data about your system,
and a few *awesome* helper functions that make it easier to register
timers, suspend widgets and so on. Vicious doesn't depend on any third party
Lua libraries, but may depend on additional system utilities (see widget
description).

## Usage

When provided by an operating system package, or installed from source
into the Lua library path Vicious can be used as a regular Lua
library, to be used stand-alone or to feed widgets of any window
manager (e.g. Ion, WMII). It is compatible with both Lua v5.1 and v5.2.

```lua
> widgets = require("vicious.widgets.init")
> print(widgets.volume(nil, "Master")[1])
100
```

## Usage within Awesome

To use Vicious with Awesome, install the package from your operating
system provider, or download the source code and move it to your
awesome configuration directory in `$XDG_CONFIG_HOME` (usually `~/.config`):

```bash
$ mv vicious $XDG_CONFIG_HOME/awesome/
```

Vicious will only load modules for widget types you intend to use in
your awesome configuration, to avoid having useless modules sitting in
your memory.

Then add the following to the top of your `rc.lua`:

```lua
local vicious = require("vicious")
```

Once you create a widget (a textbox, graph or a progressbar) call
`vicious.register()` to register it with Vicious:

    vicious.register(widget, wtype, format, interval, warg)

### widget

*Awesome* widget created with `widget()` or `awful.widget()` (in case of a
graph or a progressbar).

### wtype

Type: Vicious widget or `function`:

* Vicious widget type: any of the available (default, or custom)
  [widget type provided by Vicious](#widgets).
* function: custom function from your own *Awesome* configuration can be
  registered as widget types (see [Custom widget types](#custom-widget)).

### format

Type: `string` or `function`:

* string: `$1`, `$2`, `$3`, etc. will be replaced by their respective value
  returned by the widget type. In case the widget type returns a table with
  string keys, use: `${key}`.
* `function(widget, args)` can be used to manipulate data returned by the
  widget type (see [Format functions](#format-func)).

### interval

Number of seconds between updates of the widget (default: 2). Read section
[Power and Caching](#power) for more information.

### warg

Some widget types require an argument to be passed, for example the battery ID.

## Other functions

### Unregister a widget

    vicious.unregister(widget, keep)

If `keep == true`, `widget` will be suspended and wait for activation.

### Suspend all widgets

    vicious.suspend()

See [example automation script](http://sysphere.org/~anrxc/local/sources/lmt-vicious.sh)
for the "laptop-mode-tools" start-stop module.

### Restart suspended widgets

    vicious.activate(widget)

If `widget` is provided only that widget will be activated.

### Enable caching of a widget type

    vicious.cache(wtype)

Enable caching of values returned by a widget type.

### Force update of widgets

    vicious.force(wtable)

`wtable` is a table of one or more widgets to be updated.

### Get data from a widget

    vicious.call(wtype, format, warg)

Fetch data from `widget` to use it outside from the wibox
([example](#call-example)).

## <a name="widgets"></a>Widget types

Widget types consist of worker functions that take two arguments `format` and
`warg` (in that order), which were previously passed to `vicious.register`, and
return a table of values to be formatted by `format`.

### vicious.widgets.bat

Provides state, charge, and remaining time for a requested battery.

Supported platforms: GNU/Linux (require `sysfs`), FreeBSD (require `acpiconf`).

* `warg` (from now on will be called *argument*):
    * On GNU/Linux: battery ID, e.g. `"BAT0"`
    * On FreeBSD (optional): battery ID, e.g. `"batt"` or `"0"`
* Returns an array (integer-indexed table) consisting of:
    * `$1`: State of requested battery
    * `$2`: Charge level in percent
    * `$3`: Remaining (charging or discharging) time
    * `$4`: Wear level in percent
    * `$5`: Current (dis)charge rate in Watt

### vicious.widgets.cpu

Provides CPU usage for all available CPUs/cores.

Supported platforms: GNU/Linux, FreeBSD.

* Argument: None
* Returns an array containing:
    * `$1`: usage of all CPUs/cores
    * `$2`, `$3`, etc. are respectively the usage of 1st, 2nd, etc. CPU/core

### vicious.widgets.cpufreq

Provides freq, voltage and governor info for a requested CPU.

Supported platforms: GNU/Linux, FreeBSD.

* Argument: CPU ID, e.g. `"cpu0"` on GNU/Linux, `"0"` on FreeBSD
* Returns an array containing:
    * `$1`: Frequency in MHz
    * `$2`: Frequency in GHz
    * `$3`: Voltage in mV
    * `$4`: Voltage in V
    * `$5`: Governor state
    * On FreeBSD: only the first two are supported
      (other values will always be `"N/A"`)

### vicious.widgets.cpuinf

Provides speed and cache information for all available CPUs/cores.

Supported platforms: GNU/Linux.

* Argument: None
* Returns a table with string keys, using CPU ID as a base, e.g. `{cpu0 mhz}`,
  `{cpu0 ghz}`, `{cpu0 kb}`, `{cpu0 mb}`, `{cpu1 mhz}`, etc.

### vicious.widgets.date

Provides access to Lua's `os.date`, with optional settings for time format and
time offset.

Supported platforms: platform independent.

* `format` (optional): a [strftime(3)](https://linux.die.net/man/3/strftime)
  format specification string (format functions are not supported). If not
  provided, use the prefered representation for the current locale.
* Argument (optional): time offset in seconds, e.g. for different a time zone.
  If not provided, current time is used.
* Returns the output of `os.date` formatted by `format` *string*.

### vicious.widgets.dio

Provides I/O statistics for all available storage devices.

Supported platforms: GNU/Linux.

* Argument: None
* Returns a table with string keys: `{sda total_s}`, `{sda total_kb}`,
  `{sda total_mb}`, `{sda read_s}`, `{sda read_kb}`, `{sda read_mb}`,
  `{sda write_s}`, `{sda write_kb}`, `{sda write_mb}`, `{sda iotime_ms}`,
  `{sda iotime_s}`, `{sdb1 total_s}`, etc.

### vicious.widget.fanspeed

Provides fanspeed information for specified fan.

Supported platforms: FreeBSD.

* Argument: full `sysctl` string to entry, e.g. `"dev.acpi_ibm.0.fan_speed"`
* Returns speed of specified fan in RPM, `-1` on error (probably wrong string)

### vicious.widgets.fs

Provides usage of disk space.

Supported platforms: platform independent.

* Argument (optional): if true includes remote filesystems, otherwise fallback
  to default, where only local filesystems are included
* Returns a table with string keys, using mount points as a base, e.g.
  `{/ size_mb}`, `{/ size_gb}`, `{/ used_mb}`, `{/ used_gb}`, `{/ used_p}`,
  `{/ avail_mb}`, `{/ avail_gb}`, `{/ avail_p}`, `{/home size_mb}`, etc.

### vicious.widgets.gmail

Provides count of new and subject of last e-mail on Gmail.

Supported platform: platform independent, requiring `curl`.

This widget expects login information in your `~/.netrc` file, e.g.
`machine mail.google.com login user password pass` and you have to disable
[two step verification](https://support.google.com/accounts/answer/1064203).
[Allow access for less secure apps](https://www.google.com/settings/security/lesssecureapps)
afterwards. BE AWARE THAT MAKING THESE SETTINGS IS A SECURITY RISK!

* Arguments (optional): either a number or a table
    * If it is a number, subject will be truncated.
    * If it is a table whose first field is the maximum length and second field
      is the widget name (e.g. *gmailwidget*), scrolling will be used.
* Returns a table with string keys: `{count}` and `{subject}`

### vicious.widgets.hddtemp

Provides hard drive temperatures using the hddtemp daemon.

Supported platforms: GNU/Linux, requiring `hddtemp` and `curl`.

* Argument (optional): `hddtemp` listening port (default: 7634)
* Returns a table with string keys, using hard drives as a base, e.g.
  `{/dev/sda}` and `{/dev/sdc}`.

### vicious.widgets.mbox

Provides the subject of last e-mail in a mbox file.

Supported platforms: platform independent.

* Argument: either a string or a table:
    * A string representing the full path to the mbox, or
    * Table of the form `{path, maximum_length[, widget_name]}`.
      If the widget name is provided, scrolling will be used.
    * Note: the path will be escaped so special variables like `~` will not
      work, use `os.getenv` instead to access environment variables.
* Returns an array whose first value is the subject of the last e-mail.

**vicious.widgets.mboxc**

Provides the count of total, old and new messages in mbox files.

Supported platforms: platform independent.

* Argument: a table with full paths to mbox files.
* Returns an array containing:
    * `$1`: Total number of messages
    * `$2`: Number of old messages
    * `$3`: Number of new messages

### vicious.widgets.mdir

Provides the number of unread messages in Maildir structures/directories.

Supported platforms: platform independent.

* Argument: a table with full paths to Maildir structures.
* Returns an array containing:
    * `$1`: Number of new messages
    * `$2`: Number of *old* messages lacking the *Seen* flag

### vicious.widgets.mem

Provides RAM and Swap usage statistics.

Supported platforms: GNU/Linux, FreeBSD.

* Argument: None
* Returns (per platform):
    * GNU/Linux: an array consisting of:
        * `$1`: Memory usage in percent
        * `$2`: Memory usage in MB
        * `$3`: Total system memory in MB
        * `$4`: Free memory in MB
        * `$5`: Swap usage in percent
        * `$6`: Swap usage in MB
        * `$7`: Total system swap in MB
        * `$8`: Free swap in MB
        * `$9`: Memory usage with buffers and cache, in MB
    * FreeBSD: an array including:
        * `$1`: Memory usage in percent
        * `$2`: Memory usage in MB
        * `$3`: Total system memory in MB
        * `$4`: Free memory in MB
        * `$5`: Swap usage in percent
        * `$6`: Swap usage in MB
        * `$7`: Total system swap in MB
        * `$8`: Free swap in MB
        * `$9`: Wired memory in percent
        * `$10`: Wired memory in MB
        * `$11`: Unfreeable memory (basically active+inactive+wired) in percent
        * `$12`: Unfreeable memory in MB

**vicious.widgets.mpd**

Provides Music Player Daemon information.
Supported platforms: platform independent (required tools: `curl`).

* Arguments:
  * Takes a table as an argument, 1st field should be the password (or nil),
    2nd the hostname (or nil) and 3rd port (or nil) - if no argument is
    provided connection attempt will be made to localhost port 6600 with no
    password
* Returns:
  * Returns a table with string keys: `{volume}`, `{state}`, `{Artist}`, `{Title}`,
    `{Album}`, `{Genre}` and optionally `{Name}` and `{file}`

**vicious.widgets.net**

Provides state and usage statistics of network interfaces.
Supported platforms: GNU/Linux, FreeBSD.

* Arguments (per platform):
  * GNU/Linux: none
  * FreeBSD: desired interface, e.g. `wlan0`
* Returns (per platform):
  * GNU/Linux: returns a table with string keys, using net interfaces as a base:
    `{eth0 carrier}`, `{eth0 rx_b}`, `{eth0 tx_b}`, `{eth0 rx_kb}`, `{eth0 tx_kb}`,
    `{eth0 rx_mb}`, `{eth0 tx_mb}`, `{eth0 rx_gb}`, `{eth0 tx_gb}`, `{eth0 down_b}`,
    `{eth0 up_b}`, `{eth0 down_kb}`, `{eth0 up_kb}`, `{eth0 down_mb}`,
    `{eth0 up_mb}`, `{eth0 down_gb}`, `{eth0 up_gb}`, `{eth1 rx_b}` etc.
  * FreeBSD: returns a table with string keys:
    `{carrier}`, `{rx_b}`, `{tx_b}`, `{rx_kb}`, `{tx_kb}`,
    `{rx_mb}`, `{tx_mb}`, `{rx_gb}`, `{tx_gb}`, `{down_b}`,
    `{up_b}`, `{down_kb}`, `{up_kb}`, `{down_mb}`,
    `{up_mb}`, `{down_gb}`, `{up_gb}`

**vicious.widgets.org**

Provides agenda statistics for Emacs org-mode.
Supported platforms: platform independent.

* Arguments:
  * Takes a table with full paths to agenda files, that will be parsed, as an
    argument
* Returns:
  * Returns 1st value as count of tasks you forgot to do, 2nd as count of
    tasks for today, 3rd as count of tasks for the next 3 days and 4th as
    count of tasks to do in the week

**vicious.widgets.os**

Provides operating system information.
Supported platforms: platform independent.

* Arguments:
  * None
* Returns:
  * Returns 1st value as the operating system in use, 2nd as the release
    version, 3rd as your username, 4th the hostname, 5th as available system
    entropy and 6th value as available entropy in percent

**vicious.widgets.pkg**

Provides number of pending updates on UNIX systems. Be aware that some package
managers need to update their local databases (as root) before showing the
correct number of updates.
Supported platforms: platform independent.

* Arguments:
  * Takes the GNU/Linux or BSD distribution name as an argument, e.g. `"Arch"`,
    `"Arch C"`, `"Arch S"`, `"Debian"`, `"Ubuntu"`, `"Fedora"`, `"FreeBSD"`,
    `"Mandriva"`
* Returns:
  * Returns 1st value as the count of available updates, 2nd as the list of
    packages to update

**vicious.widgets.raid**

Provides state information for a requested RAID array.
Supported platforms: GNU/Linux.

* Arguments:
  * Takes the RAID array ID as an argument
* Returns:
  * Returns 1st value as the number of assigned, and 2nd as active, devices in
    the array

**vicious.widgets.thermal**

Provides temperature levels of several thermal zones.
Supported platforms: GNU/Linux, FreeBSD.

* Arguments (per platform):
  * GNU/Linux: takes the thermal zone as an argument, e.g. `"thermal_zone0"`, or a
    table with 1st field as thermal zone, 2nd as data source - available data
    sources are `"proc"`, `"core"` and `"sys"` (which is the default when only
    the zone is provided) and 3rd optional argument as a temperature input
    file to read
  * FreeBSD: takes the full sysctl path to a thermal zone as an argument, e.g.
    `"hw.acpi.thermal.tz0.temperature"`, or a table with multiple paths
* Returns:
  * GNU/Linux: returns 1st value as temperature of requested thermal zone
  * FreeBSD: returns a table with a entry for every input thermal zone

**vicious.widgets.uptime**

Provides system uptime and load information.
Supported platforms: GNU/Linux, FreeBSD.

* Arguments:
  * None
* Returns:
  * Returns 1st value as uptime in days, 2nd as uptime in hours, 3rd as uptime
    in minutes, 4th as load average for past 1 minute, 5th for 5 minutes and
    6th for 15 minutes

**vicious.widgets.volume**

Provides volume levels and state of requested mixers.
Supported platforms: GNU/Linux (required tool: amixer), FreeBSD.

* Arguments (per platform):
  * GNU/Linux: takes either a single argument containing the ALSA mixer control as
    an argument, e.g. `"Master"`, or a table passed as command line arguments
    to [amixer(1)](https://linux.die.net/man/1/amixer),
    i.e `{"PCM", "-c", "0"}` or `{"Master", "-D", "pulse"}`.
  * FreeBSD: takes the mixer control as an argument, e.g. `"vol"`
* Returns:
  * GNU/Linux: returns 1st value as the volume level and 2nd as the mute state of
    the requested control
  * FreeBSD: returns 1st value as the volume level of the left channel, 2nd as
    the volume level of the right channel and 3rd as the mute state of the
    desired control

**vicious.widgets.weather**

Provides weather information for a requested station.
Supported platforms: platform independent (required tools: `curl`).

* Arguments:
  * Takes the ICAO station code as an argument, e.g. `"LDRI"`
* Returns:
  * Returns a table with string keys: `{city}`, `{wind}`, `{windmph}`,
  `{windkmh}`, `{sky}`, `{weather}`, `{tempf}`, `{tempc}`, `{humid}`,
  `{dewf}`, `{dewc}` and `{press}`

**vicious.widgets.wifi**

Provides wireless information for a requested interface.
Supported platforms: GNU/Linux.

* Arguments:
  * Takes the network interface as an argument, e.g. `"wlan0"`
* Returns:
  * Returns a table with string keys: `{ssid}`, `{mode}`, `{chan}`, `{rate}`,
    `{link}`, `{linp}` (link quality in percent) and `{sign}` (signal level)

**vicious.widgets.wifiiw**

Provides wireless information for a requested interface (similar to
vicious.widgets.wifi, but uses iw instead of iwconfig).
Supported platforms: GNU/Linux.

* Arguments:
  * Takes the network interface as an argument, e.g. `"wlan0"`
* Returns:
  * Returns a table with string keys: `{ssid}`, `{mode}`, `{chan}`, `{rate}`,
    `{freq}`, `{linp}` (link quality in percent), `{txpw}` (tx power) and
    `{sign}` (signal level)


## <a name="custom-widget"></a>Custom widget types

Use any of the existing widget types as a starting point for your
own. Write a quick worker function that does the work and plug it
in. How data will be formatted, will it be red or blue, should be
defined in rc.lua (or somewhere else, outside the actual module).

Before writing a widget type you should check if there is already one in the
contrib directory of Vicious. The contrib directory contains extra widgets you
can use. Some are for less common hardware, and other were contributed by
Vicious users. Most of the contrib widgets are obsolete. Contrib widgets will
not be imported by init unless you explicitly enable it, or load them in your
rc.lua.

Some users would like to avoid writing new modules. For them Vicious
kept the old Wicked functionality, possibility to register their own
functions as widget types. By providing them as the second argument to
vicious.register. Your function can accept "format" and "warg"
arguments, just like workers.


## <a name="power"></a>Power and Caching

When a lot of widgets are in use they, and awesome, can generate a lot
of wake-ups and also be very expensive for system resources. This is
especially important when running on battery power. It was a big
problem with awesome v2 and widgets that used shell scripts to gather
data, and with widget libraries written in languages like Ruby.

Lua is an extremely fast and efficient programming language, and
Vicious takes advantage of that. But suspending Vicious widgets is one
way to prevent them from draining your battery, despite that.

Update intervals also play a big role, and you can save a lot of power
with a smart approach. Don't use intervals like: 5, 10, 30, 60... to
avoid harmonics. If you take the 60-second mark as an example, all of
your widgets would be executed at that point. Instead think about
using only prime numbers, in that case you will have only a few
widgets executed at any given time interval. When choosing intervals
also consider what a widget actually does. Some widget types read
files that reside in memory, others call external utilities and some,
like the mbox widget, read big files.

Vicious can also cache values returned by widget types. Caching
enables you to have multiple widgets using the same widget type. With
caching its worker function gets executed only once - which is also
great for saving power.

* Some widget types keep internal data and if you call one multiple times
  without caching, the widget that executes it first would modify stored
  values. This can lead to problems and give you inconsistent data. Remember
  it for widget types like CPU and Network usage, which compare the old set of
  data with the new one to calculate current usage.

* Widget types that require a widget argument to be passed should be handled
  carefully. If you are requesting information for different devices then
  caching should not be used, because you could get inconsistent data.


## Security

At the moment only one widget type (Gmail) requires auth. information
in order to get to the data. In the future there could be more, and
you should give some thought to the issue of protecting your data. The
Gmail widget type by default stores login information in the ~/.netrc
file, and you are advised to make sure that file is only readable by
the owner. Other than that we can not force all users to conform to
one standard, one way of keeping it secure, like in some keyring.

First let's clear why we simply don't encrypt the login information
and store it in ciphertext. By exposing the algorithm anyone can
reverse the encryption steps. Some claim even that's better than
plaintext but it's just security trough obscurity.

Here are some ideas actually worth your time. Users that have KDE (or
parts of it) installed could store their login information into the
Kwallet service and request it via DBus from the widget type. It can
be done with tools like "dbus-send" and "qdbus". The Gnome keyring
should support the same, so those with parts of Gnome installed could
use that keyring.

Users of GnuPG (and its agent) could consider encrypting the netrc
file with their GPG key. Trough the GPG Passphrase Agent they could
then decrypt the file transparently while their session is active.

## Usage examples

Start with a simple widget, like `date`. Then build your setup from
there, one widget at a time. Also remember that besides creating and
registering widgets you have to add them to a `wibox` (statusbar) in
order to actually display them.

**Date widget**

```Lua
    datewidget = wibox.widget.textbox()
    vicious.register(datewidget, vicious.widgets.date, "%b %d, %R")
```

updated every 2 seconds (the default interval), uses standard
date sequences as the format string

**Memory widget**

```Lua
    memwidget = wibox.widget.textbox()
    vicious.cache(vicious.widgets.mem)
    vicious.register(memwidget, vicious.widgets.mem, "$1 ($2MB/$3MB)", 13)
```

updated every 13 seconds, appends "MB" to 2nd and 3rd returned
values and enables caching of this widget type

**HDD temperature widget**

```Lua
    hddtempwidget = wibox.widget.textbox()
    vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda} °C", 19)
```

updated every 19 seconds, requests the temperature level of the
{/dev/sda} key/disk and appends "°C" to the returned value, does
not provide the port argument so default port is used

**Mbox widget**

```Lua
    mboxwidget = wibox.widget.textbox()
    vicious.register(mboxwidget, vicious.widgets.mbox, "$1", 5, "/home/user/mail/Inbox")
```
updated every 5 seconds, provides full path to the mbox as an
argument

**Battery widget**

```lua
    batwidget = wibox.widget.progressbar()

    -- Create wibox with batwidget
    batbox = wibox.widget {
      {
        max_value     = 1,
        widget        = batwidget,
        border_width  = 0.5,
        border_color  = "#000000",
        color         = {
          type = "linear",
          from = { 0, 0 },
          to = { 0, 30 },
          stops = {
            { 0, "#AECF96" },
            { 1, "#FF5656" }
          }
       }
      },
      forced_height = 10,
      forced_width  = 8,
      direction     = 'east',
      color         = beautiful.fg_widget,
      layout        = wibox.container.rotate,
    }
    batbox = wibox.layout.margin(batbox, 1, 1, 3, 3)
    -- Register battery widget
    vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT0")
```
updated every 61 seconds, requests the current battery charge
level and displays a progressbar, provides "BAT0" battery ID as an
argument

**CPU usage widget**

```Lua
    cpuwidget = awful.widget.graph()
    cpuwidget:set_width(50)
    cpuwidget:set_background_color("#494B4F")
    cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 50, 0 },
      stops = { { 0, "#FF5656" }, { 0.5, "#88A175" }, { 1, "#AECF96" }}})
    vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 3)
```
updated every 3 seconds, feeds the graph with total usage
percentage of all CPUs/cores


## <a name="format-func"></a>Format functions

You can use a function instead of a string as the format parameter.
Then you are able to check the value returned by the widget type and
change it or perform some action. You can change the color of the
battery widget when it goes below a certain point, hide widgets when
they return a certain value or maybe use string.format for padding.

Do not confuse this with just coloring the widget, in those cases standard
Pango markup can be inserted into the format string.

The format function will get the widget as its first argument, table
with the values otherwise inserted into the format string as its
second argument, and will return the text/data to be used for the
widget.

### Examples

#### Hide mpd widget when no song is playing

```lua
mpdwidget = wibox.widget.textbox()
vicious.register(mpdwidget, vicious.widgets.mpd,
                 function (widget, args)
                     if args["{state}"] == "Stop" then
                         return ""
                     else
                         return '<span color="white">MPD:</span> '..
                                args["{Artist}"]..' - '.. args["{Title}"]
                     end
                 end)
```

#### Use string.format for padding

```lua
uptimewidget = wibox.widget.textbox()
vicious.register(uptimewidget, vicious.widgets.uptime,
                 function (widget, args)
                     return string.format("Uptime: %2dd %02d:%02d ",
                                          args[1], args[2], args[3])
                 end, 61)
```

When it comes to padding it is also useful to mention how a widget can
be configured to have a fixed width. You can set a fixed width on your
textbox widgets by changing their .width field (by default width is
automatically adapted to text width). The following code forces a fixed width
of 50px to the uptime widget, and aligns its text to the right:

```lua
uptimewidget = wibox.widget.textbox()
uptimewidget.width, uptimewidget.align = 50, "right"
vicious.register(uptimewidget, vicious.widgets.uptime, "$1 $2:$3", 61)
```

#### Stacked graph

Stacked graphs (aka multigraphs) are not handled by Vicious at the moment, as
it's hard to pass on color index arguments elegantly. But they are not
unusable, far from it.

```lua
ctext = wibox.widget.textbox()
cgraph = awful.widget.graph()
cgraph:set_width(100):set_height(20)
cgraph:set_stack(true):set_max_value(100)
cgraph:set_background_color("#494B4F")
cgraph:set_stack_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(ctext, vicious.widgets.cpu,
                 function (widget, args)
                     cgraph:add_value(args[2], 1) -- Core 1, color 1
                     cgraph:add_value(args[3], 2) -- Core 2, color 2
                     cgraph:add_value(args[4], 3) -- Core 3, color 3
                 end, 3)
```

The snipet above enables graph stacking/multigraph and plots usage of all three
CPU cores on a single graph. The textbox `ctext` is just an empty placeholder.

#### Substitute widget types' symbols

If you are not happy with default symbols used in volume, battery, cpufreq and
other widget types, use your own symbols without any need to modify modules.
The following example uses a custom table map to modify symbols representing
the mixer state: on or off/mute.

```lua
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume,
                 function(widget, args)
                     local label = { ["♫"] = "O", ["♩"] = "M" }
                     return "Volume: " .. args[1] .. "% State: " .. label[args[2]]
                 end, 2, "PCM")
```

#### <a name="call-example"></a>Get data from the widget

`vicious.call` could be useful for naughty notification and scripts:

```lua
mybattery = wibox.widget.textbox()
vicious.register(mybattery, vicious.widgets.bat, "$2%", 17, "0")
mybattery:buttons(awful.util.table.join(
    awful.button({}, 1,
                 function()
                     naughty.notify({
                         title = "Battery indicator",
                         text = vicious.call(vicious.widgets.bat,
                                             "Remaining time: $3", "0")
                     })
                 end)
))
```

Format functions can be used as well:

```lua
mybattery:buttons(awful.util.table.join(
    awful.button({}, 1,
                 function()
                     naughty.notify({
                         title = "Battery indicator",
                         text = vicious.call(
                             vicious.widgets.bat,
                             function(widget, args)
                                 return ("%s: %10sh\n%s: %14d%%\n%s: %12dW"):format(
                                     "Remaining time", args[3],
                                     "Wear level", args[4],
                                     "Present rate", args[5])
                             end, "0")})
                 end)
))
```

## See also

* Manual pages: [awesome(1)](https://awesomewm.org/doc/manpages/awesome),
  [awesomerc(5)](https://awesomewm.org/doc/manpages/awesomerc.5.html)
* [Awesome declarative layout system](https://awesomewm.org/apidoc/documentation/03-declarative-layout.md.html)
* [Example *awesome* configuration](http://git.sysphere.org/awesome-configs/)

## Authors

Wicked was written by:

* Lucas de Vries           \<lucas glacicle.com\>

Vicious was originally written by:

* Adrian C. (anrxc)        \<anrxc sysphere.org\>

Current maintainer:

* Jörg Thalheim (Mic92)    \<joerg thalheim.io\>

Maintainer of the Freebsd Port:

* [@mutlusun](https://github.com/mutlusun)

Vicious major contributors:

* Benedikt Sauer           \<filmor gmail.com\>
* Greg D.                  \<jabbas jabbas.pl\>
* Henning Glawe            \<glaweh debian.org\>
* Rémy C.                  \<shikamaru mandriva.org\>
* Hiltjo Posthuma          \<hiltjo codemadness.org\>
* Hagen Schink             \<troja84 googlemail.com\>
* Arvydas Sidorenko        \<asido4 gmail.com\>
* Dodo The Last            <dodo.the.last gmail.com>
* ...
* Consult git log for a complete list of contributors
