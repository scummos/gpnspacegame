import QtQuick 1.1
import Qt 4.7

Rectangle {
    id: ship
    color: playercolor
    radius: 10
    width: 2*radius
    height: 2*radius

    property color playercolor: "green"
    property string playername;
    
    property HealthBar healthbar;
    
    property variant position: [0.0, 0.0]
    property variant velocity: [0.0, 0.0]
    property variant acceleration: [0.0, 0.0]
    property variant keys: []
    
    property double health: 100
    
    property double shipAccel: 0.001
    
    function tick() {
        // calculate norm of acceleration
        var abs_acceleration = Math.sqrt(acceleration[0]*acceleration[0] + acceleration[1]*acceleration[1]);
        if(abs_acceleration == 0)
            abs_acceleration = 1.0;
        
        // update ship velocity
        var newVelocity = velocity;
        for ( var i = 0; i < 2; i++ ) {
            newVelocity[i] += acceleration[i]*shipAccel*arena.timeInterval/abs_acceleration;
            newVelocity[i] *= 0.999; // damping
        }
        velocity = newVelocity;
        
        var newPosition = position;
        // update ship position
        for ( var i = 0; i < 2; i++ ) {
            newPosition[i] += velocity[i]*arena.timeInterval
        }
        position = newPosition;
    }
    
    function changeAcceleration(amount, multiplier) {
        var newValue = acceleration;
        for ( var i = 0; i < 2; i++ ) {
            newValue[i] += multiplier * amount[i];
        }
        acceleration = newValue;
    }
    
//     onAccelerationChanged: {
//         console.log("accel:", acceleration)
//     }
    
    onPositionChanged: {
        x = position[0];
        y = position[1];
    }
}