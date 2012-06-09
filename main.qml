import QtQuick 1.1
import Qt 4.7

Rectangle {
    id: canvas
    width: 600
    height: 600
    color: "#333333"
    state: "NotStartedState"
    
    states: [
        State {
            name: "NotStartedState"
            PropertyChanges { target: startGameBanner; visible: true}
            PropertyChanges { target: help; visible: true }
        },
        State {
            name: "GameRunningState"
            PropertyChanges { target: messagebox; visible: false }
            PropertyChanges { target: startGameBanner; visible: false }
            PropertyChanges { target: help; visible: false }
        }
    ]
    
    Rectangle {
        id: arena
        width: 550
        height: 550
        x: 25
        y: 25
        color: "#000000"
        
        property int timeInterval: 16
        
        Rectangle {
            z:200
            id: help
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                y: 20
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                text: "<center>Player 1 controls: Arrow keys</center>\n"+
                      "<center>Player 2 controls: WASD</center>\n"+
                      "<center>Hit your enemy to make him crash into walls!</center>\n"+
                      "<center>The faster you hit a wall, the more damage you take.</center>\n"+
                      "<center>If you recently collided with an enemy, more damage will be dealt by crashes.</center>\n"+
                      "<center>Flying fast regenerates hitpoints.</center>\n"
            }
        }
        
        Rectangle {
            id: startGameBanner;
            z:200
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 80
                opacity:1
                Behavior on opacity {
                    NumberAnimation {
                        duration:300
                    }
                }
                font.pointSize:11
                color:"white"
                text:"Press Spacebar to start a new game"
                
                SequentialAnimation {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { target: startGameBanner; property: "opacity"; to: 0.3; duration: 600 }
                    NumberAnimation { target: startGameBanner; property: "opacity"; to: 1.0; duration: 600 }
                }
            }
        }
        
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
                particleColors: ["#FF0051", "#FF0000", "#FF4C00", "#FFAE00", "#E6FF00"]
            }
            
            Ship {
                function healthbar() {
                    return healthbars.children[1];
                }
                position: [450, 450]
                playercolor: "blue"
                keys: [Qt.Key_A, Qt.Key_D, Qt.Key_S, Qt.Key_W]
                playername: "Player 2"
                particleColors: ["#0800FF", "#008CFF", "#00FFCC", "#00FF51", "#33FF00"]
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
        
        function newGame() {
            console.log("new game started");
            canvas.state = "GameRunningState"
            for ( var i = 0; i < 2; i++ ) {
                players.children[i].health = 100;
                players.children[i].velocity = [0, 0]
                players.children[i].acceleration = [0, 0]
            }
            players.children[0].position = [50, 50]
            players.children[1].position = [450, 450]
        }
        
        Keys.onPressed: {
            event.accepted = true;
            if ( event.key == Qt.Key_Space && canvas.state == "NotStartedState" ) {
                newGame();
            }
            if ( event.key == Qt.Key_Escape && canvas.state == "GameRunningState" ) {
                canvas.state = "NotStartedState";
            }
            doHandleKey(event, "pressed")
        }
        
        Keys.onReleased: {
            event.accepted = true;
            doHandleKey(event, "released")
        }
        
        Text {
            z:200
            id: messagebox
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            opacity:1
            Behavior on opacity {
                NumberAnimation {
                    duration:300
                }
            }
            font.pointSize:35
            color:"white"
            text:"<center>GPNSpaceGame</center>"
        }
        
        function message(text, timeout) {
            messagebox.text = text;
            messagebox.opacity = 1;
        }
        
        function wallCollisionFeedback(location, text, color) {
            var comp = Qt.createComponent("WallCrashAnimation.qml");
            var fontsize = 11;
            if ( text !== "" ) {
                if ( text > 20 ) {
                    text += "!!";
                    fontsize = 15;
                }
                else if ( text > 10 ) {
                    text += "!";
                    fontsize = 13;
                }
                else if ( text < 6 ) {
                    fontsize = 9;
                }
            }
            var sprite = comp.createObject(arena, {
                "x": location[0],
                "y": location[1],
                "text": text,
                "fontSize": fontsize,
                "col": color
            });

            if (sprite == null) {
                // Error Handling
                console.log("Error creating object");
            }
        }
        
        function ouch(ship, damage) {
            if ( damage < 4 ) {
                damage = 0;
            }
            if ( ship.reducedDamage == 0) {
                damage /= 2
            }
            if ( canvas.state == "GameRunningState" ) {
                ship.health -= damage;
            }
            if ( ship.health <= 0 ) {
               ship.health = 0;
               canvas.state = "NotStartedState"
               message("<center>Game Over</center>\n<center>" + ship.playername + " died first.</center>", 5000);
            }
            if ( damage > 0 ) {
                wallCollisionFeedback([ship.x+ship.radius, ship.y+ship.radius], Math.round(damage), ship.playercolor);
            }
        }
        
        function applyDamageFromWallCollision(ship) {
            console.log(ship.velocity);
            var damage = ( Math.pow(ship.velocity[0], 2) + Math.pow(ship.velocity[1], 2) ) * 30;
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
                // make sure we are not f*cked by the "center" being in top-left corner
                var offset = ship.radius*Math.sqrt(2);
                var other_offset = other.radius*Math.sqrt(2);
                var p1 = [ship.position[0]+offset, ship.position[1]+offset];
                var p2 = [other.position[0]+other_offset, other.position[1]+other_offset];
                var collision_normal = [(p1[0]-p2[0])/distance, (p1[1]-p2[1])/distance];
                // simple circle-collision with equal masses:
                // swap velocities in normal direction and reflect in tangent direction
                var v1_n = [(ship.velocity[0]*collision_normal[0] + ship.velocity[1]*collision_normal[1])*collision_normal[0],
                            (ship.velocity[0]*collision_normal[0] + ship.velocity[1]*collision_normal[1])*collision_normal[1]];
                var v2_n = [(other.velocity[0]*collision_normal[0] + other.velocity[1]*collision_normal[1])*collision_normal[0], 
                            (other.velocity[0]*collision_normal[0] + other.velocity[1]*collision_normal[1])*collision_normal[1]];
                var v1_t = [-(-ship.velocity[0]*collision_normal[1] + ship.velocity[1]*collision_normal[0])*collision_normal[1], 
                            (-ship.velocity[0]*collision_normal[1] + ship.velocity[1]*collision_normal[0])*collision_normal[0]];
                var v2_t = [-(-other.velocity[0]*collision_normal[1] + other.velocity[1]*collision_normal[0])*collision_normal[1], 
                            (-other.velocity[0]*collision_normal[1] + other.velocity[1]*collision_normal[0])*collision_normal[0]];
                console.log("COLLISION!");
                ship.recentlyCrashed = -500/timeInterval; // half a second
                other.recentlyCrashed = -500/timeInterval;
                ship.reducedDamage = -900/timeInterval; // almost a second no reduced collision damage
                other.reducedDamage = -900/timeInterval;
                ship.velocity =  [v2_n[0] + v1_t[0], v2_n[1] + v1_t[1]];
                other.velocity = [v1_n[0] + v2_t[0], v1_n[1] + v2_t[1]];
                // avoid penetration: move players apart
                // half the penetration depth with some "offset factor"
                // penetration_vec has half pen. depth as magnitude, then
                var penetration_norm = (effective_radius - distance)*2;
                var penetration_vec = [collision_normal[0]*penetration_norm, collision_normal[1]*penetration_norm];
                ship.position = [p1[0] + penetration_vec[0] - offset, p1[1] + penetration_vec[1] - offset];
                other.position = [p2[0] - penetration_vec[0] - other_offset, p2[1] - penetration_vec[1] - other_offset];
                wallCollisionFeedback([(ship.x+other.x)/2, (ship.y+other.y)/2], "", Qt.rgba(0, 0, 0, 1)); // don't display text
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
        y: 5
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