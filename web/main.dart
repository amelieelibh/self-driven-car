library com.aebh.selfdrivencar;

import 'dart:html' show window;
import 'package:phaser/phaser.dart';
import 'states/DriverState.dart' show DriverState;

main() {
  print("start");

//  var w = dom.window.innerWidth * dom.window.devicePixelRatio,
//  h = dom.window.innerHeight * dom.window.devicePixelRatio,
//  width = (h > w) ? h : w,
//  height = (h > w) ? w : h;
//
//  // Hack to avoid iPad Retina and large Android devices. Tell it to scale up.
//  if (dom.window.innerWidth >= 1024 && dom.window.devicePixelRatio >= 2) {
//    width = Math.round(width / 2);
//    height = Math.round(height / 2);
//  }
//  // reduce screen size by one 3rd on devices like Nexus 5
//  if (dom.window.devicePixelRatio == 3) {
//    width = Math.round(width / 3) * 2;
//    height = Math.round(height / 3) * 2;
//  }

  var driverState = new DriverState().jsonMap();
  print("states");
  
  Game game = new Game(window.innerWidth, window.innerHeight, Phaser.CANVAS,
      'phaser-example');
  game.state.add('Boot', new Object());
  game.state.add('Preloades', new Object());
  game.state.add('MainMenu', new Object());
  game.state.add('Game', driverState);
  game.state.add('EndGame', new Object());
  print("start");
  game.state.start('Game');
  print("main end");
  //game.canvas.style.cursor = "pointer";
  //game.boot();
}