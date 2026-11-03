pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

ColumnLayout {
    id: root

    required property var group

    spacing: Tokens.spacing.extraSmall / 2

    StyledText {
        Layout.leftMargin: Tokens.padding.small
        Layout.bottomMargin: Tokens.spacing.extraSmall
        text: root.group.name
        color: Colours.palette.m3primary
        font: Tokens.font.label.medium
    }

    Repeater {
        model: root.group.binds

        ConnectedRect {
            id: row

            required property var modelData
            required property int index

            Layout.fillWidth: true
            first: index === 0
            last: index === root.group.binds.length - 1
            implicitHeight: content.implicitHeight + Tokens.padding.large * 2

            RowLayout {
                id: content

                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium

                StyledText {
                    Layout.fillWidth: true
                    text: row.modelData.desc
                    font: Tokens.font.body.medium
                    elide: Text.ElideRight
                }

                KeyCombo {
                    keys: row.modelData.keys
                }
            }
        }
    }
}
