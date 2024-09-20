const hyprland = await Service.import("hyprland")
const systemtray = await Service.import("systemtray")

const divide = ([total, free]) => free / total

const cpu2 = Variable(0, {
    listen: ['cpu-pct.sh']
})

const ram = Variable(0, {
    poll: [2000, 'free', out => {
        const tokens = out.split('\n')
            .find(line => line.includes('Mem:'))
            .split(/\s+/)
        const avail = parseInt(tokens[2])
        const used = parseInt(tokens[1])
        return Math.round(100 * tokens[2] / tokens[1])
    }],
})

const network = Variable("", { listen: ['network-traffic.sh'] })

const volume = Variable(0, { poll: [2000, "pamixer --get-volume"] })

const time = Variable("", { poll: [1000, "date  '+%_I:%M'"] })

const date = Variable("", { poll: [1000, "date  '+%_m/%_d/%Y'"] })

const showDate = Variable(false)

const Clock = () => Widget.Button({
    on_clicked: () => showDate.setValue(!showDate.getValue()),
    child:  Widget.Label({
        class_name: "clock",
        label: Utils.derive([time, date, showDate], (t, d, sd) => sd ? d : t).bind()
    })
})

const HyprlandFullscreen = () => Widget.Label({
    setup: self => self.hook(hyprland, function(self, ...args) {
        const eventtype = args[0]
        if (eventtype === "workspacev2") {
            const workspaceId = parseInt(args[1])
            const activeWorkspace = hyprland.getWorkspace(workspaceId)
            self.label = activeWorkspace && activeWorkspace.hasfullscreen ? "F" : ""
        } else if (eventtype === "fullscreen") {
            self.label = args[1] === "1" ? "F" : ""
        }
    }, 'event'),
    label: ""
})

const Workspaces = () => {
    const activeId = hyprland.active.workspace.bind("id")
    const workspaces = hyprland.bind("workspaces").as(ws => 
        ws
            .sort((a, b) => a.id - b.id)
            .map(({ id, name }) => Widget.Button({
                on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
                child: Widget.Label(`${name}`),
                class_name: activeId.as(i => `${i === id ? "focused" : ""}`),
            }))
    )
    return Widget.Box({
        class_name: "workspaces",
        spacing: 8,
        children: [
            Widget.Box({ spacing: 8, children: workspaces }),
            HyprlandFullscreen(),
        ]
    })
}

const ClientInfo = () => Widget.Label({
    class_name: "client-title",
    label: hyprland.active.client.bind("title"),
})

const Labeled = (lbl, widget) => Widget.Box({
    spacing: 4,
    children: [Widget.Label(lbl), widget]
})

const StatusMonitor = () => Widget.Box({
    spacing: 12,
    children: [
        Labeled("C:", Widget.Label({ label: cpu2.bind().as(v => `${v}`) })),
        Labeled("M:", Widget.Label({ label: ram.bind().as(v => `${v}`) })),
        Labeled("V:", Widget.Label({ label: volume.bind().as(v => `${v}`) })),
        Labeled("N:", Widget.Label({ class_name: "network", label: network.bind().as(v => `${v}`) })),
    ]
})

const ramProgress = Widget.CircularProgress({
    value: ram.bind()
})

const SysTrayItem = item => Widget.Button({
    child: Widget.Icon().bind('icon', item, 'icon'),
    tooltipMarkup: item.bind('tooltip_markup'),
    onPrimaryClick: (_, event) => item.activate(event),
    onSecondaryClick: (_, event) => item.openMenu(event),
})

const SysTray = () => Widget.Box({
    children: systemtray.bind("items").as(i => i.map(SysTrayItem))
})


const RightBox = () => Widget.Box({
    hpack: "end",
    homogeneous: false,
    spacing: 14,
    children: [StatusMonitor(), SysTray(), Clock()]
})

const Bar = (monitor = 0) => Widget.Window({
    name: `bar-${monitor}`,
    class_name: "bar-window",
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
        class_name: "bar",
        homogeneous: false,
        startWidget: Workspaces(),
        centerWidget: ClientInfo(),
        endWidget: RightBox(),
    }),
})

App.config({
    style: "./style.css",
    windows: [
        Bar(),
    ]
})

export { }
