import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls

Controls.Button {
    text: "Esci"
    background: Rectangle {
        color: parent.pressed ? "#06acff" : "#0584ce"
        border.color: "#d7f1f8"
        border.width: 1
        radius: 4
    }
    
    contentItem: Text {
        text: parent.text
        color: "#d7f1f8"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
