library com.aebh.selfdrivencar.entities;

import 'package:phaser/phaser.dart' show Game, PhaserSprite, Group, Physics;

class EnemyTank {
  Game game;
  int health=3;
  PhaserSprite player;
  Group bullets;
  num fireRate;
  num nextFire;
  bool alive;
  
  PhaserSprite shadow;
  PhaserSprite tank;
  PhaserSprite turret;
  

  EnemyTank(int index, Game game, PhaserSprite player, Group  bullets) {
    //   print("worldX,worldY=${game.world.width},${game.world.height}");
    var x = game.world.randomX;
    var y = game.world.randomY;
    if(x >= 0 && x < 500){
        x = 500;
    }else if(x < 0 && x > -500){
        x = -500;
    }
    //x = -2000; y = 0;
    // print("x,y=$x,$y");
    this.game = game;
    this.health = 3;
    this.player = player;
    this.bullets = bullets;
    this.fireRate = 1000;
    this.nextFire = 0;
    this.alive = true;

    this.shadow = game.add.sprite(x, y, 'enemy', 'shadow');
    this.tank = game.add.sprite(x, y, 'enemy', 'tank1');
    this.turret = game.add.sprite(x, y, 'enemy', 'turret');
    
    this.shadow.anchor.setTo(0.5);
    this.tank.anchor.setTo(0.5);
    this.turret.anchor.setTo(0.3, 0.5);

    this.tank.name = index.toString();
    game.physics.enable(this.tank, Physics.ARCADE);
    this.tank.body.immovable = false;
    this.tank.body.collideWorldBounds = false;
    this.tank.body.bounce.setTo(1, 1);

    this.tank.angle = game.rnd.angle();

    game.physics.arcade.velocityFromRotation(this.tank.rotation, 50, this.tank.body.velocity);
  }
  
  damage () {

      this.health -= 1;

      if (this.health <= 0)
      {
          this.alive = false;

          this.shadow.kill();
          this.tank.kill();
          this.turret.kill();

          return true;
      }

      return false;

  }

  update () {
      this.tank.body.collideWorldBounds = false;
      //print("tank pos=${this.tank.x},${this.tank.y}");
      this.shadow.x = this.tank.x;
      this.shadow.y = this.tank.y;
      this.shadow.rotation = this.tank.rotation;

      this.turret.x = this.tank.x;
      this.turret.y = this.tank.y;
      this.turret.rotation = this.game.physics.arcade.angleBetween(this.tank, this.player);

      if (this.game.physics.arcade.distanceBetween(this.tank, this.player) < 300)
      {
          if (this.game.time.now > this.nextFire && this.bullets.countDead() > 0)
          {
              this.nextFire = this.game.time.now + this.fireRate;

              var bullet = this.bullets.getFirstDead();

              bullet.reset(this.turret.x, this.turret.y);

              bullet.rotation = this.game.physics.arcade.moveToObject(bullet, this.player, 500);
          }
      }

  }
}