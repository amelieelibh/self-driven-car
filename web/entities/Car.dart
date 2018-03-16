library com.aebh.selfdrivencar.entities;

import 'package:phaser/phaser.dart' show Game, PhaserSprite, Group, Physics;

class Car {
  static const ROTATION_VEL = 50;

  bool alive;
  int health=100;
  var currentSpeed = 0;
  
  Game game;
  PhaserSprite shadow;
  PhaserSprite sprite;


  Car(Game game) {
    var x = 0;
    var y = 0;
    this.game = game;
    this.health = 100;
    this.alive = true;

    this.shadow = game.add.sprite(x, y, 'shadow', 'shadow');
    this.sprite = game.add.sprite(x, y, 'car', 'car');

    this.sprite.width /= 2;
    this.sprite.height /= 2;

    this.shadow.anchor.setTo(0.5);
    this.sprite.anchor.setTo(0.5);

    this.sprite.name = "car";
    game.physics.enable(this.sprite, Physics.ARCADE);
    game.physics.arcade.gravity.y = 0;
    this.sprite.body.immovable = false;
    this.sprite.body.collideWorldBounds = true;
    this.sprite.body.bounce.setTo(1, 1);
    this.sprite.body.drag.setTo(0.2);
    this.sprite.body.maxVelocity.setTo(400, 400);
    this.sprite.body.collideWorldBounds = true;

    this.sprite.angle = 0;//game.rnd.angle();

    this.sprite.bringToTop();

    game.physics.arcade.velocityFromRotation(this.sprite.rotation, ROTATION_VEL, this.sprite.body.velocity);
  }
  
  damage (num damageAmount) {
      this.health -= damageAmount;
      if (this.health <= 0)
      {
          this.alive = false;
        //   this.shadow.kill();
        //   this.sprite.kill();
          return true;
      }
      return false;
  }

  update (var cursors) {
    if(!alive) return;

    if (cursors.left.isDown) {
      sprite.angle -= 4;
    } else if (cursors.right.isDown) {
      sprite.angle += 4;
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
      game.physics.arcade.velocityFromRotation(sprite.rotation, currentSpeed, sprite.body.velocity);
    }

    if (game.input.activePointer.isDown) {
      //  Boom!
      switchLightsOn(game);
    }

    //   this.sprite.body.collideWorldBounds = false;
    this.shadow.x = this.sprite.x;
    this.shadow.y = this.sprite.y;
    this.shadow.rotation = this.sprite.rotation;
  }
}

bool switchLightsOn(Game game){
    return false;
}