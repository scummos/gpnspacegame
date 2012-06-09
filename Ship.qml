import QtQuick 1.1
import Qt 4.7
import Qt.labs.particles 1.0

Rectangle {
    id: ship
    color: playercolor
    radius: 17
    width: 2*radius
    height: 2*radius
    opacity: 0
    
    property variant particleColors;

    property color playercolor: "green"
    property string playername;
    
    property HealthBar healthbar;
    
    property variant position: [0.0, 0.0]
    property variant velocity: [0.0, 0.0]
    property variant acceleration: [0.0, 0.0]
    property variant keys: []
    property double particleEmissionCounter: 0;
    
    property double health: 100
    
    property double shipAccel: 0.001
    
    // ticks since the most recent crash, negative
    // "0" means "long ago"
    property int recentlyCrashed: 0;
    property int reducedDamage: 0;
    property int boostCooldown: 0;
    
    function tryBoost(other) {
        if ( boostCooldown < 0 ) {
            return false;
        }
        var strength = Math.pow(position[0]-other.position[0], 2)
                      +Math.pow(position[1]-other.position[1], 2);
        var distance = Math.sqrt(strength);
        strength = Math.min(1 / Math.sqrt(strength) * 50, 0.5);
        var direction_x = position[0]-other.position[0];
        var direction_y = position[1]-other.position[1];
        direction_x /= distance;
        direction_y /= distance;
        console.log("str:", strength);
        var newVelocity = other.velocity;
        newVelocity[0] -= direction_x * strength;
        newVelocity[1] -= direction_y * strength;
        other.velocity = newVelocity;
        boostCooldown = -8000/arena.timeInterval;
        healthbar().animateBash();
        return true;
    }
    
    function tick() {
        // calculate norm of acceleration
        var abs_acceleration = Math.sqrt(acceleration[0]*acceleration[0] + acceleration[1]*acceleration[1]);
        if ( abs_acceleration == 0 ) {
            abs_acceleration = 1.0;
        }
        
        // update ship velocity
        var newVelocity = velocity;
        for ( var i = 0; i < 2; i++ ) {
            newVelocity[i] += acceleration[i]*shipAccel*arena.timeInterval/abs_acceleration;
            if ( newVelocity[i]*acceleration[i] < 0 ) {
                // opposite directions
                if ( recentlyCrashed == 0 ) {
                    newVelocity[i] *= 0.85
                }
                else {
                    newVelocity[i] *= 0.95
                }
            }
            // damping
            if ( recentlyCrashed == 0) {
                newVelocity[i] *= 0.995;
            }
            else {
                newVelocity[i] *= 0.998;
            }
        }
        velocity = newVelocity;
        var abs_velocity = Math.sqrt(Math.pow(velocity[0],2) + Math.pow(velocity[1],2));
        // console.log(recentlyCrashed, " ", abs_velocity);
        if ( recentlyCrashed == 0 && abs_velocity > 0.8 && canvas.state == "GameRunningState") {
            health += 3.0/arena.timeInterval;
            if(health > 100) {
                health = 100;
            }
        }
        
        var newPosition = position;
        // update ship position
        for ( var i = 0; i < 2; i++ ) {
            newPosition[i] += velocity[i]*arena.timeInterval;
        }
        position = newPosition;
        if ( recentlyCrashed < 0 ) {
            recentlyCrashed ++;
        }
        if ( reducedDamage < 0 ) {
            reducedDamage ++;
        }
        if ( boostCooldown < 0 ) {
            boostCooldown ++;
        }
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
    
    function spawnParticle(opacity) {
        var comp = Qt.createComponent("Particle.qml");
        var sprite = comp.createObject(arena, {
            "x": x + radius + (Math.random()-0.5) * 8,
            "y": y - radius/2 + (Math.random()-0.5) * 8,
            "opacity": opacity,
            "colors": particleColors
        });

        if (sprite == null) {
            // Error Handling
            console.log("Error creating object");
        }
    }
    
    // basic periodic particle spawner
    Timer {
        interval: 300
        running: true
        repeat: true
        onTriggered: {
            spawnParticle(0.5);
        }
    }
    
    onHealthChanged: {
        ship.healthbar().health = ship.health;
    }
    
    onPositionChanged: {
        particleEmissionCounter -= Math.abs(x-position[0])
        particleEmissionCounter -= Math.abs(y-position[1])
        x = position[0];
        y = position[1];
        if ( particleEmissionCounter < 0 ) {
            spawnParticle(Math.max(0.5, 
                                   Math.min(0.7, 
                                            (Math.abs(velocity[0])+Math.abs(velocity[1]))*1.3
                                           )
                                  )
                         );
            particleEmissionCounter = 6;
        }
    }
}