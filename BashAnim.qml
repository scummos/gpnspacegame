import QtQuick 1.1

Rectangle {
    property double angle : 0
    property double strength: 45
    opacity: 0.25
    z: 500
    Repeater {
        model: 20
        Rectangle {
            x: (strength+8)*Math.random()*0.4 - 4
            y: (strength+8)*Math.random()*0.4 - 4
            id: rect
            color: "white"
            height: 1
            width: 0
            transform: Rotation { angle: parent.angle; }
            ParallelAnimation {
                running: true
                NumberAnimation { target: rect; property: "opacity"; to: 0.4; duration: 50 }
                NumberAnimation { target: rect; property: "width"; to: strength/1.2 + 15; duration: 50 }
            }
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: 80 }
    }
    Timer {
        interval: 100
        running: true
        onTriggered: {
            parent.opacity = 0
            parent.destroy(80)
        }
    }
}