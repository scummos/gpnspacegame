import QtQuick 1.1

Item {
    z: 100
    property string text
    property int fontSize
    property color col
    Text {
        color: parent.col
        style: Text.Outline
        styleColor: Qt.rgba(255, 255, 255, 0.5)
        text: parent.text
        opacity: 1
        font.pointSize: parent.fontSize
        Behavior on opacity {
            NumberAnimation { duration: 2000 }
        }
        Timer {
            interval: 1000
            running: true
            onTriggered: {
                parent.opacity = 0
                parent.destroy(2000)
            }
        }
    }
}