import XMonad
import XMonad.Actions.CycleWS (WSType(Not))
import XMonad.Hooks.DynamicLog
import qualified XMonad.Hooks.EwmhDesktops as EWMH
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.ResizableTile
import XMonad.Layout.Renamed
import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen
import qualified XMonad.StackSet as W
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Run (safeSpawn, spawnPipe)
import XMonad.Util.EZConfig (additionalKeys, mkKeymap)
import XMonad.Actions.CycleWS
import Graphics.X11.ExtraTypes.XF86
import System.IO
import Data.List (intersect, sortBy)
import Data.Function (on)
import Data.Monoid
import Data.Maybe
import System.Exit
import Control.Applicative ((<$>))
import Control.Monad (forM_, join)

import qualified XMonad.StackSet as W
import qualified XMonad.Layout.Spacing as S
import qualified XMonad.Actions.CycleWS as A
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "termite"
dmenuCmd = "dmenu_run -fn \"Misc Tamsyn\" -nb \"#282828\" -nf \"#b8bb26\" -sb \"#689d6a\" -sf \"#ebdbb2\""

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- NOTE: from 0.9.1 on numlock mask is set automatically. The numlockMask
-- setting should be removed from configs.
--
-- You can safely remove this even on earlier xmonad versions unless you
-- need to set it to something other than the default mod2Mask, (e.g. OSX).
--
-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
-- myNumlockMask   = mod2Mask -- deprecated in xmonad-0.9.1
------------------------------------------------------------


-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["web","util","wk1","wk2","wk3","wk4","play","sys","9"]

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor  = "#282828"
myFocusedBorderColor = "#b8bb26"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn ("exe=`" ++ dmenuCmd ++ "` && eval \"exec $exe\""))

    , ((modm,               xK_Return), spawn "myxterm")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm,               xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_semicolon), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)
    , ((modm,               xK_o     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm .|. shiftMask, xK_h     ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm .|. shiftMask, xK_l), sendMessage (IncMasterN (-1)))

    -- App keys
    , ((modm .|. mod1Mask, xK_f), spawn "firefox")
    , ((modm .|. mod1Mask, xK_b), spawn "chromium")
    , ((modm .|. mod1Mask, xK_e), spawn "myxterm -e nvim")

    -- Cycling
    , ((modm,         xK_period), A.moveTo A.Next (Not A.emptyWS))
    , ((modm,         xK_comma ), A.moveTo A.Prev (Not A.emptyWS))
    , ((modm,         xK_Tab   ), A.toggleWS)

    -- Nudging
    , ((modm,               xK_bracketleft), sendMessage MirrorShrink)
    , ((modm,               xK_bracketright), sendMessage MirrorExpand)

    -- Audio shit
    , ((0, xF86XK_AudioRaiseVolume), spawn "vol-up.sh")
    , ((0, xF86XK_AudioLowerVolume), spawn "vol-down.sh")

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "stack exec -- xmonad --recompile; stack exec -- xmonad --restart")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- Tag cycling stuff
tagsWithStack :: WindowSet -> [WorkspaceId]
tagsWithStack ss = map W.tag . filter hasStack . W.workspaces $ ss
  where hasStack ws = (W.tag ws == W.currentTag ss) || (isJust . W.stack $ ws)

tagAfter t = head . tail . dropWhile (t /=) . cycle

tagBefore t = tagAfter t . reverse

switchStackedTag fn ss = W.greedyView newTag ss
  where newTag = fn (W.currentTag ss) (tagsWithStack ss)


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- * NOTE: XMonad.Hooks.EwmhDesktops users must remove the obsolete
-- ewmhDesktopsLayout modifier from layoutHook. It no longer exists.
-- Instead use the 'ewmh' function from that module to modify your
-- defaultConfig as a whole. (See also logHook, handleEventHook, and
-- startupHook ewmh notes.)
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts layoutsWithBar
           ||| renamed [Replace "full"] (noBorders . fullscreenFull $ Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = S.smartSpacing 7 $ ResizableTall nmaster delta ratio []

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100
    layoutsWithBar =     renamed [Replace "tile"] tiled
                     ||| renamed [Replace "btile"] (Mirror tiled)
                     ||| renamed [Replace "mon"] (noBorders Full)


------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook =
    manageDocks
    <+> composeOne
          [ className =? "MPlayer"        -?> doFloat
          , className =? "Gimp"           -?> doFloat
          -- , resource  =? "desktop_window" --> doIgnore
          -- , resource  =? "kdesktop"       --> doIgnore
          , isFullscreen -?> doFullFloat
          , not <$> isDialog -?> doF W.swapDown
          ]

------------------------------------------------------------------------
-- Event handling

-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH event handling to your custom event hooks by
-- combining them with ewmhDesktopsEventHook.
--
-- myEventHook = EWMH.ewmhFullscreen
-- myEventHook = return ()

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH logHook actions to your custom log hook by
-- combining it with ewmhDesktopsLogHook.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add initialization of EWMH support to your custom startup
-- hook by combining it with ewmhDesktopsStartup.
--
myStartupHook = setWMName "LG3D"


------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

mainXmobar = do
    xmproc <- spawnPipe "xmobar /home/blake/.xmobarrc"
    xmonad $ EWMH.ewmh defaults
        { logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "#b8bb26" "" . shorten 50
                        , ppCurrent = xmobarColor "#83a598" "" . wrap "*" ""
                        }
        }

mainPolybar = do
    forM_ [".xmonad-workspace-log", ".xmonad-title-log", ".xmonad-layout-log"] $ \file -> do
        safeSpawn "mkfifo" ["/tmp/" ++ file]
    polybarProc <- spawnPipe "polybar xmonad-gruvbox"
    xmonad $ EWMH.ewmh . docks . EWMH.ewmhFullscreen $ defaults
        { logHook = eventLogHook
        }

-- Run xmonad with the settings you specify. No need to modify this.
--
main = mainPolybar

eventLogHook = do
    winset <- gets windowset
    title <- maybe (return "") (fmap show . getName) . W.peek $ winset
    let currWs = W.currentTag winset
    let layout = description . W.layout . W.workspace . W.current $ winset
    -- let wss = map W.tag $ W.workspaces winset
    let wss = intersect myWorkspaces $ map W.tag $ filter (isVisible currWs)
                $ W.workspaces winset
    let wsStr = join $ map (fmt currWs) $ wss
    appendLog "/tmp/.xmonad-title-log" title
    appendLog "/tmp/.xmonad-workspace-log" wsStr
    appendLog "/tmp/.xmonad-layout-log" layout
 where
    appendLog f s = io $ appendFile f (s ++ "\n")
    fmt currWs ws 
        | currWs == ws = "%{F#b8bb26}*" ++ ws ++ "%{F-} "
        | otherwise    = " " ++ ws ++ " "
    isVisible currWs ws = isJust (W.stack ws) || (currWs == W.tag ws)


    -- sort' = sortBy (compare `on` (!! 0))



-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        -- numlockMask deprecated in 0.9.1
        -- numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        -- handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
