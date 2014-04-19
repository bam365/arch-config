xset fp+ /usr/share/fonts/local
xset fp rehash
feh --bg-scale summervines.jpg
case $1 in
    'kde') exec startkde ;;
    'wmfs') exec wmfs ;;
    'i3') exec i3;;
    'scrotwm') /usr/local/bin/scrotwm ;;
    'xfce') startxfce4 ;;
    'openbox')
        tint2 &
        openbox ;;
    'fluxbox') fluxbox ;;
    'awesome')
        awesomestatus.sh &
        exec awesome ;;
    'bspwm')
        sxhkd &
        exec bspwm ;;
    *) 
        ~/src/dwm/dwm
esac
