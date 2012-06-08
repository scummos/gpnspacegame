import QtQuick 1.1

Grid {
    rows: 1; columns: 2; spacing: 20
    
    property string text : "<none>"
    property int health: -1;
    property color barcolor: "black"
    onHealthChanged: {
        children[1].children[0].width = health;
    }
    onBarcolorChanged: {
        children[1].children[0].color = barcolor;
    }
    
    
    Text {
        text: parent.text
        font.family: "Monospace"
        font.pointSize: 8
        color: "#CCCCCC"
    }
    
    Rectangle {
        border.width: 1
        width: 100
        height: 12
        // The actual health bar
        Rectangle {
            height: parent.height
            border.width: 1
            Behavior on width {
                NumberAnimation {
                    duration: 200
                }
            }
        }
        Rectangle {
            width: parent.children[0].width // the health bar's width and height
            height: parent.children[0].height
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.15) }
                GradientStop { position: 0.15; color: Qt.rgba(0, 0, 0, 0.45) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0) }
            }
        }
        radius: 1
        color: Qt.rgba(0, 0, 0, 0.2)
    }
}