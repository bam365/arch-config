# Unix config files

## Starting on a new machine

Running the `make-links.sh` file will create symlinks in the ~/.config directory for several of these things

You'll want to copy most of the stuff in bin/ to ~/.local/bin

## Current set up

### Hyprland

Hyprland is the current desktop of choice. Configured by hypr/hyprland.conf.

### AGS

In Hyprland, AGS is currently being used for a top status bar. AGS is currently in a transitional state. The
most recent version is technically 3.0 but it's not even released yet. There is a working bar project in the
ags3 directory. The `start-bar.sh` binary will launch the bar after it is installed to ~/.config

To install ags3, it's probably best to install the github:aylur/ags#agsFull package to your nix profile.

Some things have been omitted from the bar project, like the node_modules and @girs directories. You may need
to do some things with the `ags` cli command to get those files back and pointed at your nix store or whatever
appropriate place to do get LSP support when developing.

This currently relies on some tools on [bamhsclitools](https://codeberg.org/bam365/bamhsclitools)

### Alacritty

The current terminal of choice is alacritty.


### Dunst

Dunst is the current desktop notifications system of choice.
