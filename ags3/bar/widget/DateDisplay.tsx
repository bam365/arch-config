import { With, createState } from "ags"
import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"

export default function DateDisplay() {
    const time = createPoll("", 1000, "date '+%_I:%M'")
    const date = createPoll("", 1000, "date '+%_m/%_d/%Y'")
    const [showingDate, setShowingDate] = createState(false)

    const toggleDate = () => {
        setShowingDate(d => !d)
    }

    return (
        <With value={showingDate}>{(isShowingDate) =>
            <button
                hexpand
                halign={Gtk.Align.END}
                onClicked={toggleDate}
            >
                <label label={isShowingDate ? date : time} />
            </button>
        }</With>
    )
}
