import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#050e15"
    
    property alias title: titleText.text
    property alias message: messageText.text
    
    ColumnLayout {
        anchors.centerIn: parent
        anchors.margins: 20
        spacing: 15
        
        Text {
            id: titleText
            text: "SparkleOS"
            color: "#d7f1f8"
            font.pixelSize: 18
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        
        Text {
            id: messageText
            text: "Messaggio di sistema"
            color: "#a1b4ba"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 300
        }
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            
            Controls.Button {
                text: "OK"
                background: Rectangle {
                    color: parent.pressed ? "#06acff" : "#0584ce"
                    border.color: "#d7f1f8"
                    border.width: 1
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#d7f1f8"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: root.visible = false
            }
        }
    }
}
