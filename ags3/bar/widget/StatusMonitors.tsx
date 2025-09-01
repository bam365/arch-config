import { With } from "ags"
import { Gtk } from "ags/gtk4"
import { createSubprocess } from "ags/process"
import { createPoll } from "ags/time"

const labeled = (lbl: string, widget: JSX.Element) =>
    <box spacing={4}>
        <label label={lbl} />
        {widget}
    </box>

export function CpuMonitor() {
    const cpu = createSubprocess("", "cpu-pct.sh", x => x)
    return labeled("C:", <With value={cpu}>{(cpu) => <label label={cpu} />}</With>)
}

export function MemoryMonitor() {
    const memory = createPoll("", 2000, "free", out => {
        const memLine = out
            .split('\n')
            .find(line => line.includes('Mem:'))
        const tokens = memLine ? memLine.split(/\s+/) : ["1", "0"]
        const avail = parseInt(tokens[2])
        const used = parseInt(tokens[1])
        return `${Math.round(100 * avail / used)}`
    })
    return labeled("M:", <With value={memory}>{(mem) => <label label={mem} />}</With>)
}

export function VolumeMonitor() {
    const vol = createPoll("", 2000, "pamixer --get-volume")
    return labeled("M:", <With value={vol}>{(vol) => <label label={vol} />}</With>)
}

export function NetMonitor() {
    const net = createSubprocess("", "network-traffic.sh", x => x)
    return labeled("N: ", <With value={net}>{(net) =>
        <label
            class={"network"}
            hexpand={false}
            halign={Gtk.Align.CENTER}
            label={net}
        />
    }</With>)
}

export function StatusMonitors() {
    return (
        <box spacing={12}>
            <CpuMonitor />
            <MemoryMonitor />
            <VolumeMonitor />
            <NetMonitor />
        </box>
    )
}
