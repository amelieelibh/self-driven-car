library com.aebh.selfdrivencar.states;

import 'package:phaser/phaser.dart' show Game, Group, Tilemap, PhaserSprite, Rectangle;
import 'dart:html' show window;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import '../entities/Car.dart';

class DriverState {

  Car car;
  var land;
  var map;
  var layer;
  var maker;
  Group explosions;

//  var logo;

  var cursors;

  DriverState(){
  }

  preload(Game game) { 
    game.load.image('car', 'assets/sprites/car1.png');
    game.load.image('shadow', 'assets/sprites/shadow.png');
    game.load.image('logo', 'assets/games/tanks/logo.png');
    game.load.image('earth', 'assets/games/tanks/scorched_earth.png');
    game.load.spritesheet('kaboom', 'assets/games/tanks/explosion.png', 64, 64, 23);

    game.load.tilemap('map', 'assets/sprites/course1.json', null, Tilemap.TILED_JSON);
    game.load.image('tiles', 'assets/sprites/track.png');

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

//  Our painting marker
    // marker = game.add.graphics();
    // marker.lineStyle(2, 0xffffff, 1);
    // marker.drawRect(0, 0, 32, 32);


    // //  Explosion pool
    // explosions = game.add.group();

    // for (var i = 0; i < 10; i++) {
    //   var explosionAnimation = explosions.create(0, 0, 'kaboom', 0, false);
    //   explosionAnimation.anchor.setTo(0.5, 0.5);
    //   explosionAnimation.animations.add('kaboom');
    // }

    // logo = game.add.sprite(0, 200, 'logo');
    // logo.fixedToCamera = true;

    game.input.onDown.add(allowInterop(removeLogo), null, null, game);

    //Creating car
    car = new Car(game);

    game.camera.follow(car.sprite);
    game.camera.deadzone = new Rectangle(window.innerWidth*.4, window.innerWidth*.4, window.innerWidth*.2, window.innerWidth*.2);
    game.camera.focusOnXY(0, 0);

    cursors = game.input.keyboard.createCursorKeys();
    print("Driver State Created");
  }
  
  //@JS("removeLogo")
  removeLogo(p,e, Game game) {
    game.input.onDown.remove(allowInterop(removeLogo));
    // logo.kill();
  }

  //@JS()
  update(Game game) {
    //game.physics.arcade.overlap(enemyBullets, tank, allowInterop(bulletHitPlayer), null);
    if(cursors != null){
      car.update(cursors);
    }
    
    // land.tilePosition.x = -game.camera.x;
    // land.tilePosition.y = -game.camera.y;
  }

  //@JS()
  render(Game game) {

    // game.debug.text('Active Bullets: ' + bullets.countLiving() + ' / ' + bullets.length, 32, 32);
    game.debug.text('Status: ' + car.health.toString(), 32, 32);

  }
  
  dynamic jsonMap(){
    return jsify({'preload': allowInterop(preload), 
            'create' : allowInterop(create),
            'update' : allowInterop(update), 
            'render' : allowInterop(render)});
  }
}
