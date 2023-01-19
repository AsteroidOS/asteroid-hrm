/*
 * Copyright (C) 2021 Timo Könnecke <github.com/eLtMosen>
 *               2021 Darrel Griët <dgriet@gmail.com>
 *               2019 Florent Revest <revestflo@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtSensors 5.11
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.KeepAlive 1.1

Application {
    id: app

    centerColor: "#0097A6"
    outerColor: "#00060C"

    readonly property real arcStartOffset: -181
    readonly property real arcGapHeart: 52

    property int bpm: 0
    property int lastBpm: 0
    property bool pulseToggle: true
    property real arcBpmGap: app.lastBpm > 0 ? 28 : 0
    property real arcBpmOffset: app.lastBpm > app.bpm ? 75 : 15
    property real arcEnd: arcStart
    property real arcStart: arcStartOffset + arcGapHeart/2 - pulseWidthArc
    property real pulseAnimationDuration: app.bpm === 0 ?
                         100 :
                         1000 / (app.bpm / 20)

    property real arcAnimationDuration: app.bpm === 0 ?
                         30000 :
                         1000 / (app.bpm / 20)

    property real lastBpmAngle: app.lastBpm > app.bpm ?
                                    30 :
                                    -30
    property int pulseWidthArc: pulseToggle ?
                                 0 :
                                 -6
    property int pulseWidth: pulseToggle ? Dims.h(20) : Dims.h(26)

    onArcEndChanged: canvas.requestPaint()
    onArcBpmOffsetChanged: canvas.requestPaint()

    HrmSensor {
        active: true
        onReadingChanged: {
            app.lastBpm = app.bpm
            app.bpm = reading.bpm
            if (app.lastBpm > 0) {
                DisplayBlanking.preventBlanking = false
            }
        }
    }

    Timer {
        id: pulseTimer
        interval: 1000 / (app.bpm / 30)
        running: app.bpm
        repeat: true
        onTriggered: pulseToggle ?
                         pulseToggle = false :
                         pulseToggle = true
    }

    Behavior on arcBpmGap { NumberAnimation { duration: 100; easing.type: Easing.OutCirc} }
    Behavior on arcBpmOffset { NumberAnimation { duration: 1000; easing.type: Easing.OutCirc } }
    Behavior on arcEnd { NumberAnimation { duration: arcAnimationDuration; easing.type: app.lastBpm === 0 ? Easing.Linear : Easing.OutInSine } }
    Behavior on arcStart { NumberAnimation { duration: arcAnimationDuration; easing.type: app.lastBpm === 0 ? Easing.Linear : Easing.OutInSine } }
    Behavior on pulseWidth { NumberAnimation { duration: pulseAnimationDuration; easing.type: Easing.OutInSine } }
    Item {
        height: Dims.h(100)
        width: Dims.w(100)
        anchors {
            centerIn: parent
            verticalCenterOffset: DeviceInfo.flatTireHeight/2
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            rotation: -90
            opacity: 0.4
            onPaint: {
                var ctx = getContext("2d")
                var x = Dims.w(50)
                var y = Dims.h(50)
                var start = Math.PI * (arcStart / 180)
                var end = Math.PI * (arcEnd / 180)
                var gap1 = Math.PI * ((arcStartOffset + arcBpmOffset + 45 - arcBpmGap/2) / 180)
                var gap2 = Math.PI * ((arcStartOffset + arcBpmOffset + 45 + arcBpmGap/2) / 180)

                if (gap1 > end) gap1 = end
                if (gap2 > end) gap2 = end

                ctx.reset()
                ctx.beginPath()
                ctx.lineCap = "round"
                ctx.lineWidth = Dims.h(3.4)
                ctx.strokeStyle = "#38FF12"
                ctx.arc(x, y, (Dims.w(100) / 2.9), start, gap1, false)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(x, y, (Dims.w(100) / 2.9), gap2, end, false)
                ctx.stroke()
            }
        }

        Label {
            id: bpmText
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            font.letterSpacing: app.bpm > 0 ? -Dims.w(0.8) : 0
            font.pixelSize: app.bpm > 0 ?
                                app.bpm >= 100 ?
                                    Dims.h(29) :
                                    Dims.h(33) :
                                Dims.h(6)
            font.styleName: app.bpm >= 100 ? "SemiCondensed" : ""
            text: app.bpm > 0 ?
                    app.bpm :
                    //% "Measuring…"
                    qsTrId("id-measuring")
            Timer {
                id: blinkTimer
                interval: 800
                running: true
                repeat: app.bpm === 0
                onTriggered: app.bpm === 0 ?
                                bpmText.opacity = bpmText.opacity === 0 ?
                                    1 :
                                    0 :
                                bpmText.opacity = 1
            }
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutQuad } }
        }

        Text {
            id: lastBpmText
            z: 2
            color: "#ffffff"
            anchors {
                centerIn: parent
                horizontalCenterOffset: -Dims.w(34.5)
            }
            font.letterSpacing: -heartPicture.width * 0.0018
            font.pixelSize: Dims.h(8.6)
            font.styleName: "Bold"
            text: app.lastBpm > 0 ?
                    app.lastBpm :
                    ""
            Text {
                id: arrowShape
                z: 1
                anchors{
                    left: lastBpmText.right
                    leftMargin: Dims.w(2)
                    verticalCenter: lastBpmText.verticalCenter
                }
                font.family: "Source Sans Pro"
                font.pixelSize: Dims.h(7)
                color: "#6638FF12"
                text: lastBpm > 0 ? "\u25B6" : ""
            }
            transform: Rotation {
                origin.x: (Dims.w(34.5)) + (lastBpmText.width * 0.5)
                origin.y: lastBpmText.height * 0.5
                angle: lastBpmAngle
                Behavior on angle {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.OutCirc
                    }
                }
            }
        }

        Text {
            id: heartPicture
            anchors{
                centerIn: parent
                verticalCenterOffset: Dims.h(31)
            }
            font.pixelSize: pulseWidth
            text: "\u2764"
            Text {
                anchors {
                    centerIn: parent
                    verticalCenterOffset: heartPicture.height * 0.018
                }
                font.pixelSize: heartPicture.height * 0.22
                font.letterSpacing: -heartPicture.width * 0.004
                font.styleName: "Bold"
                color: "#ffffffff"
                text: "bpm"
            }
        }
    }
    Component.onCompleted: {
        DisplayBlanking.preventBlanking = true

        app.arcEnd = Qt.binding(function() { return arcStartOffset + (360 - arcGapHeart) + 28 + pulseWidthArc })
    }
}
