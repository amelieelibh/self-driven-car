library com.aebh.selfdrivencar;

import 'dart:html' show window;
import 'package:phaser/phaser.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'dart:mirrors';
import 'states/DriverState.dart' show DriverState;
//import "dart:html" as dom;

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
  var driverState =new DriverState();
  print("states");
  
  Game game = new Game(window.innerWidth, window.innerHeight, Phaser.CANVAS,
      'phaser-example');
  //game.state.add('Boot', null);
  //game.state.add('Preloades', null);
  //game.state.add('MainMenu', null);
  //game.state.add("Game", jsifyObject(driverState));
  //game.state.add('Game', jsify({'preload':driverState.preload}));
  //game.state.add('Game', jsify({'preload':allowInterop(driverState.preload)}));
  game.state.add('Game', driverState.jsonMap());
  //game.state.add('EndGame', null);
  print("start");
  game.state.start('Game');
  print("main end");
  //game.canvas.style.cursor = "pointer";
  //game.boot();
  //print("start");
  
}


dynamic jsifyObject(dynamic obj){
  Map<String, Function> m = new Map();
  InstanceMirror instanceMirror = reflect(obj);
  ClassMirror classMirror = instanceMirror.type;
  Map<Symbol, MethodMirror> declarations = classMirror.instanceMembers;
  for(MethodMirror v in declarations.values){
    if(v.isConstructor || v.isPrivate || !v.isRegularMethod || v.isOperator){
      continue;
    }
    print(MirrorSystem.getName(v.simpleName));
    var name = MirrorSystem.getName(v.simpleName);
    m.putIfAbsent(MirrorSystem.getName(v.simpleName), () => allowInterop(v));
  }
  print("map result");
  for(Function i in m.values){
    print(""+i.toString());
  }
  return jsify(m);
}
