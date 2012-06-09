import QtQuick 1.1

Item {
    z: 100
    property string text
    property int fontSize
    property color col
    
    Repeater {
        model: 50
        Rectangle {
            id: explosionSprite
            width: 1; height: 0
            border.width: 0
            x: Math.random()*10-5
            y: Math.random()*10-5
            opacity: 0.8
            color: "white"
            transform: Rotation { angle: 365*Math.random() }
            ParallelAnimation {
                running: true
                NumberAnimation { target: explosionSprite; property: "opacity"; to: 0; duration: 300+6*fontSize }
                NumberAnimation { target: explosionSprite; property: "height"; to: 40+10*(fontSize-10); duration: 300+Math.random()*200+6*fontSize }
            }
        }
    }
    
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
                parent.parent.destroy(2000)
            }
        }
    }
}