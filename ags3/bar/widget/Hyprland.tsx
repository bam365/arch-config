import { For, With, createBinding } from "ags"
import { createSubprocess } from "ags/process"
import Hyprland from "gi://AstalHyprland"


export function HyprlandTitleHs() {
    const hyprlandTitle = createSubprocess("", "hyprland-title", x => x)
    return (<With value={hyprlandTitle}>{(title) => <label label={title} />}</With>)
}

export function HyprlandTitle() {
    const hypr = Hyprland.get_default()
    const focusedClientBind = createBinding(hypr, "focusedClient")
    return (
        <box>
            <With value={focusedClientBind}>{(focusedClient) => {
                const titleBind = createBinding(focusedClient, "title")
                return <box><With value={titleBind}>{(title) =>
                    <label label={title} />
                }</With></box>
            }}</With>
        </box>
    )
}

export function HyprlandFullscreen() {
    const hypr = Hyprland.get_default()
    // The "hasfullscreen" prop on "focusedWorkspace" seems like it should work for
    // this purpose, but it doesn't, so just looking a the current client
    const focusedClientBind = createBinding(hypr, "focusedClient")
    return (
        <box>
            <With value={focusedClientBind}>{(client) => {
                const fullscreenBind = createBinding(client, "fullscreen")
                return <box><With value={fullscreenBind}>{(fullscreen) =>
                    <label class={"fullscreen"} label={fullscreen > 0 ? "F" : ""} />
                }</With></box>
            }}</With>
        </box>
    )
}

export function HyprlandWorkspaces() {
    const hypr = Hyprland.get_default()
    const workspaces = createBinding(hypr, "workspaces")
        .as(wss => wss.sort((a, b) => a.id - b.id))
    const focusedWorkspace = createBinding(hypr, "focusedWorkspace")
    return (
        <box>
            <With value={focusedWorkspace}>
                {(focusedWs) => (
                    <box spacing={8}>
                        <For each={workspaces}>
                            {(ws, _) => (
                                <button
                                    onClicked={() => ws.focus()}
                                    class={ws === focusedWs ? "focused" : ""}
                                >
                                    {ws.name}
                                </button>
                            )}
                        </For>
                    </box>
                )}
            </With>
        </box>
    )
}
