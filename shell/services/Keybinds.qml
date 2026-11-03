pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    property var groups: []
    property var conflicts: []
    readonly property bool loaded: groups.length > 0

    function filter(query: string): var {
        const q = (query ?? "").trim().toLowerCase();
        if (!q)
            return groups;

        return groups.map(g => ({
                    name: g.name,
                    binds: g.binds.filter(b => g.name.toLowerCase().includes(q) || b.desc.toLowerCase().includes(q) || b.keys.join(" ").toLowerCase().includes(q))
                })).filter(g => g.binds.length > 0);
    }

    FileView {
        path: `${Paths.state}/keybinds.json`
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                const data = JSON.parse(text());
                root.groups = data.groups ?? [];
                root.conflicts = data.conflicts ?? [];
            } catch (e) {
                root.groups = [];
                root.conflicts = [];
            }
        }
        onLoadFailed: {
            root.groups = [];
            root.conflicts = [];
        }
    }
}
