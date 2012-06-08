import QtQuick 1.1

Item {
    property variant colors
    Rectangle {
        property variant colors: parent.colors
        id: particle
        opacity: parent.opacity;
        width: 30
        height: 30
        radius: 15
        color: colors[0];
        transform: Rotation { angle: 45 + 20*Math.random() }
        Behavior on opacity {
            NumberAnimation { duration: 2700 }
        }
        SequentialAnimation {
            running: true
            ColorAnimation { target: particle; property: "color"; to: colors[1]; duration: 500 }
            ColorAnimation { target: particle; property: "color"; to: colors[2]; duration: 500 }
            ColorAnimation { target: particle; property: "color"; to: colors[3]; duration: 500 }
            ColorAnimation { target: particle; property: "color"; to: colors[4]; duration: 500 }
        }
        
        ParallelAnimation {
            running: true
            NumberAnimation { target: particle; property: "width"; to: 10; duration: 800 }
            NumberAnimation { target: particle; property: "height"; to: 10; duration: 800 }
            NumberAnimation { target: particle; property: "radius"; to: 0; duration: 1100 }
        }
        
        Timer {
            interval: 300
            running: true
            onTriggered: {
                parent.opacity = 0;
                parent.destroy(3000);
            }
        }
    }
}