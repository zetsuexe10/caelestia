pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.modules.cheatsheet
import qs.modules.nexus.common

PageBase {
    id: root

    title: Tr.tr("Keyboard shortcuts")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SearchBar {
            id: search

            Layout.fillWidth: true
            Layout.bottomMargin: Tokens.spacing.small
            placeholderText: Tr.tr("Search shortcuts")
            font: Tokens.font.body.large
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.large
            visible: !Keybinds.loaded
            text: Tr.tr("No shortcut data yet. Reload Hyprland config (Ctrl+Super+Alt+R).")
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.medium
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.large
            visible: Keybinds.loaded && Keybinds.filter(search.text).length === 0
            text: Tr.tr("No matching shortcuts")
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.medium
        }

        Repeater {
            model: Keybinds.filter(search.text)

            BindGroup {
                required property var modelData

                Layout.fillWidth: true
                group: modelData
            }
        }
    }
}
