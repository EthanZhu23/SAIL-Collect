import 'package:flutter/material.dart';
import 'dart:async';





class Range extends StatefulWidget {
  //final double max;
  // Range({super.key, required this.max});

  @override
  State<Range> createState() => _AccelerometerRange();


}

class _AccelerometerRange extends State<Range> {


  double _currentSliderValue = 20;
  StreamSubscription? _accelSubscription;
  bool _accelAvailable = true;
  List _entriesAcc = [];
  List<double> _accelData = List.filled(3, 0.0);
  int count =  1;
  DateTime end = DateTime.now();
  DateTime start = DateTime.now();
  DateTime currentTime = DateTime.now();

  double max_range = 0;

  static const String _title = 'Setting Accelerometer range';

  @override
  void initState(){
    super.initState();


  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: Container(
          padding: EdgeInsets.fromLTRB(0, 250, 0, 0),
          alignment: AlignmentDirectional.centerStart,
          child: Column(
              children: <Widget>[
                Text(
                  (_currentSliderValue.round()/10).toString() + 'g',
                  textAlign: TextAlign.center,
                ),

                Slider(value: _currentSliderValue,
                  max: 150,
                  divisions: 15,
                  label: (_currentSliderValue.round()/10).toString() + 'g',
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      child: Text("Set Threshold"),
                      color: Colors.green ,
                      onPressed: (){
                        Navigator.pop(context, _currentSliderValue.round());
                      },
                    ),
                  ],
                ),

              ]

          ),

        ),


      ),
    );
  }

}
