library com.aebh.selfdrivencar.entities;

import 'package:phaser/phaser.dart' show Game, PhaserSprite, PhaserPoint, Physics;

class Vehicle{
  static const double MAX_DIST = 999.9;
  static const double HYST_DIST = 2.0;
  static const double C_FRICTION = 0.9;
  static const double GRAVITY = 9.80;
  static const ROTATION_VEL = 50;
  static const TURN_ANGLE_SPEED = 2;

  bool alive;
  int health=100;
  var currentSpeed = 0;
  
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
  final String _spriteUrl;

  int speed = 0;
  int currentRPM = 0;
  double brake = 0.0;
  double totalStoppingDist = 0.0;
  int currentGear = 0;

  List<double> proximitySensorFL = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
  List<double> proximitySensorFR = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
  List<double> proximitySensorBL = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
  List<double> proximitySensorBR = [MAX_DIST, MAX_DIST, MAX_DIST, MAX_DIST];
  
  Vehicle(this.brand, this.model, this._width, this._height, this._gearsNum, 
      this._maxRPM, this._minOptimalRPM, this._maxOptimalRPM, this._maxSpeed, this._hp,
      this._turningRadius, this._spriteUrl, this._weight);
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
      if(speed > 0){
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
      }else if(speed < 0){
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

    if (left > 0) {
      sprite.angle -= TURN_ANGLE_SPEED;
    } else if (right > 0) {
      sprite.angle += TURN_ANGLE_SPEED;
    }

    if (up > 0) {
      if (currentSpeed >= 300) {
          currentSpeed = 300;
      } else {
          currentSpeed += 20;
      }
    } else if (down > 0) {
      if (currentSpeed <= -150) {
        currentSpeed = -150;
      } else {
        currentSpeed -= 20;
      }
    } else {
      if (currentSpeed > 10) {
        currentSpeed -= 10;
      } else if (currentSpeed < -10) {
        currentSpeed += 10;
      } else {
        currentSpeed = 0;
      }
    }

    game.physics.arcade.velocityFromRotation(sprite.rotation, currentSpeed, sprite.body.velocity);

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
      var v = speed * (1000 / 60 / 60);
      var d = v * v / (2 * getCurrentCoefficientOfFriction() * GRAVITY);
      this.totalStoppingDist = d;
  }

  double getCurrentCoefficientOfFriction(){
      return C_FRICTION; // * 0.75;
  }

  accelerateSpeed(double gasPedal){
      // this.currentRPM = (this.currentRPM * (1 + gasPedal * _maxRPM / 60)).toInt();
      this.currentRPM = (this.currentRPM * (1 + gasPedal * _maxRPM)).toInt();
      // v1 = v0 + 0.001341 * HP? * 5252 * (RPM? / 60 min)  * (gear? / 3) / (masa? * C_FRICTION) / (1000 m)
      if(this.speed < _maxSpeed){
          this.speed = (this.speed + 0.001341 * 5252 * _hp * currentRPM * currentGear / (3 * _weight * 1000)).toInt();
      }else{
          this.speed = _maxSpeed;
      }
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
  
  bool switchLightsOn(Game game){
      return false;
  }

  static final VEHICLE_SPORT_CAR = new Vehicle("Patito","X1", 107, 58, 5, 9000, 4000, 5500, 240, 200, 3.5, 'assets/sprites/car1.png', 2500);
}