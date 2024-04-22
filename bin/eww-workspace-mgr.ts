import { 
	HyprlandWorkspaceData, handleSocket2Events, getHyprlandWorkspaceData,
	Event, WorkspaceDefinition, getWorkspaceDefinitions
} from "./hyprland-util.ts"


interface WorkspaceData {
	index: string
	class: string
	icon: string
}

interface Data {
	activeWorkspace: number
	activeTitle: string
	isFullscreen: boolean
	workspacedata: WorkspaceData[]
}

let activeTitle = ""
let activeWorkspaceId = 1

const makeNewData = (ev: Event, definitions: Map<number, WorkspaceDefinition>, hyprlandData: HyprlandWorkspaceData[]): Data => {
	activeWorkspaceId = ev.t === "activeworkspace" ? ev.id : activeWorkspaceId
	const activeWorkspace = hyprlandData.find(hw => hw.id === activeWorkspaceId)
	activeTitle = ev.t === "activewindow" ? ev.title : activeTitle
	return {
		activeWorkspace: activeWorkspaceId,
		activeTitle,
		isFullscreen: activeWorkspace ? activeWorkspace.hasFullscreen : false,
		workspacedata: hyprlandData.map(hw => {
			const def = definitions.get(hw.id)
			return {
				index: hw.id.toString(),
				class: activeWorkspaceId === hw.id ? "ws-active" : "ws-inactive",
				icon: def ? def.name : hw.id.toString()
			}
		})
	}
}

const workspaceDefs = await getWorkspaceDefinitions()

await handleSocket2Events(async (event) => {
	if (event.t === "unknown") {
		return
	}
	const hyprlandData = await getHyprlandWorkspaceData()
	const newData = makeNewData(event, workspaceDefs, hyprlandData)
	console.log(JSON.stringify(newData))
})
	
