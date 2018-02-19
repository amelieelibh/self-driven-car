library example;
import "package:play_phaser/phaser.dart";
 
//import "dart:html" as dom;

part "games/games_07_tanks.dart";
main() {
//  dom.window.console.log("preload");
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

  //var game = new Game(width, height, WEBGL, '');


  Game game = new Game(800, 600, AUTO, 'phaser-example');

  //game.canvas.style.cursor = "pointer";
  //game.boot();
  //print("start");
  
  var game_car = new games_07_tanks();
  game.state.add("game_car", game_car);
  game.state.start("game_car");

}
