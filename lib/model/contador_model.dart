import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class ContadorModelSingleton extends Model{

  static final ContadorModelSingleton _contadorModel = ContadorModelSingleton._internal();
  ContadorModelSingleton._internal();
  factory ContadorModelSingleton() => _contadorModel;

  final double minBPM = 10;
  final double maxBPM = 300;
  final String _soundHi = "assets/sounds/MetronomeHi.wav";
  final String _soundLo = "assets/sounds/MetronomeLo.wav";

  double defaultBPM = 100;
  bool isPlaying = false;
  bool isVibrationOn = true;
  Soundpool pool = Soundpool(streamType: StreamType.notification);
  List<bool> leds = [false, false];
  List<int> taps = List<int>(2);

  int _tapInterval;

  void setBPM(double newValue){
    defaultBPM = newValue;
    notifyListeners();
  }

  void _setTapBPM(){
    var _intervalo = 60000 ~/(taps[1] - taps[0]) ;
    if(_intervalo <= maxBPM && _intervalo >= minBPM)
      setBPM(_intervalo.toDouble());

  }

  void increaseBPM(){
    defaultBPM++;
    notifyListeners();
  }

  void decrementBPM(){
    defaultBPM--;
    notifyListeners();
  }

  void play(int op) async {
    if(op == 1){

      isPlaying = true;
      double _speed = defaultBPM;
      double _ms = 60000;
      double _interval = _ms / _speed;
      print("!!!! intervalo : $_interval");
      String _playSound = _soundHi;

      while(isPlaying){
        int soundId = await rootBundle.load(_playSound).then((ByteData soundData) {
          return pool.load(soundData);
        });

        if(_playSound.contains("Hi"))
          _playSound = _soundLo;
        else
          _playSound = _soundHi;

        blinkLed();
        int streamId = await pool.play(soundId);

        if(isVibrationOn)
          Vibration.vibrate(duration: 50);

        await Future.delayed(Duration(milliseconds: _interval.toInt()));
      }
    }

    else{
      isPlaying = false;
      for(var i = 0; i <= leds.length -1; i++){ leds[i] = false;}
    }

    notifyListeners();
  }

  double getBPM(){
    return defaultBPM;
  }

  void blinkLed(){
    //means its the first time play was pressed
    if(!leds[0] && !leds[1]){
      leds[0] = true;
      leds[1] = false;
    }
    else{
       for(var i = 0; i <= leds.length -1; i++){
         if(leds[i])
            leds[i] = false;
         else
           leds[i] = true;
       }
    }

    print("!!!! leds: ${leds}");
    notifyListeners();
  }

  void setVibration(bool vibration){
    isVibrationOn = vibration;
    notifyListeners();
  }

  void _clearTap(){
    taps[0] = null;
    taps[1] = null;
  }

  void setTap(int tempo){
    if(taps[1] != null)
      _clearTap();

    if(taps[0] == null)
      taps[0] = tempo;
    else if(taps[0] != null && taps[1] == null)
      taps[1] = tempo;
    else
      _clearTap();

    if(taps[0] != null && taps[1] != null)
      _setTapBPM();

    notifyListeners();
  }
}