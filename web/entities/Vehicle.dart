library com.aebh.selfdrivencar.entities;

import 'package:phaser/phaser.dart' show Game, PhaserSprite, PhaserPoint, Physics;

class Vehicle{
  static const double MAX_DIST = 999.9;
  static const double HYST_DIST = 2.0;
  static const double C_FRICTION = 0.9;
  static const double GRAVITY = 9.80;
  static const ROTATION_VEL = 50;

  bool alive;
  int health=100;
  
  Game game;
  PhaserSprite shadow;
  PhaserSprite sprite;


  final String brand;
  final String model;
  final int _width;
  final int _height;
  final int _gearsNum; //between 0 and n, -1 by default
  final int _maxRPM;
  final int _minOptimalRPM;
  final int _maxOptimalRPM; 
  final int _maxSpeed; //km/h
  final int _hp; //horse power
  final double _turningRadius; //m
  final int _weight; //kg

  double TURN_ANGLE_SPEED = 2.0;

  // int speed = 0;
  double currentSpeed = 0.0;
  int currentRPM = 0;
  double totalStoppingDist = 0.0;
  int currentGear = 0;

  List<double> proximitySensorFL = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
  List<double> proximitySensorFR = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
  List<double> proximitySensorBL = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
  List<double> proximitySensorBR = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
  
  int lastTimeUpdate = 0;

  Vehicle(this.brand, this.model, this._width, this._height, this._gearsNum, 
      this._maxRPM, this._minOptimalRPM, this._maxOptimalRPM, this._maxSpeed, this._hp,
      this._turningRadius, this._weight){
    TURN_ANGLE_SPEED = 2 * 3.1415 / _turningRadius;
  }
  initialize(Game game, int x, int y){

    String spritename = brand+model;

    this.game = game;
    this.health = 100;
    this.alive = true;

    this.shadow = game.add.sprite(x, y, 'shadow', 'shadow');
    this.sprite = game.add.sprite(x, y, spritename, spritename);
    this.sprite.name = spritename;
    
    this.shadow.anchor.setTo(0.5);
    this.sprite.anchor.setTo(0.5);

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

    game.physics.arcade.velocityFromRotation(this.sprite.rotation, 
        100 - 3.1416 * _turningRadius * _turningRadius, this.sprite.body.velocity);
  }

  List<double> checkForCollisionDanger(){
      List<double> dangers = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
      updateStoppingDistance();
      if(currentSpeed > 0){
          for(var sensorVal in proximitySensorFL){
              if(HYST_DIST + totalStoppingDist >= sensorVal && sensorVal < dangers[0]){
                  dangers[0] = sensorVal.toDouble();
              }
          }
          for(var sensorVal in proximitySensorFR){
              if(HYST_DIST + totalStoppingDist >= sensorVal && sensorVal < dangers[1]){
                  dangers[1] = sensorVal;
              }
          }
      }else if(currentSpeed < 0){
          for(var sensorVal in proximitySensorBL){
              if(HYST_DIST + totalStoppingDist >= sensorVal && sensorVal < dangers[2]){
                  dangers[3] = sensorVal;
              }
          }
          for(var sensorVal in proximitySensorBR){
              if(HYST_DIST + totalStoppingDist >= sensorVal && sensorVal < dangers[3]){
                  dangers[0] = sensorVal;
              }
          }
      }
      return dangers;
  }

  update (double up, double down, double left, double right) {
    if(!alive) return;
    if(lastTimeUpdate == 0 |0| lastTimeUpdate + 1000 < game.time.now.toInt()){
      lastTimeUpdate = game.time.now.toInt();
    }

    if((currentSpeed).abs() -10 > 0){
      if (left > 0) {
        sprite.angle -= TURN_ANGLE_SPEED * left;
      } else if (right > 0) {
        sprite.angle += TURN_ANGLE_SPEED * right;
      }
    }

    updateGear(game, up, down);
    if (up > 0) {
      accelerateSpeed(up);
    } 
    if (down > 0) {
      if(currentSpeed > 0){
        brake();
      }else{
        accelerateSpeed(-down);
      }
    } 
    if(up <= 0 && down <= 0){
      accelerateSpeed(0.0);
    }

    game.physics.arcade.velocityFromRotation(sprite.rotation, currentSpeed * 4, sprite.body.velocity);

    if (game.input.activePointer.isDown) {
      //  Boom!
      switchLightsOn(game);
    }

    //   this.sprite.body.collideWorldBounds = false;
    this.shadow.x = this.sprite.x;
    this.shadow.y = this.sprite.y;
    this.shadow.rotation = this.sprite.rotation;
  }

