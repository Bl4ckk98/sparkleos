import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#050e15"
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "SparkleOS"
            color: "#d7f1f8"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        
        Text {
            text: "Arrivederci!"
            color: "#a1b4ba"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
        }
        
        ProgressBar {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 200
            value: 1.0
        }
    }
}
