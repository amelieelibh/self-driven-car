library com.aebh.selfdrivencar.states;

import 'package:phaser/phaser.dart' show Game, Group, Tilemap, PhaserPoint, Rectangle, Button;
import 'dart:html' show window;
import 'dart:mirrors'; 
import 'package:js/js.dart';
import 'package:js/js_util.dart';
// import '../entities/Car.dart';
import '../entities/Vehicle.dart';

class DriverState {

  Vehicle car;
  var land;
  var map;
  var layer;
  var maker;
  Group explosions;

//  var logo;

  var cursors;
  Button joystick;
  PhaserPoint joystickPos;
  bool isJoystickOn = false;

  double up = 0.0,    swUp = 0.0;
  double down = 0.0,  swDown = 0.0;
  double left = 0.0,  swLeft = 0.0;
  double right = 0.0, swRight = 0.0;

  DriverState(){
  }

  preload(Game game) { 
    
    game.load.image('shadow', 'assets/sprites/shadow.png');
    game.load.image('logo', 'assets/games/tanks/logo.png');
    game.load.image('earth', 'assets/games/tanks/scorched_earth.png');
    game.load.spritesheet('kaboom', 'assets/games/tanks/explosion.png', 64, 64, 23);

    game.load.tilemap('map', 'assets/sprites/course1.json', null, Tilemap.TILED_JSON);
    game.load.image('tiles', 'assets/sprites/track.png');

    //gamepad buttons
    game.load.spritesheet('joystick', 'assets/sprites/joystick.png', 136, 134);

    
    game.load.image("PatitoX1", 'assets/sprites/car1.png');
  }

  create(Game game) {
    print("Driver State Create");
    //  Resize our game world to be a 4920 x 4920 square
    game.world.setBounds(-2460, -2460, 2460, 2460);

    //  Our tiled scrolling background
    // land = game.add.tileSprite(0, 0, window.innerWidth, window.innerHeight, 'earth');
    // land.fixedToCamera = true;

    map = game.add.tilemap('map');

    map.addTilesetImage('tiles');
    // map.setCollisionBetween(1, 12);
    layer = map.createLayer('Course Test');
    layer.resizeWorld();

    game.input.onDown.add(allowInterop(removeLogo), null, null, game);

    //Creating car
    // car = new Car(game);
    car = Vehicle.VEHICLE_SPORT_CAR;
    car.initialize(game, -2200, -2200);

    game.camera.follow(car.sprite);
    game.camera.deadzone = new Rectangle(window.innerWidth*.4, window.innerWidth*.4, window.innerWidth*.2, window.innerWidth*.2);
    game.camera.focusOnXY(0, 0);

    cursors = game.input.keyboard.createCursorKeys();
    
    joystickPos = new PhaserPoint(window.innerWidth/2, window.innerHeight - 150);
    joystick = game.add.sprite(joystickPos.x, joystickPos.y, 'joystick');
    joystick.anchor.setTo(0.5);
    joystick.inputEnabled = true;
    joystick.fixedToCamera = true;
    joystick.input.pixelPerfectOver = true;
    //  Enable the hand cursor
    joystick.input.useHandCursor = true;

    // joystick.events.onInputOver.add(allowInterop(onDragJoystick));
    // joystick.events.onInputOut.add(allowInterop(onDragEndJoystick));
    // joystick.events.onDragUpdate.add(allowInterop(onDragJoystick));
    // joystick.events.onInputDown.add(allowInterop(onDragJoystick));
    joystick.events.onInputUp.add(allowInterop(onDragEndJoystick));
    joystick.events.onInputDown.add(allowInterop((sprite, point){
      isJoystickOn = true;
      onDragJoystick(point, point.x, point.y);
    }));
    game.input.addMoveCallback(allowInterop(onDragJoystick), this);
    // joystick.input.allowHorizontalDrag = true;
    // joystick.input.allowVerticalDrag = true;
    

    print("Driver State Created");
  }
  
  
  onDragEndJoystick(var sprite, var point, [bool b]){
    swUp = swDown = swLeft = swRight = 0.0;
    print("reset to swUp=$swUp, swDown=$swDown, swLeft=$swLeft, swRight=$swRight");
    isJoystickOn = false;
  }
  // onDragJoystick(var sprite, var point
  onDragJoystick(var point, var x, var y, [bool b]){
    if(!isJoystickOn){
      return;
    }
    swUp = swDown = swLeft = swRight = 0.0;
    // print("joystic.pos=${sprite.x},${sprite.y}");
    // print("point.pos=${sprite.input.pointerX()},${sprite.input.pointerY()} >> ${point.clientX},${point.clientY}");
    print("joystic.pos=${joystickPos.x},${joystickPos.y}");
    print("point.pos=${point.clientX},${point.clientY}");
    if(point.clientX > joystickPos.x){
    // if(sprite.input.pointerX()>0){
        swRight = 1.0;
    }
    if(point.clientX < joystickPos.x){
    // if(sprite.input.pointerX()<0){
        swLeft = 1.0;
    }
    if(point.clientY > joystickPos.y){
    // if(sprite.input.pointerY()>0){
        swDown = 1.0;
    }
    if(point.clientY < joystickPos.y){
    // if(sprite.input.pointerY()<0){
        swUp = 1.0;
    }
    print("swUp=$swUp, swDown=$swDown, swLeft=$swLeft, swRight=$swRight");
  }

  //@JS("removeLogo")
  removeLogo(p,e, Game game) {
    game.input.onDown.remove(allowInterop(removeLogo));
    // logo.kill();
  }

  resetDirectionals(){
    up = 0.0; down = 0.0; left = 0.0; right = 0.0;
  }
  //@JS()
  update(Game game) {
    resetDirectionals();
    //game.physics.arcade.overlap(enemyBullets, tank, allowInterop(bulletHitPlayer), null);
    if(cursors != null){
      
      if(cursors.up.isDown){
        up = 1.0;
      }
      if(cursors.down.isDown){
        down = 1.0;
      }
      
      if(cursors.left.isDown){
        left = 1.0;
      }
      if(cursors.right.isDown){
        right = 1.0;
      }
    }
    
    // land.tilePosition.x = -game.camera.x;
    // land.tilePosition.y = -game.camera.y;
    car.update(
      up > 0 ? up : swUp, 
      down > 0 ? down : swDown, 
      left > 0 ? left : swLeft, 
      right > 0 ? right : swRight);
  }

  //@JS()
  render(Game game) {

    // game.debug.text('Active Bullets: ' + bullets.countLiving() + ' / ' + bullets.length, 32, 32);
    game.debug.text('Status: ' + car.health.toString(), 32, 32);
    game.debug.text('x: ' + joystick.input.snapX.toString(), 5, 15);     
    game.debug.text('y: ' + joystick.input.snapY.toString(), 5, 30);

    game.debug.spriteInputInfo(joystick, 32, 64);
    // game.debug.geom(joystick.input._tempPoint);

  }
  
  dynamic jsonMap(){
    return jsify({'preload': allowInterop(preload), 
            'create' : allowInterop(create),
            'update' : allowInterop(update), 
            'render' : allowInterop(render)});
  }
}
