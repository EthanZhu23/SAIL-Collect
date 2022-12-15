import 'package:flutter/material.dart';





class Gyro_range extends StatefulWidget {
  //final double max;
  // Range({super.key, required this.max});

  @override
  State<Gyro_range> createState() => _GyroRange();


}

class _GyroRange extends State<Gyro_range> {


  double _currentSliderValue = 20;


  static const String _title = 'Setting Gyroscope range';

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
                  (_currentSliderValue.round()).toString() + '°/s',
                  textAlign: TextAlign.center,
                ),

                Slider(value: _currentSliderValue,
                  max: 150,
                  divisions: 15,
                  label: (_currentSliderValue.round()).toString() + '°/s',
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
