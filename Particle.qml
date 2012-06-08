import QtQuick 1.1

Item {
    Rectangle {
        opacity: 0.4
        color: "white"
        width: 2
        height: 2
//         Behavior on opacity {
//             NumberAnimation { duration: 2000 }
//         }
//         Timer {
//             interval: 1000
//             running: true
//             onTriggered: {
//                 parent.opacity = 0
//                 parent.destroy(2000)
//             }
//         }
    }
}