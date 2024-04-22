export interface HyprlandWorkspaceData {
	id: number
	hasFullscreen: boolean
}

export interface WorkspaceDefinition {
	id: number
	name: string
}

export type Event = 
	| { t: "activewindow", title: string }
	| { t: "activeworkspace", id: number }
	| { t: "fullscreen", num: number }
	| { t: "unknown", fullEvent: string }

const socketPath  = `/tmp/hypr/${Deno.env.get("HYPRLAND_INSTANCE_SIGNATURE")}/.socket2.sock`

const parseEvent = (ev: string): Event => {
	const parts = ev.split(">>")
	if (parts.length < 2) {
		return { t: "unknown", fullEvent: ev }
	}
	const evType = parts[0]
	if (evType === "activewindow") {
		return { t: "activewindow", title: parts[1] }
	} else if (evType === "workspace") {
		return { t: "activeworkspace", id: parseInt(parts[1]) }
	} else if (evType === "fullscreen") {
		return { t: "fullscreen", num: parseInt(parts[1]) }
	} else {
		return ({ t: "unknown", fullEvent: ev })
	}
}

const parseWorkspaceData = (output: string): HyprlandWorkspaceData[] => {
	const lines = output
		.split("\n")
		.map(s => s.trim())
	const workspaceIds = lines.reduce(
		(acc, line) => {
			const match = new RegExp("workspace ID (\\d+)").exec(line)
			return match === null ? acc : [...acc, parseInt(match[1])]
		},
		[] as number[]
	)
	const hasFullscreen = lines.reduce(
		(acc, line) => {
			const match = new RegExp("hasfullscreen: (\\d)").exec(line)
			return match === null ? acc : [...acc, match[1] === "1"]
		},
		[] as boolean[]
	)
	return workspaceIds
		.map((id, idx) => ({ id, hasFullscreen: hasFullscreen[idx] }))
		.sort((a, b) => a.id - b.id)
}

export const handleSocket2Events = async (handler: (ev: Event) => Promise<void>) => {
	const conn = await Deno.connect({ path: socketPath, transport: "unix" })
	const decoder = new TextDecoder()
	for await (const chunk of conn.readable) {
		const events = decoder.decode(chunk)
		for (const event of events.split("\n")) {
			await handler(parseEvent(event))
		}
	}
}

export const getHyprlandWorkspaceData = async () => {
	const cmd = new Deno.Command("hyprctl", { args: ["workspaces"]})
	const output = await cmd.output() 
	return parseWorkspaceData(new TextDecoder().decode(output.stdout))
}

export const getWorkspaceDefinitions = async (): Promise<Map<number, WorkspaceDefinition>> => {
	const cmd = new Deno.Command("eww", { args: ["get", "workspacedefs"] })
	const output = await cmd.output() 
	const jsonData = JSON.parse(new TextDecoder().decode(output.stdout)) as WorkspaceDefinition[]
	const ret = new Map<number, WorkspaceDefinition>()
	for (const wd of jsonData) {
		ret.set(wd.id, wd)
	}
	return ret
}
