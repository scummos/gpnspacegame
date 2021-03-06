import QtQuick 1.1
import Qt 4.7

Rectangle {
    id: canvas
    width: 600
    height: 600
    color: "#333333"
    state: "NotStartedState"
    
    property variant pressedKeys: {}
    
    states: [
        State {
            name: "NotStartedState"
            PropertyChanges { target: startGameBanner; visible: true }
            PropertyChanges { target: startGameText; text: "Press Spacebar to start a new game, F1 for help" }
        },
        State {
            name: "GameRunningState"
            PropertyChanges { target: messagebox; visible: false }
            PropertyChanges { target: startGameBanner; visible: false }
            PropertyChanges { target: help; state: "NotVisibleState" }
        },
        State {
            name: "DemoState"
            PropertyChanges { target: messagebox; visible: false }
            PropertyChanges { target: startGameBanner; visible: true }
            PropertyChanges { target: help; state: "NotVisibleState" }
            PropertyChanges { target: startGameText; text: "Demo mode - press any key" }
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
            z: 100
            id: help
            y: -200
            anchors.horizontalCenter: parent.horizontalCenter
            state: "NotVisibleState"
            states: [
                State {
                    name: "NotVisibleState"
                    PropertyChanges { target: help; y: -200 }
                    PropertyChanges { target: help; opacity: 0 }
                },
                State {
                    name: "VisibleState"
                    PropertyChanges { target: help; y: 0 }
                    PropertyChanges { target: help; opacity: 1 }
                }
            ]
            Behavior on y {
                NumberAnimation { duration: 200 }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            Text {
                y: 20
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.family: "georgia"
                text: "<center>Hit your enemy to make him crash into walls!</center>\n"+
                      "<center>You can move around and use a Bash to kick the enemy away a bit (every 8 seconds).</right>\n"+
                      "<center>Player 1 controls: Arrow keys + AltGr (Bash)</center>\n"+
                      "<center>Player 2 controls: WASD + Shift (Bash)</center>\n"+
                      "<center>The faster you hit a wall, the more damage you take.</center>\n"+
                      "<center>If you recently collided with an enemy, more damage will be dealt by crashes.</center>\n"
//                       "<center>Flying fast regenerates hitpoints.</center>\n"
            }
        }
        
        Rectangle {
            id: "arena_obstacle"
            color: canvas.color
            radius: 50
            x: arena.width/2-radius
            y: arena.height/2-radius
            width: radius*2
            height: radius*2
        }
        
        Rectangle {
            id: startGameBanner;
            z:200
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                id: startGameText;
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
                font.family: "georgia"
                text:"Press Spacebar to start a new game, F1 for help"
                
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
            var exclusiveKeys = [
                [Qt.Key_Right, Qt.Key_Left],
                [Qt.Key_Up, Qt.Key_Down],
                [Qt.Key_A, Qt.Key_D],
                [Qt.Key_W, Qt.Key_S]
            ]
            var keymap = new Object()
            
            for( var idx in canvas.pressedKeys ) {
                keymap[idx] = canvas.pressedKeys[idx];
            }
            if ( eventType == "pressed" ) {
                for ( var i = 0; i < 4; i++ ) {
                    for ( var j = 0; j < 2; j++ )  {
                        if ( event.key == exclusiveKeys[i][j] && canvas.pressedKeys[exclusiveKeys[i][1-j]] == true ) {
//                             console.log("collision detected");
                            keymap[exclusiveKeys[i][1-j]] = 0;
                            keymap[exclusiveKeys[i][j]] = 0;
                        }
                    }
                }
                keymap[event.key] = 1;
            }
            else if ( eventType == "released" ) {
                keymap[event.key] = 0;
            }
            canvas.pressedKeys = keymap
        }
        
        function newGame() {
            console.log("new game started");
            canvas.state = "GameRunningState"
            for ( var i = 0; i < 2; i++ ) {
                players.children[i].health = 100;
                players.children[i].velocity = [0, 0]
                players.children[i].acceleration = [0, 0]
                players.children[i].healthbar().resetBash();
                players.children[i].boostCooldown = 0;
            }
            players.children[0].position = [50, 50]
            players.children[1].position = [450, 450]
        }
        
        Timer {
            id: demoTimer
            interval: 200; running: false; repeat: true
            onTriggered: {
                for ( var i = 0; i < 2; i++ ) {
                    players.children[i].tick();
                    var currentAccel = players.children[i].acceleration;
                    var distance = Math.sqrt(Math.pow(players.children[i].position[0]-players.children[1-i].position[0], 2)
                                  +Math.pow(players.children[i].position[1]-players.children[1-i].position[1], 2));
                    var direction = [0, 0]
                    for ( var k = 0; k < 2; k++ ) {
                        direction[k] = players.children[i].position[k]-players.children[1-i].position[k];
                        direction[k] /= distance;
                        currentAccel[k] += (Math.random()-0.5)*0.4 - (players.children[i].position[k]-300)/600*0.35 - direction[k]*0.01;
                        currentAccel[k] *= Math.random() * 0.4;
                    }
                    players.children[i].acceleration = currentAccel;
                }
            }
        }
        
        Keys.onPressed: {
            if ( canvas.state == "NotStartedState" ) {
                if ( event.key == Qt.Key_Space ) {
                    newGame();
                }
                if ( event.key == Qt.Key_F2 ) {
                    demoTimer.start();
                    canvas.state = "DemoState";
                }
                if ( event.key == Qt.Key_F1 ) {
                    if ( help.state == "VisibleState" ) {
                        help.state = "NotVisibleState";
                    }
                    else {
                        help.state = "VisibleState";
                    }
                }
            }
            else if ( canvas.state == "DemoState" ) {
                canvas.state = "NotStartedState";
                demoTimer.stop();
            }
            else if ( canvas.state == "GameRunningState" ) {
                if ( event.key == Qt.Key_Escape  ) {
                    canvas.state = "NotStartedState";
                    message("<center>QSwoosh</center>");
                }
                if ( event.key == Qt.Key_Shift ) {
                    players.children[1].tryBoost(players.children[0]);
                }
                if ( event.key == Qt.Key_AltGr ) {
                    players.children[0].tryBoost(players.children[1]);
                }
            }
            doHandleKey(event, "pressed")
            event.accepted = true;
        }
        
        Keys.onReleased: {
            doHandleKey(event, "released")
            event.accepted = true;
        }
        
        Text {
            z:200
            id: messagebox
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            opacity:1
            font.family: "georgia"
            Behavior on opacity {
                NumberAnimation {
                    duration:300
                }
            }
            font.pointSize:27
            color:"white"
            text:"<center>QSwoosh</center>"
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
            var damage = ( Math.pow(ship.velocity[0], 2) + Math.pow(ship.velocity[1], 2) ) * 30;
            ouch(ship, damage);
            return damage
        }
        
        function reflect(ship, normal) {
            var damage = applyDamageFromWallCollision(ship);
            var dampening = 0.75;
            // extra dampening on heavy damages
            if ( damage > 15 ) {
                dampening = 0.25*Math.exp(-(damage-15)/10.0) + 0.5
            }
            
            // reflect the ship along collision normal
            var v_n_fac = ship.velocity[0]*normal[0] + ship.velocity[1]*normal[1];
            var v_t_fac = -ship.velocity[0]*normal[1] + ship.velocity[1]*normal[0];
            var v_n = [v_n_fac*normal[0], v_n_fac*normal[1]];
            var v_t = [-v_t_fac*normal[1], v_t_fac*normal[0]];

            ship.velocity = [(-v_n[0] + v_t[0])*dampening, (-v_n[1] + v_t[1])*dampening];
        }
        
        function eventuallyHandleArenaCollision(ship) {
            if ( ship.x + ship.radius*2 > width || ship.x < 0 ) {
                reflect(ship, [1, 0]);
                var pos = ship.position;
                if(ship.x < 0)
                    pos[0] = 0;
                else
                    pos[0] = width - ship.radius*2;
                ship.position = pos;
            }
            if ( ship.y + ship.radius*2 > height || ship.y < 0 ) {
                reflect(ship, [0, 1]);
                var pos = ship.position;
                if(ship.y < 0)
                    pos[1] = 0;
                else
                    pos[1] = height - ship.radius*2;
                ship.position = pos;
            }
            var arena_obstacle_dist = Math.sqrt(Math.pow(ship.position[0]-arena_obstacle.x+arena.x/2-arena_obstacle.radius, 2)
                                    + Math.pow(ship.position[1]-arena_obstacle.y+arena.y/2-arena_obstacle.radius, 2))
            if( arena_obstacle_dist < ship.radius + arena_obstacle.radius ) {
                var normal = [(ship.x-arena_obstacle.x+arena.x/2-arena_obstacle.radius)/arena_obstacle_dist,
                              (ship.y-arena_obstacle.y+arena.y/2-arena_obstacle.radius)/arena_obstacle_dist]
                reflect(ship, normal);
                var pos = ship.position;
                // move the ship out of the obstacle
                var factor = (ship.radius + arena_obstacle.radius - arena_obstacle_dist)*1.1
                ship.position = [pos[0]+normal[0]*factor, pos[1]+normal[1]*factor];
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
                console.log("BANG!");
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