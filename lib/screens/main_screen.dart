import 'package:easy_metronome/model/contador_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override

  Widget buildLed(String text, bool turnOn){
    print("!!!! montou led ${text} -> ${turnOn}");
    return Container(
      alignment: Alignment.center,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: turnOn ? Colors.greenAccent : Colors.grey,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              offset: turnOn ? const Offset(3.0, 3.0) : const Offset(0.0, 0.0),
              blurRadius: 2,
              spreadRadius: turnOn ? 1 : -1,
              color: turnOn ? Colors.green : Colors.grey,
          ),
        ],
      ),
      child: Text(text, style: TextStyle(color: Colors.white),),
    );
  }

  Widget build(BuildContext context) {
    return ScopedModel<ContadorModelSingleton>(
        model: ContadorModelSingleton(),
        child: Scaffold(
            appBar: AppBar(
              title: Text("Easy Metronome"),
              centerTitle: true,
              backgroundColor: Colors.greenAccent,
            ),
            body: ScopedModelDescendant<ContadorModelSingleton>(
                builder: (context, child, model) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //contador
                  Expanded(
                    flex: 1,
                    child: Card(
                        child: Column(
                          children: [
                            Text(
                              model.defaultBPM.toStringAsFixed(0),
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            Text(
                              "BPM",
                              style: TextStyle(
                                  color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                      ],
                    )),
                  ),
                  //player
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 1, 
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Colors.greenAccent[200],
                                inactiveTrackColor: Colors.greenAccent[100],
                                thumbColor: Colors.greenAccent,
                                overlayColor: Colors.greenAccent.withAlpha(32),
                                overlayShape:
                                    RoundSliderOverlayShape(overlayRadius: 28.0),
                              ),
                              child: Slider(
                                min: model.minBPM,
                                max: model.maxBPM,
                                value: model.defaultBPM,
                                onChanged: (value) {
                                  setState(() {
                                    model.setBPM(value);
                                    if (model.isPlaying) model.play(0);
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: RaisedButton(
                                      child: Text(
                                        "-",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      shape: CircleBorder(),
                                      color: Colors.greenAccent,
                                      onPressed: () {
                                        setState(() {
                                          model.decrementBPM();
                                          if (model.isPlaying) model.play(0);
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: RaisedButton.icon(
                                        label: Text(
                                          model.isPlaying ? "Pause" : " Play ",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30)
                                        ),
                                        icon: Icon(model.isPlaying? Icons.pause : Icons.play_arrow, color: Colors.white,),
                                        color: Colors.greenAccent,
                                        onPressed: () {
                                          setState(() {
                                            if (model.isPlaying) {
                                              model.play(0);
                                            } else {
                                              model.play(1);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: RaisedButton(
                                      child: Text(
                                        "+",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      shape: CircleBorder(),
                                      color: Colors.greenAccent,
                                      onPressed: () {
                                        setState(() {
                                          model.increaseBPM();
                                          if (model.isPlaying) model.play(0);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //leds
                  Expanded(
                    flex: 1,
                    child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildLed("1", model.leds[0]),
                                buildLed("2", model.leds[1]),
                              ],
                            ),
                          ),
                      ),
                  //tap
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: InkWell(
                          child:  Center(child:
                              Text("Tap here", style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontStyle: FontStyle.italic
                              ),),
                            ),
                          onTap: (){
                            if (model.isPlaying) model.play(0);
                            model.setTap(DateTime.now().millisecondsSinceEpoch);
                            print("!!!! taps ${model.taps}");
                          },
                        ),
                    ),),
                ],
              );
            }
            ),
            floatingActionButton: ScopedModelDescendant<ContadorModelSingleton>(
                builder: (context, child, model) {
                  return FloatingActionButton(
                    child: Icon(Icons.vibration),
                    backgroundColor: model.isVibrationOn ? Colors.greenAccent : Colors.grey,
                    onPressed: (){
                      if(model.isVibrationOn)
                          model.setVibration(false);
                      else
                        model.setVibration(true);
                    },
                  );
                }),
        )
    );
  }
}
