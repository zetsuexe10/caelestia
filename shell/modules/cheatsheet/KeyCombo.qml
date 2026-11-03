pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

RowLayout {
    id: root

    required property var keys

    spacing: Tokens.spacing.small

    Repeater {
        model: root.keys.slice(0, 2)

        RowLayout {
            id: alt

            required property string modelData
            required property int index

            spacing: Tokens.spacing.extraSmall

            StyledText {
                visible: alt.index > 0
                text: "/"
                color: Colours.palette.m3onSurfaceVariant
            }

            Repeater {
                model: alt.modelData.split(" + ")

                StyledRect {
                    id: chip

                    required property string modelData

                    implicitWidth: Math.max(implicitHeight, label.implicitWidth + Tokens.padding.large)
                    implicitHeight: label.implicitHeight + Tokens.padding.small * 2

                    color: Colours.palette.m3surfaceContainerHighest
                    radius: Tokens.rounding.medium

                    StyledText {
                        id: label

                        anchors.centerIn: parent
                        text: chip.modelData
                        color: Colours.palette.m3onSurface
                        font: Tokens.font.label.medium
                    }
                }
            }
        }
    }
}
