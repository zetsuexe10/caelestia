pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
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
        spacing: Tokens.spacing.largeIncreased

        SearchBar {
            id: search

            Layout.fillWidth: true
            placeholderText: Tr.tr("Search shortcuts")
            font: Tokens.font.body.large
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
