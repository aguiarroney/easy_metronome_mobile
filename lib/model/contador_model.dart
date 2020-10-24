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

  void setBPM(double newValue){
    defaultBPM = newValue;
    notifyListeners();
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
}