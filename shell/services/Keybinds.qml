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

    function refresh(): void {
        if (groups.length === 0 && !fallback.running)
            fallback.running = true;
    }

    function filter(query: string): var {
        const q = (query ?? "").trim().toLowerCase();
        if (!q)
            return groups;

        return groups.map(g => ({
                    name: g.name,
                    binds: g.binds.filter(b => g.name.toLowerCase().includes(q) || b.desc.toLowerCase().includes(q) || b.keys.join(" ").toLowerCase().includes(q))
                })).filter(g => g.binds.length > 0);
    }

    function fromHyprctl(raw: string): void {
        if (groups.length > 0)
            return;

        const mods = [[64, "SUPER"], [4, "CTRL"], [8, "ALT"], [1, "SHIFT"]];
        const seen = new Set();
        const binds = [];

        try {
            for (const b of JSON.parse(raw)) {
                const key = b.key || (b.keycode ? `code:${b.keycode}` : "");
                if (!key)
                    continue;

                const combo = [...mods.filter(m => (b.modmask & m[0]) !== 0).map(m => m[1]), key].join(" + ");
                const desc = b.description || `${b.dispatcher ?? ""} ${b.arg ?? ""}`.trim();
                if (seen.has(combo + desc))
                    continue;

                seen.add(combo + desc);
                binds.push({
                    keys: [combo],
                    desc: desc || "Binding"
                });
            }
        } catch (e) {
            return;
        }

        if (binds.length > 0)
            groups = [
                {
                    name: "Bindings",
                    binds
                }
            ];
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
            root.refresh();
        }
        onLoadFailed: {
            root.groups = [];
            root.conflicts = [];
            root.refresh();
        }
    }

    Process {
        id: fallback

        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.fromHyprctl(text)
        }
    }
}
