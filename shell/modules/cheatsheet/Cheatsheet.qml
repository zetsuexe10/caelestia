pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.misc
import qs.services

Scope {
    id: root

    property bool open

    readonly property var targetScreens: {
        const name = Hypr.focusedMonitor?.name;
        const match = Screens.screens.filter(s => s.name === name);
        return match.length > 0 ? match : Screens.screens;
    }

    function toggle(): void {
        open = !open;
    }

    LazyLoader {
        active: root.open

        Variants {
            model: root.targetScreens

            StyledWindow {
                id: win

                required property ShellScreen modelData

                screen: modelData
                name: "cheatsheet"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true

                Item {
                    anchors.fill: parent
                    focus: true
                    Keys.onEscapePressed: root.open = false

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, 0.45)

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.open = false
                        }
                    }

                    StyledRect {
                        id: card

                        anchors.centerIn: parent
                        width: Math.min(parent.width - Tokens.padding.extraLarge * 2, 1100)
                        height: Math.min(parent.height - Tokens.padding.extraLarge * 2, 720)

                        color: Colours.palette.m3surface
                        radius: Tokens.rounding.extraLarge

                        MouseArea {
                            anchors.fill: parent
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.padding.extraLarge
                            spacing: Tokens.spacing.largeIncreased

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spacing.medium

                                MaterialIcon {
                                    text: "keyboard"
                                    color: Colours.palette.m3primary
                                    fontStyle: Tokens.font.icon.medium
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: Tr.tr("Keyboard shortcuts")
                                    font: Tokens.font.title.large
                                }

                                StyledText {
                                    text: Tr.tr("Esc to close")
                                    color: Colours.palette.m3onSurfaceVariant
                                    font: Tokens.font.label.medium
                                }
                            }

                            SearchBar {
                                id: search

                                Layout.fillWidth: true
                                focus: true
                                placeholderText: Tr.tr("Search shortcuts")
                                font: Tokens.font.body.large
                                Keys.onEscapePressed: root.open = false
                            }

                            StyledText {
                                Layout.fillWidth: true
                                visible: Keybinds.conflicts.length > 0
                                text: Tr.tr("Conflicting shortcuts") + ": " + Keybinds.conflicts.join(", ")
                                color: Colours.palette.m3error
                                font: Tokens.font.label.medium
                                wrapMode: Text.WordWrap
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                visible: Keybinds.filter(search.text).length === 0
                                text: Keybinds.loaded ? Tr.tr("No matching shortcuts") : Tr.tr("No shortcut data yet. Reload the Hyprland config.")
                                color: Colours.palette.m3onSurfaceVariant
                                font: Tokens.font.body.large
                            }

                            VerticalFadeFlickable {
                                id: flick

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentHeight: grid.implicitHeight
                                clip: true

                                GridLayout {
                                    id: grid

                                    width: flick.width
                                    columns: width > 760 ? 2 : 1
                                    columnSpacing: Tokens.spacing.largeIncreased
                                    rowSpacing: Tokens.spacing.largeIncreased
                                    uniformCellWidths: true

                                    Repeater {
                                        model: Keybinds.filter(search.text)

                                        BindGroup {
                                            required property var modelData

                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignTop
                                            group: modelData
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.open = true;
        }

        function close(): void {
            root.open = false;
        }

        target: "cheatsheet"
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "cheatsheet"
        description: "Toggle keyboard shortcuts"
        onPressed: root.toggle()
    }
}
