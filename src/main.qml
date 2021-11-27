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
import Nemo.KeepAlive 1.1

Application {
    id: app

    centerColor: "#8d92aa"
    outerColor: "#004080"

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
    property int pulseWidth: pulseToggle ?
                                 app.height * 0.20 :
                                 app.height * 0.26

    onArcEndChanged: canvas.requestPaint()

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

    Behavior on arcBpmGap { NumberAnimation { duration: 100; easing.type: Easing.Linear} }
    Behavior on arcBpmOffset { NumberAnimation { duration: 1000; easing.type: Easing.OutCirc } }
    Behavior on arcEnd { NumberAnimation { duration: arcAnimationDuration; easing.type: app.lastBpm === 0 ? Easing.Linear : Easing.OutInSine } }
    Behavior on arcStart { NumberAnimation { duration: arcAnimationDuration; easing.type: app.lastBpm === 0 ? Easing.Linear : Easing.OutInSine } }
    Behavior on pulseWidth { NumberAnimation { duration: pulseAnimationDuration; easing.type: Easing.OutInSine } }

    Canvas {
        id: canvas
        anchors.fill: parent
        rotation: -90
        opacity: 0.4
        onPaint: {
            var ctx = getContext("2d")
            var x = app.width / 2
            var y = app.height / 2
            var start = Math.PI * (arcStart / 180)
            var end = Math.PI * (arcEnd / 180)
            var gap1 = Math.PI * ((arcStartOffset + arcBpmOffset + 45 - arcBpmGap/2) / 180)
            var gap2 = Math.PI * ((arcStartOffset + arcBpmOffset + 45 + arcBpmGap/2) / 180)

            if (gap1 > end) gap1 = end
            if (gap2 > end) gap2 = end

            ctx.reset()
            ctx.beginPath()
            ctx.lineCap = "round"
            ctx.lineWidth = app.height * 0.034
            ctx.strokeStyle = "#38FF12"
            ctx.arc(x, y, (app.width / 2.9), start, gap1, false)
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(x, y, (app.width / 2.9), gap2, end, false)
            ctx.stroke()
        }
    }

    Label {
        id: bpmText
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        font.letterSpacing: app.bpm > 0 ?
                                -app.width * 0.008 :
                                0
        font.pixelSize: app.bpm > 0 ?
                            app.bpm / 100 >= 1 ?
                                app.height*0.29 :
                                app.height*0.33 :
                            app.height*0.06
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
            horizontalCenter: app.horizontalCenter
            horizontalCenterOffset: -app.width * 0.345
            verticalCenter: app.verticalCenter
        }
        font.letterSpacing: -heartPicture.width * 0.0018
        font.pixelSize: app.height*0.086
        font.styleName: "Bold"
        text: app.lastBpm > 0 ?
                  app.lastBpm :
                  ""
        Text {
            id: arrowShape
            z: 1
            anchors{
                left: lastBpmText.right
                leftMargin: app.width * 0.02
                verticalCenter: lastBpmText.verticalCenter
            }
            font.family: "Source Sans Pro"
            font.pixelSize: app.height * 0.07
            color: "#6638FF12"
            text: lastBpm > 0 ? "\u25B6" : ""
        }
        transform: Rotation {
            origin.x: (app.width * 0.345) + (lastBpmText.width * 0.5)
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
            horizontalCenter: app.horizontalCenter
            verticalCenter: app.verticalCenter
            verticalCenterOffset: app.height * 0.31
        }
        font.pixelSize: pulseWidth
        text: "\u2764"
        Text {
            anchors {
                centerIn: heartPicture
                verticalCenterOffset: heartPicture.height * 0.018
            }
            font.pixelSize: heartPicture.height * 0.22
            font.letterSpacing: -heartPicture.width * 0.004
            font.styleName: "Bold"
            color: "#ffffffff"
            text: "bpm"
        }
    }
    Component.onCompleted: {
        DisplayBlanking.preventBlanking = true

        app.arcEnd = Qt.binding(function() { return arcStartOffset + (360 - arcGapHeart) + 28 + pulseWidthArc })
    }
}
