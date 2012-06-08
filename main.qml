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
        
        property int timeInterval: 4
        
        Item {
            id: players
            Ship {
                function healthbar() {
                    return healthbars.children[0];
                }
                position: [50, 50]
                playercolor: "red"
                keys: [Qt.Key_Left, Qt.Key_Right, Qt.Key_Down, Qt.Key_Up]
                playername: "Player 1"
            }
            
            Ship {
                function healthbar() {
                    return healthbars.children[1];
                }
                position: [450, 450]
                playercolor: "blue"
                keys: [Qt.Key_A, Qt.Key_D, Qt.Key_S, Qt.Key_W]
                playername: "Player 2"
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
        
        Text {
            id: messagebox
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            opacity:0
            Behavior on opacity {
                NumberAnimation {
                    duration:300
                }
            }
            font.pointSize:35
            color:"white"
            text:"FOOBAR!"
        }
        
        function message(text, timeout) {
            messagebox.text = text;
            messagebox.opacity = 1;
        }
        
        function ouch(ship, damage) {
            console.log("damage: ", damage, ship);
            if ( damage < 4 ) {
                damage = 0;
            }
            ship.health -= damage;
            if ( ship.health <= 0 ) {
               ship.health = 0;
               message(ship.playername + " died. Fail!", 5000);
            }
            ship.healthbar().health = ship.health;
        }
        
        function applyDamageFromWallCollision(ship) {
            console.log(ship.velocity);
            var damage = ( Math.pow(ship.velocity[0], 2) + Math.pow(ship.velocity[1], 2) ) * 20;
            ouch(ship, damage);
        }
        
        function reflect(ship, axis) {
            applyDamageFromWallCollision(ship);
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
        
        function eventuallyHandleShipCollision(ship, other) {
            // ship coordinates specify the upper left corner
            var distance = Math.sqrt(Math.pow(ship.position[0]-other.position[0], 2)
                                    +Math.pow(ship.position[1]-other.position[1], 2));
            var effective_radius = (ship.radius + other.radius);
            if ( distance < effective_radius ) {
                // simple collision with equal masses: swap velocities
                var v1 = ship.velocity;
                var v2 = other.velocity;
                ship.velocity = v2;
                other.velocity = v1;
                // avoid penetration: move players apart
                var p1 = ship.position;
                var p2 = other.position;
                // half the penetration depth scaled by the distance
                // penetration_vec has half pen. depth as magnitude, then
                var penetration_norm = (effective_radius - distance) * distance * 10;
                var penetration_vec = [(p1[0]-p2[0])/penetration_norm, (p1[1]-p2[1])/penetration_norm];
                ship.position = [p1[0] + penetration_vec[0], p1[1] + penetration_vec[1]];
                other.position = [p2[0] - penetration_vec[0], p2[1] - penetration_vec[1]];
            }
        }
        
        Timer {
            interval: arena.timeInterval; running: true; repeat: true
            onTriggered: {
                for ( var i = 0; i < 2; i++ ) {
                    players.children[i].tick();
                    parent.eventuallyHandleArenaCollision(players.children[i]);
                }
                // TODO 2-player only
                parent.eventuallyHandleShipCollision(players.children[0], players.children[1]);
            }
        }
    }
    
    Grid {
        id: healthbars
        x: 25
        columns: 2; rows: 1; spacing: 40;
        HealthBar {
            text: "Player 1"
            barcolor: players.children[0].playercolor
            health: 100.0
        }
        
        HealthBar {
            text: "Player 2"
            barcolor: players.children[1].playercolor
            health: 100.0
        }
    }
    
}