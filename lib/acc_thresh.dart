import 'package:flutter/material.dart';






class Acc_range extends StatefulWidget {

  @override
  State<Acc_range> createState() => _AccelerometerRange();


}

class _AccelerometerRange extends State<Acc_range> {

  //init the slide bar value
  double _currentSliderValue = 20;

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
