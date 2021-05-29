/*
 * Copyright (C) 2019 Florent Revest <revestflo@gmail.com>
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

Application {
    id: app

    centerColor: "#b04d1c"
    outerColor: "#421c0a"

    property int bpm: 0;

    HrmSensor {
        active: true
        onReadingChanged: app.bpm = reading.bpm;
        onStatusChanged: console.log("status changed to: " + str(status))
    }

    Label {
        id: bpmText
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
       //% "Measuring..."
        text: app.bpm > 0 ? app.bpm : qsTrId("id-measuring")
    }
}
