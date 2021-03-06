library com.aebh.selfdrivencar.states;

import 'package:phaser/phaser.dart' show Game, Group, Physics, PhaserSprite, Rectangle;
import 'dart:html' show window;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import '../entities/Tanks.dart';

class TankState {

  var land;

  var shadow;
  PhaserSprite tank;
  var turret;

  List<EnemyTank> enemies;
  Group enemyBullets;
  var enemiesTotal = 0;
  var enemiesAlive = 0;
  Group explosions;

  var logo;

  var currentSpeed = 0;
  var cursors;

  Group bullets;
  var fireRate = 300;
  var nextFire = 0;

  TankState(){
  }

  preload(Game game) { 
    
    print("preload");
    game.load.atlas('tank', 'assets/games/tanks/tanks.png', 'assets/games/tanks/tanks.json');
    game.load.atlas('enemy', 'assets/games/tanks/enemy-tanks.png', 'assets/games/tanks/tanks.json');
    game.load.image('logo', 'assets/games/tanks/logo.png');
    game.load.image('bullet', 'assets/games/tanks/bullet.png');
    game.load.image('earth', 'assets/games/tanks/scorched_earth.png');
    game.load.spritesheet('kaboom', 'assets/games/tanks/explosion.png', 64, 64, 23);

  }

  create(Game game) {
    print("Driver State Create");
    //  Resize our game world to be a 2000 x 2000 square
    game.world.setBounds(-1000, -1000, 2000, 2000);

    //  Our tiled scrolling background
    land = game.add.tileSprite(0, 0, window.innerWidth, window.innerHeight, 'earth');
    land.fixedToCamera = true;

    //  The base of our tank
    tank = game.add.sprite(0, 0, 'tank', 'tank1');
    tank.anchor.setTo(0.5, 0.5);
    tank.animations.add('move', ['tank1', 'tank2', 'tank3', 'tank4', 'tank5', 'tank6'], 20, true);

    //  This will force it to decelerate and limit its speed
    game.physics.enable(tank, Physics.ARCADE);
    game.physics.arcade.gravity.y = 0;
    tank.body.drag.setTo(0.2);
    tank.body.maxVelocity.setTo(400, 400);
    tank.body.collideWorldBounds = true;

    //  Finally the turret that we place on-top of the tank body
    turret = game.add.sprite(0, 0, 'tank', 'turret');
    turret.anchor.setTo(0.3, 0.5);

    //  The enemies bullet group
    enemyBullets = game.add.group();
    enemyBullets.enableBody = true;
    enemyBullets.physicsBodyType = Physics.ARCADE;
    enemyBullets.createMultiple(100, 'bullet');

    enemyBullets.forEach(allowInterop((PhaserSprite s){
      s.anchor.setTo(0.5);
      s.outOfBoundsKill=true;
      s.checkWorldBounds=true;
    }), null);
    enemyBullets.setAll('anchor.x', 0.5);
    enemyBullets.setAll('anchor.y', 0.5);
    enemyBullets.setAll('outOfBoundsKill', true);
    enemyBullets.setAll('checkWorldBounds', true);

    //  Create some baddies to waste :)
    enemies = [];

    enemiesTotal = 25;
    enemiesAlive = 25;

    for (var i = 0; i < enemiesTotal; i++) {
      enemies.add(new EnemyTank(i, game, tank, enemyBullets));
    }

    //  A shadow below our tank
    shadow = game.add.sprite(0, 0, 'tank', 'shadow');
    shadow.anchor.setTo(0.5, 0.5);

    //  Our bullet group
    bullets = game.add.group();
    bullets.enableBody = true;
    bullets.physicsBodyType = Physics.ARCADE;
    bullets.createMultiple(30, 'bullet', 0, false);
    
    bullets.forEach(allowInterop((PhaserSprite s){
      s.anchor.setTo(0.5);
      s.outOfBoundsKill=true;
      s.checkWorldBounds=true;
    }), null);


    //  Explosion pool
    explosions = game.add.group();

    for (var i = 0; i < 10; i++) {
      var explosionAnimation = explosions.create(0, 0, 'kaboom', 0, false);
      explosionAnimation.anchor.setTo(0.5, 0.5);
      explosionAnimation.animations.add('kaboom');
    }

    tank.bringToTop();
    turret.bringToTop();

    logo = game.add.sprite(0, 200, 'logo');
    logo.fixedToCamera = true;

    game.input.onDown.add(allowInterop(removeLogo), null, null, game);
    
    game.camera.follow(tank);
    game.camera.deadzone = new Rectangle(window.innerWidth*.4, window.innerWidth*.4, window.innerWidth*.2, window.innerWidth*.2);
    game.camera.focusOnXY(0, 0);

    cursors = game.input.keyboard.createCursorKeys();
    print("Driver State Created");
  }
  
