import QtQuick 1.1

Item {
    property string text;
    Text {
        color: "white"
        text: parent.text;
        opacity: 1
        font.pointSize: 11
        Behavior on opacity {
            NumberAnimation { duration: 2000 }
        }
        Behavior on font.pointSize {
            NumberAnimation { duration: 300 }
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