#!/usr/bin/env qml
import QtQuick 2.15

Item {
    width: 384
    height: 216
    
    Rectangle {
        anchors.fill: parent
        color: "#050e15"
        
        Text {
            anchors.centerIn: parent
            text: "SparkleOS"
            color: "#d7f1f8"
            font.pixelSize: 24
            font.bold: true
        }
    }
}
