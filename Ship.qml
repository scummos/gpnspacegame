import QtQuick 1.1
import Qt 4.7

Rectangle {
    id: ship
    color: playercolor
    width: 20
    height: 20

    property color playercolor: "green"
    
    property variant position: [0.0, 0.0]
    property variant velocity: [0.0, 0.0]
    property variant acceleration: [0.0, 0.0]
    property variant keys: []
    
    function tick() {
        console.log("tick: ", position, velocity, acceleration);
    }
    
    function changeAcceleration(amount, multiplier) {
        console.log("acceleration changed: ", amount);
        var newValue = acceleration;
        for ( var i = 0; i < 2; i++ ) {
            newValue[i] += multiplier * amount[i];
        }
        acceleration = newValue;
    }
    
    onAccelerationChanged: {
        console.log("accel:", acceleration)
    }
    
    onPositionChanged: {
        console.log("position changed:", position);
        x = position[0];
        y = position[1];
    }
    
}