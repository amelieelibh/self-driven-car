library com.aebh.selfdrivencar;

import 'dart:html';
import 'package:phaser/phaser.dart';
import 'states/DriverState.dart' show DriverState;

main() {
  print("start");
  print(""+window.innerWidth.toString()+","+window.innerHeight.toString());
  print(""+window.devicePixelRatio.toString());
  var w = window.innerWidth * window.devicePixelRatio;
  var h = window.innerHeight * window.devicePixelRatio;
  var width = (h > w) ? h : w;
  var height = (h > w) ? w : h;

  // Hack to avoid large devices. Tell it to scale up.
  if (window.devicePixelRatio > 1) {
    width = Math.roundTo(width / window.devicePixelRatio);
    height = Math.roundTo(height / window.devicePixelRatio);
  }
  // Hack to avoid iPad Retina and large Android devices. Tell it to scale up.
  if (window.innerWidth >= 1024 && window.devicePixelRatio >= 2) {
    width = Math.roundTo(width / 2);
    height = Math.roundTo(height / 2);
  }
  // reduce screen size by one 3rd on devices like Nexus 5
  if (window.devicePixelRatio == 3) {
    width = Math.roundTo(width / 3) * 2;
    height = Math.roundTo(height / 3) * 2;
  }

  var driverState = new DriverState().jsonMap();
  print("states");
  
  Game game = new Game(width, height, Phaser.AUTO,
      'phaser-example');
  // game.state.add('Boot', new Object());
  // game.state.add('Preloades', new Object());
  // game.state.add('MainMenu', new Object());
  game.state.add('Game', driverState);
  // game.state.add('EndGame', new Object());
  print("start");
  game.state.start('Game');
  print("main end");
  //game.canvas.style.cursor = "pointer";
  //game.boot();
}