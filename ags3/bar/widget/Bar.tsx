import { createComputed, createBinding } from "ags"
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"

import DateDisplay from "./DateDisplay"
import { HyprlandTitle, HyprlandFullscreen, HyprlandWorkspaces } from "./Hyprland"
import { StatusMonitors } from "./StatusMonitors"
import Tray from "./Tray"


export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const rightBox =
        <box
            halign={Gtk.Align.END}
            spacing={14}
            homogeneous={false}
        >
            <StatusMonitors />
            <Tray />
            <DateDisplay />
        </box>


    return (
        <window
            visible
            name="Bar"
            class="bar"
            gdkmonitor={gdkmonitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={TOP | LEFT | RIGHT}
            application={app}
        >
            <centerbox cssName="centerbox">
                <box spacing={8} $type="start">
                    <HyprlandWorkspaces />
                    <box halign={Gtk.Align.END}>
                        <HyprlandFullscreen />
                    </box>
                </box>
                <box $type="center">
                    <HyprlandTitle />
                </box>
                <box $type="end">
                    {rightBox}
                </box>
            </centerbox>
        </window >
    )
}
