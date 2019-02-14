# XEnv
#### A set of launchers, controls, and status bars for use with a MacOS tiling window manager, mainly chunkwm.

This is designed for use with chunkwm (or maybe other window managers) with padding around your screen edges, and dock and menu bar set to auto-hide. It gives you a launcher, CPU usage graphs, quick controls for chunkwm, and status for audio, wifi, etc.

I created this for my own use, and there is a lot of hard coded sizes, control layouts, etc.

![Screenshot](https://github.com/bensinc/XEnv/raw/master/screenshot.png "Screenshot")

#### Todos:

* Detect screen size changes and automatically reset the view positions
* Move all of the "widgets" into their own components, and create a way to add any widget to any bar via a configuration file.

#### Building

Make sure to do a pod install first, then setup your .xenvrc file and build the Xcode project normally.

#### Launcher configuration

Right now everything is hard coded except for the launcher items. Create a .xenvrc file in your home directory, based on the sample-xenvrc file in the repository.

The .xenvrc file should contain a full path to a .app file, one per line. It will try to pull the icon right from the .app file, but that doesn't always work. If not, you can add a | and then a path to a custom icon.

You can also add new-iterm as an app path, which runs some Applescript to tell the running iterm instance to open a new window.

#### Usage

You'll want to setup your chunkwm config to add padding around the top, bottom, and sides to line up with the XEnv tools. You may also want to right click on the XEnv dock icon and set it to show on all desktops.

The control bar has the following buttons, from left to right:

![Control Buttons](https://github.com/bensinc/XEnv/raw/master/controls.png "Control Buttons")

* Sleep the computer
* Restart chunkwm (I have to do this when I go from my external to internal display, so I made it easy)
* Switch to horizontal layout
* Switch to vertical layout
* Rotate layout 90 degrees
* Switch everything to floating mode
* Switch everything to bsp tiling mode

Click the Apple icon in the upper left to start Activity Monitor.

Click the volume icon to mute the default audio.

Hover over audio, wifi, battery, and time to get some extra info.

