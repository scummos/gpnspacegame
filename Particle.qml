import QtQuick 1.1

Item {
    Rectangle {
        id: particle
        opacity: parent.opacity;
        color: "#FFF700"
        width: 10
        height: 10
        transform: Rotation { angle: 45 + 20*Math.random() }
        Behavior on opacity {
            NumberAnimation { duration: 2700 }
        }
        SequentialAnimation {
            running: true
            ColorAnimation { target: particle; property: "color"; to: "#FF9500"; duration: 500 }
            ColorAnimation { target: particle; property: "color"; to: "#FF0073"; duration: 500 }
            ColorAnimation { target: particle; property: "color"; to: "#004CFF"; duration: 500 }
            ColorAnimation { target: particle; property: "color"; to: "#00FF6A"; duration: 500 }
        }
        
        Timer {
            interval: 300
            running: true
            onTriggered: {
                parent.opacity = 0
                parent.destroy(3000)
            }
        }
    }
}