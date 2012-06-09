import QtQuick 1.1

Grid {
    rows: 1; columns: 3; spacing: 20
    
    property string text : "<none>"
    property int health: -1;
    property color barcolor: "black"
    onHealthChanged: {
        if( children[1].children[0].width < health ) {
            increase_health.start();
        }
        else {
            decrease_health.start();
        }
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
    
    function animateBash() {
        bashAnimation.restart();
    }
    
    Text {
        id: bashtext
        color: "yellow"
        text: "Bash!"
        SequentialAnimation {
            id: bashAnimation
            ColorAnimation { target: bashtext; property: "color"; to: "black"; duration: 0 }
            ColorAnimation { target: bashtext; property: "color"; to: "white"; duration: 8000 }
            SequentialAnimation {
                loops: 3
                ColorAnimation { target: bashtext; property: "color"; to: "red"; duration: 100 }
                ColorAnimation { target: bashtext; property: "color"; to: "yellow"; duration: 100 }
            }
        }
    }
    
    SequentialAnimation {
        id: "increase_health"
        running: false;
        loops: 1;
        ColorAnimation { target: children[1].children[0]; property: "color"; to: Qt.lighter(barcolor, 3.2); duration: 50 }
        ColorAnimation { target: children[1].children[0]; property: "color"; to: barcolor; duration: 200 }
    }
    SequentialAnimation {
        id: "decrease_health"
        running: false;
        loops: 1;
        ColorAnimation { target: children[1].children[0]; property: "color"; to: Qt.darker(barcolor, 1.7); duration: 50 }
        ColorAnimation { target: children[1].children[0]; property: "color"; to: barcolor; duration: 200 }
    }
}