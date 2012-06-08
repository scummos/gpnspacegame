import QtQuick 1.1
import Qt 4.7

Rectangle {
    id: canvas
    width: 600
    height: 600
    color: "#FFBC00"
    
    Rectangle {
        id: arena
        width: 550
        height: 550
        x: 25
        y: 25
        color: "#000000"
        
        property double shipAccel: 0.02
        
        Item {
            id: players
            Ship {
                position: [50, 50]
                playercolor: "red"
                keys: [Qt.Key_Left, Qt.Key_Right, Qt.Key_Down, Qt.Key_Up]
            }
            
            Ship {
                position: [450, 450]
                playercolor: "blue"
                keys: [Qt.Key_A, Qt.Key_D, Qt.Key_S, Qt.Key_W]
            }
        }
        
        focus: true
        
        function doHandleKey(event, eventType) {
            var multiplier = 0;
            if ( eventType == "pressed" ) {
                multiplier = +1;
            }
            else if ( eventType == "released" ) {
                multiplier = -1;
            }
            multiplier *= shipAccel; // speed of the ships in general
            var accelerations = [ [-1.0, 0.0], [1.0, 0.0],
                                  [0.0, 1.0], [0.0, -1.0] ];
            for ( var i = 0; i < 4; i++ ) {
                for ( var j = 0; j < 2; j++ ) {
                    if ( event.key == players.children[j].keys[i] ) {
                        players.children[j].changeAcceleration(accelerations[i], multiplier)
                    }
                }
            }
        }
        
        Keys.onPressed: {
            event.accepted = true;
            doHandleKey(event, "pressed")
        }
        
        Keys.onReleased: {
            doHandleKey(event, "released")
        }
        
        function reflect(ship, axis) {
            var reflectedVelocity = ship.velocity;
            reflectedVelocity[axis] = -reflectedVelocity[axis] * 0.75;
            reflectedVelocity[1-axis] = reflectedVelocity[1-axis] * 0.75;
            ship.velocity = reflectedVelocity;
        }
        
        function eventuallyHandleArenaCollision(ship) {
            if ( ship.x + ship.radius*2 > width || ship.x < 0 ) {
                reflect(ship, 0);
                var pos = ship.position;
                if(ship.x < 0)
                    pos[0] = 0;
                else
                    pos[0] = width - ship.radius*2;
                ship.position = pos;
            }
            if ( ship.y + ship.radius*2 > height || ship.y < 0 ) {
                reflect(ship, 1);
                var pos = ship.position;
                if(ship.y < 0)
                    pos[1] = 0;
                else
                    pos[1] = height - ship.radius*2;
                ship.position = pos;
            }
        }
        
        Timer {
            interval: 4; running: true; repeat: true
            onTriggered: {
                for ( var i = 0; i < 2; i++ ) {
                    players.children[i].tick();
                    parent.eventuallyHandleArenaCollision(players.children[i]);
                    parent.eventuallyHandleShipCollision(players.children[1-i]); // TODO 2-player only
                }
            }
        }
    }
}