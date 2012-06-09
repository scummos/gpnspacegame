import QtQuick 1.1

Grid {
    columns: 3
    rows: 3
    spacing: 1
    state: "Ready"
    states: [
        State {
            name: "Running"
            
        },
        State {
            name: "Ready"
        }
    ]
    Repeater {
        id: repeater
        model: 9
        Rectangle {
            id: rect;
            opacity: 1.0
            width: 4
            height: 4
            color: "#EEFF00"
            SequentialAnimation {
                id: anim
                NumberAnimation { target: rect; property: "opacity"; to: 0.2; duration: 0 }
                NumberAnimation { target: rect; property: "opacity"; to: 0.2; duration: 8000/9.0 * (index+1) - 200 }
                NumberAnimation { target: rect; property: "opacity"; to: 1.0; duration: 200 }
                NumberAnimation { target: rect; property: "opacity"; to: 1.0; duration: 8000/9.0 * (9-(index)) - 200 }
                SequentialAnimation {
                    loops: 3
                    ColorAnimation { target: rect; property: "color"; to: "red"; duration: 100 }
                    ColorAnimation { target: rect; property: "color"; to: "#EEFF00"; duration: 100 }
                }
            }
        }
    }
    function runAnimation() {
        reset();
        for ( var i = 0; i < 9; i++ ) {
            repeater.itemAt(i).data[0].start();
        }
    }
    function reset() {
        for ( var i = 0; i < 9; i++ ) {
            repeater.itemAt(i).data[0].stop();
            repeater.itemAt(i).color = "#EEFF00";
            repeater.itemAt(i).opacity = 1.0;
        }
    }
}