  updateStoppingDistance(){
      // v is required in m/s so convert 1km/hr to m/s
      var v = currentSpeed * (1000 / 60 / 60);
      var d = v * v / (2 * getCurrentCoefficientOfFriction() * GRAVITY);
      this.totalStoppingDist = d;
  }

  double getCurrentCoefficientOfFriction(){
      return C_FRICTION; // * 0.75;
  }

  brake(){
    this.currentSpeed = this.currentSpeed * (1 - C_FRICTION/10);
    this.currentRPM = (this.currentRPM * ((1 - C_FRICTION/10))).toInt();
  }

  accelerateSpeed(double gasPedal){
    // if(lastTimeUpdate - game.time.now.toInt() > -1000){
      // return;
    // }
      // print("currentRPM=$currentRPM gasPedal=$gasPedal _maxRPM=$_maxRPM");
      if(gasPedal != 0){
        if(this.currentRPM < this._maxRPM){
          this.currentRPM = (this.currentRPM * (1 + gasPedal.abs() * _maxRPM * _gearsNum / (600000 * (currentGear > 1 ? currentGear : 1)))).toInt();
        }else{
          this.currentRPM = this._maxRPM;
        }
      }else {
        this.currentRPM = (this.currentRPM * 0.9).toInt();
      }
      if(this.currentRPM < 450){
        this.currentRPM = 450;
      }
      
      // v1 = v0 + 0.001341 * HP? * 5252 * (RPM? / 60 min)  * (gear? / 3) / (masa? * C_FRICTION) / (1000 m)
      if(this.currentSpeed <= _maxSpeed){
        if(gasPedal != 0.0){
          if(this.currentSpeed == 0.0 && gasPedal > 0){
            this.currentSpeed = 10.0;
          }
          this.currentSpeed = this.currentSpeed + 0.001341 * 5252 * _hp * currentRPM * currentGear / (3 * _weight * 1000);
        }else{
          // print("deaccel=${currentRPM / (3 * _weight * 1000 * this._maxRPM)}");
          this.currentSpeed = this.currentSpeed * .999;
        }
      }
      var maxCurrentSpeed = (this.currentGear / this._gearsNum) * _maxSpeed;
      if(this.currentSpeed.abs() > maxCurrentSpeed.abs()){
          this.currentSpeed = maxCurrentSpeed;
      }
      // print("speed=$currentSpeed");
  }

  updateGear(Game game, double up, double down){
    // if(lastTimeUpdate - game.time.now.toInt() <= -1000)
    if(up > 0 && this.currentGear < this._gearsNum){
      if(this.currentGear == 0){
        this.currentGear = 1;
        this.currentRPM ~/= 10;
      }else if(this.currentRPM > _maxOptimalRPM){
        this.currentGear++;
        this.currentRPM ~/= (this.currentGear == 0 ? 1 : this.currentGear);
      }else if(this.currentRPM > _minOptimalRPM && this.currentRPM < this._maxOptimalRPM){
        if(evaluateIfNextGear(game)){
          this.currentGear++;
          this.currentRPM ~/= (this.currentGear == 0 ? 1 : this.currentGear);
        }
      }      
    }else if(up == 0){
      if( currentGear > 3 && this.currentRPM < this._minOptimalRPM){
        if(evaluateIfPrevGear(game)){
          this.currentGear--;
          this.currentRPM *= this.currentGear;
        }
      }else if(currentGear >= 1 && this.currentRPM < 500){
        if(evaluateIfPrevGear(game)){
          this.currentGear--;
          this.currentRPM *= this.currentGear;
        }
      }
    }
    if(down > 0 && currentGear == 0){
      this.currentGear = -1;
    }else if(down == 0 && currentGear == -1 && currentRPM < 500){
      if(evaluateIfNextGear(game)){
        this.currentGear = 0;
      }
    }
  }

  bool evaluateIfNextGear(Game game){
    return (game.rnd.integerInRange(0, 100) > 85);
  }
  bool evaluateIfPrevGear(Game game){
    return (game.rnd.integerInRange(0, 100) > 95);
  }

  damage (num damageAmount) {
      /*this.health -= damageAmount;
      if (this.health <= 0)
      {
          this.alive = false;
        //   this.shadow.kill();
        //   this.sprite.kill();
          return true;
      }*/
      return false;
  }
  
  bool switchLightsOn(Game game){
      return false;
  }

  static final VEHICLE_SPORT_CAR = new Vehicle("Patito","X1", 107, 58, 5, 9000, 4000, 5500, 240, 200, 4.5, 2500);
}