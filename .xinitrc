#!/bin/sh
xset fp+ /usr/share/fonts/local
xset fp rehash
feh --bg-fill `ls ~/img/kr0/* | sort -R | head -n 1`
xmonad
