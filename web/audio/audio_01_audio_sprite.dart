part of example;

class audio_01_audio_sprite extends State {
  Sound fx;
  Button btn;

  preload() {

    game.load.image('title', 'assets/pics/catastrophi.png');

    game.load.spritesheet('button', 'assets/buttons/flixel-button.png', 80, 20);
    game.load.bitmapFont('nokia', 'assets/fonts/bitmapFonts/nokia16black.png', 'assets/fonts/bitmapFonts/nokia16black.xml');

    // game.load.audio('sfx', [ 'assets/audio/SoundEffects/fx_mixdown.mp3', 'assets/audio/SoundEffects/fx_mixdown.ogg' ]);
    game.load.audio('sfx', ['assets/audio/SoundEffects/fx_mixdown.ogg','assets/audio/SoundEffects/fx_mixdown.mp3']);

  }

  create() {

    game.add.image(0, 0, 'title');

    //	Here we set-up our audio sprite

    fx = game.add.audio('sfx');

    //	And this defines the markers.

    //	They consist of a key (for replaying), the time the sound starts and the duration, both given in seconds.
    //	You can also set the volume and loop state, although we don't use them in this example (see the docs)

    fx.addMarker('alien death', 1, 1.0);
    fx.addMarker('boss hit', 3, 0.5);
    fx.addMarker('escape', 4, 3.2);
    fx.addMarker('meow', 8, 0.5);
    fx.addMarker('numkey', 9, 0.1);
    fx.addMarker('ping', 10, 1.0);
    fx.addMarker('death', 12, 4.2);
    fx.addMarker('shot', 17, 1.0);
    fx.addMarker('squit', 19, 0.3);
    print("ok");
    //	Make some buttons to trigger the sounds
    btn= makeButton('alien death', 600, 100);
    makeButton('boss hit', 600, 140);
    makeButton('escape', 600, 180);
    makeButton('meow', 600, 220);
    makeButton('numkey', 600, 260);
    makeButton('ping', 600, 300);
    makeButton('death', 600, 340);
    makeButton('shot', 600, 380);
    makeButton('squit', 600, 420);

    
    //btn.rotation=1;
  }

  Button makeButton(String name, num x, num y) {

    Button button = game.add.button(x, y, 'button', click, 0, 1, 2);
    button.name = name;
    button.scale.set(2, 1.5);
    button.anchor.set(0,0);
    button.smoothed = false;

    BitmapText text = game.add.bitmapText(x, y + 7, 'nokia', name, 16);
    num xx=(text.textWidth / 2);

    text.x += (button.width / 2) - (text.textWidth / 2);
    //text.x=0;
    //text.dirty=true;
    //text.update();
    //text.updateTransform();
    return button;
  }

  click(Button button, Pointer pointer, bool isOver) {

    fx.play(button.name);
  }

  render(){
    game.debug.spriteInputInfo(btn, 50,20);
    game.debug.inputInfo(50,100);
  }
}
