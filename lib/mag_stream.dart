import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:motion_sensors/motion_sensors.dart';


class MagnetometerStream extends StatefulWidget{
  @override
  _MagnetometerStreamState createState() => _MagnetometerStreamState();
}

class _MagnetometerStreamState extends State<MagnetometerStream>{
  List<double> traceX = [];
  List<double> traceY = [];
  List<double> traceZ = [];
  StreamSubscription? _magSubscription;




  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    motionSensors.magnetometerUpdateInterval = Duration.microsecondsPerSecond ~/ 30;
    final stream = motionSensors.magnetometer;
    _magSubscription = stream.listen((MagnetometerEvent event) {
      setState(() {
        traceX.add(event.x);
        traceY.add(event.y);
        traceZ.add(event.z);
      });
    });

  }





  @override
  void dispose() {
    _magSubscription!.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    // Create A Scope Display
    Oscilloscope scopeOne = Oscilloscope(
      margin: EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      traceColor: Colors.green,
      yAxisMax: 300.0,
      yAxisMin: -300.0,
      dataSet: traceX,
    );

    Oscilloscope scopetwo = Oscilloscope(
      margin: EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      traceColor: Colors.cyan,
      yAxisMax: 300.0,
      yAxisMin: -300.0,
      dataSet: traceY,
    );

    Oscilloscope scopethree = Oscilloscope(
      margin: EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      traceColor: Colors.pinkAccent,
      yAxisMax: 300.0,
      yAxisMin: -300.0,
      dataSet: traceZ,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Accelerometer Graph"),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.black87,
              Colors.black87,
              Colors.black87,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            Divider(height: 5.0),
            Text("X-Axis", style: TextStyle(color: Colors.white, fontSize: 12)),
            Divider(height: 5.0),
            Expanded(flex: 1, child: scopeOne),
            Divider(height: 5.0),
            Text("Y-Axis", style: TextStyle(color: Colors.white, fontSize: 12)),
            Divider(height: 5.0),
            Expanded(flex: 1, child: scopetwo),
            Divider(height: 5.0),
            Text("Z-Axis", style: TextStyle(color: Colors.white, fontSize: 12)),
            Divider(height: 5.0),
            Expanded(flex: 1, child: scopethree),

          ],
        ),
      ),
    );
  }
}