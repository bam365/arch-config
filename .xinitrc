#!/bin/sh
# rand-kr0-wall
feh --bg-fill ~/img/kr0/barstool.png
case $1 in
    'xfce') startxfce4 ;;
    *) stack exec -- xmonad 
esac