  //@JS("removeLogo")
  removeLogo(p,e, Game game) {

    game.input.onDown.remove(allowInterop(removeLogo));
    logo.kill();

  }

  //@JS()
  update(Game game) {
    game.physics.arcade.overlap(enemyBullets, tank, allowInterop(bulletHitPlayer), null);

    enemiesAlive = 0;

    if(enemies != null){
      for (var i = 0; i < enemies.length; i++) {
        if (enemies[i].alive) {
          enemiesAlive++;
          game.physics.arcade.collide(tank, enemies[i].tank);
          game.physics.arcade.overlap(bullets, enemies[i].tank, allowInterop(bulletHitEnemy), null);
          enemies[i].update();
        }
      }
    }

    if (cursors.left.isDown) {
      tank.angle -= 4;
    } else if (cursors.right.isDown) {
      tank.angle += 4;
    }

    if (cursors.up.isDown) {
      //  The speed we'll travel at
      currentSpeed = 300;
    } else {
      if (currentSpeed > 0) {
        currentSpeed -= 4;
      }
    }

    if (currentSpeed > 0) {
      game.physics.arcade.velocityFromRotation(tank.rotation, currentSpeed, tank.body.velocity);
    }

    land.tilePosition.x = -game.camera.x;
    land.tilePosition.y = -game.camera.y;

    //  Position all the parts and align rotations
    shadow.x = tank.x;
    shadow.y = tank.y;
    shadow.rotation = tank.rotation;

    turret.x = tank.x;
    turret.y = tank.y;

    turret.rotation = game.physics.arcade.angleToPointer(turret);

    if (game.input.activePointer.isDown) {
      //  Boom!
      fire(game);
    }
  }

  //@JS()
  bulletHitPlayer(tank, bullet) {

    bullet.kill();

  }
  
  bulletHitEnemy(tank, bullet) {

    bullet.kill();
    var destroyed = enemies[int.parse(tank.name)].damage();

    if (destroyed) {
      var explosionAnimation = explosions.getFirstExists(false);
      explosionAnimation.reset(tank.x, tank.y);
      explosionAnimation.play('kaboom', 30, false, true);
    }
  }
  

  fire(Game game) {

    if (game.time.now > nextFire && bullets.countDead() > 0) {
      nextFire = game.time.now + fireRate;

      var bullet = bullets.getFirstExists(false);

      bullet.reset(turret.x, turret.y);

      bullet.rotation = game.physics.arcade.moveToPointer(bullet, 1000, game.input.activePointer, 500);
    }

  }

  //@JS()
  render(Game game) {

    // game.debug.text('Active Bullets: ' + bullets.countLiving() + ' / ' + bullets.length, 32, 32);
    game.debug.text('Enemies: ' + enemiesAlive.toString() + ' / ' + enemiesTotal.toString(), 32, 32);

  }
  
  dynamic jsonMap(){
    return jsify({'preload': allowInterop(preload), 
            'create' : allowInterop(create),
            'update' : allowInterop(update), 
            'render' : allowInterop(render)});
  }
}
