import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:sensor_model_1/slide_bar.dart';
import 'internalStorage.dart';
import 'package:path_provider/path_provider.dart';
import 'slide_bar.dart';
import 'gyro_thresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'acc_stream.dart';
import 'gyro_stream.dart';
import 'mag_stream.dart';
import 'package:vibration/vibration.dart';


void main() => runApp(MaterialApp(
  title: "App",
  home: MyApp(),
));

class MyApp extends StatefulWidget {


  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  bool _accelAvailable = true;
  bool _gyroAvailable = true;
  bool _magnetometerAvailable = true;
  bool _allAvailable = true;
  bool condition = true;
  List<double> _accelData = List.filled(3, 0.0);
  List<double> _gyroData = List.filled(3, 0.0);
  List<double> _magnetometerData = List.filled(3, 0.0);
  StreamSubscription? _accelSubscription_test;
  StreamSubscription? _accelSubscription;
  StreamSubscription? _gyroSubscription;
  StreamSubscription? _magnetometerSubscription;
  List _entriesAcc = [];
  List _entriesGyro = [];
  List _entriesMag = [];

  List _entriesAccTest = [];
  int count =  1;
  DateTime end = DateTime.now();
  DateTime start = DateTime.now();
  DateTime currentTime = DateTime.now();
  double max_range = 400;
  int acc_thresh = 0;
  int gyro_thresh = 0;

  @override
  void initState() {
    super.initState();
    _checkAll();

    //testing thresh hold
    //_checkaccrange(count);
  }

  @override
  void dispose() {
    _stopAccelerometer();
    _stopGyroscope();
    _stopMagnetometer();
    super.dispose();
  }

  void _checkAccelerometerStatus() async {
    await SensorManager()
        .isSensorAvailable(Sensors.ACCELEROMETER)
        .then((result) {
      setState(() {
        _accelAvailable = result;
      });
    });
  }


  void _checkGyroscopeStatus() async {
    await SensorManager().isSensorAvailable(Sensors.GYROSCOPE).then((result) {
      setState(() {
        _gyroAvailable = result;
      });
    });
  }

  void _checkMagnetometer() async {
    await SensorManager().isSensorAvailable(Sensors.MAGNETIC_FIELD).then((result) {
      setState(() {
        _magnetometerAvailable = result;
      });
    });
  }

  void _checkAll() async {
    _checkAccelerometerStatus();
    _checkGyroscopeStatus();
    _checkMagnetometer();

    if (_accelAvailable & _gyroAvailable & _magnetometerAvailable){
      _allAvailable = true;
    }else{
      _allAvailable = false;
    }
  }

  Future<void> _startAccelerometer() async {
    if (_accelSubscription != null) return;
    if (_accelAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: Duration(milliseconds: 28),
      );
      _accelSubscription = stream.listen((sensorEvent) {
        setState(() {
          _accelData = sensorEvent.data;
          _entriesAcc.add("${DateTime.now().toString()}, ${_accelData[0]}, ${_accelData[1]}, ${_accelData[2]}");
          if(_accelData[0] > acc_thresh || _accelData[1] > acc_thresh || _accelData[3] > acc_thresh){
              _vibrate();
          }
        });
      });
    }
  }

  void _stopAccelerometer() {
    if (_accelSubscription == null) return;
    _accelSubscription?.cancel();
    _accelSubscription_test?.cancel();
    _accelSubscription = null;
  }

  void _stopGyroscope() {
    if (_gyroSubscription == null) return;
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
  }

  void _stopMagnetometer() {
    if (_magnetometerSubscription == null) return;
    _magnetometerSubscription?.cancel();
    _magnetometerSubscription = null;

  }

  void _startAll(){
    _startAccelerometer();
    _startGyroscope();
    _startMagnetometer();
  }

  void _stopAll(){
    _stopAccelerometer();
    _stopGyroscope();
    _stopMagnetometer();
    savefile(_entriesAcc, _entriesGyro, _entriesMag);
  }

  Future<void> _startGyroscope() async {
    if (_gyroSubscription != null) return;
    if (_gyroAvailable) {
      final stream =
      await SensorManager().sensorUpdates(sensorId: Sensors.GYROSCOPE,interval: Duration(milliseconds: 28));
      _gyroSubscription = stream.listen((sensorEvent) {
        setState(() {
          _gyroData = sensorEvent.data;
          _entriesGyro.add("${DateTime.now().toString()}, ${_gyroData[0]}, ${_gyroData[1]}, ${_gyroData[2]}");
          if(_gyroData[0] > gyro_thresh || _gyroData[1] > gyro_thresh || _gyroData[3] > gyro_thresh){
            _vibrate();
          }
        });
      });
    }
  }


  Future<void> _startMagnetometer() async {
    if (_magnetometerSubscription != null) return;
    if (_magnetometerAvailable) {
      final stream =
      await SensorManager().sensorUpdates(sensorId: Sensors.MAGNETIC_FIELD,interval:Duration(milliseconds: 28) );
      _magnetometerSubscription = stream.listen((sensorEvent) {
        setState(() {
          _magnetometerData = sensorEvent.data;
          _entriesMag.add("${DateTime.now().toString()}, ${_magnetometerData[0]}, ${_magnetometerData[1]}, ${_magnetometerData[2]}");
        });
      });
    }
  }



  Future<int>  savefile (_entriesAcc, _entriesGyro, _entriesMag) async {
    await Permission.storage.request();
    final directory = await getExternalStorageDirectory();
    String newPath = "";
    print("directory: $directory");
    List<String>? paths = directory?.path.split("/");
    for(int x = 1; x < paths!.length; x++){
      String folder = paths[x];
      if(folder != "Android"){
        newPath += "/" + folder;
      } else{
        break;
      }
    }

    String time = DateTime.now().toString();
    newPath = newPath + "/sensor_model/" + time;
    Directory directory1 = Directory(newPath);
    bool exist = await directory1.exists();
    if(!exist){
      await directory1.create(recursive: true);
    }



    final checkPathExistence = await directory1.exists();
    if(!checkPathExistence){
      await directory1.create();
    }

    String csvAccelerometer = _entriesAcc.join("\n");
    print("Accelerometer Csv:  $csvAccelerometer");

    File accelerometer = File(directory1.path + "/Accelerometer.csv");

    await accelerometer.writeAsString(csvAccelerometer);
    //print(accelerometer);

    //GYROSCOPE
    String csvGyroscope = _entriesGyro.join("\n");
    print("Gyroscope Csv:  $csvGyroscope");
    String gyroscopefilename = "Gyroscope.csv";
    File gyroscope = File(directory1.path  + "/$gyroscopefilename");
    gyroscope.writeAsString(csvGyroscope);
    //print(accelerometer);

    //MAGNETOMETER
    String csvMagnetometer = _entriesMag.join("\n");
    print("Magnetometer Csv:  $csvMagnetometer");
    String magnetometerfilename = "Magnetometer.csv";
    File magnetometer = File(directory1.path  + "/$magnetometerfilename");
    magnetometer.writeAsString(csvMagnetometer);

    return 1;
  }

  Future<void> _checkaccrange(int i) async {
    if (_accelSubscription != null) return;
    if (_accelAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: Sensors.SENSOR_DELAY_FASTEST,
      );
      _accelSubscription_test = stream.listen((sensorEvent) {
        setState(() {
          _writedata(sensorEvent.data);

        });
      });
    }
  }

  Future<void> _writedata(List a) async{
    currentTime = DateTime.now();
    _entriesAccTest.add(currentTime);

    if(currentTime.compareTo(_entriesAccTest[0].add(const Duration(seconds: 10)))>0){
      final diff_time = currentTime.difference(start).inSeconds;
      max_range = _entriesAccTest.length/diff_time;
      condition = true;
    }

}
  Future<void> _getAccThreshold() async{
    acc_thresh = await Navigator.push(context,
        MaterialPageRoute(

        builder: (context) => Acc_range(),
    )
    );

  }

  Future<void> _getGyroThreshold() async{
    gyro_thresh = await Navigator.push(context,
        MaterialPageRoute(

          builder: (context) => Gyro_range(),
        )
    );

  }

  Future<void> _vibrate() async{
    Vibration.vibrate(duration: 1000);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Sensors App'),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          alignment: AlignmentDirectional.topCenter,
          child: Column(
            children: <Widget>[

              Padding(padding: EdgeInsets.only(top: 16.0)),

              Text(
                "Accelerometer Enabled: $_accelAvailable",
                textAlign: TextAlign.center,
              ),

              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[0](X) = ${_accelData[0].toStringAsFixed(3)}",
                textAlign: TextAlign.center,
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "[1](Y) = ${_accelData[1].toStringAsFixed(3)}",
                    textAlign: TextAlign.center,
                  ),

                  Padding(padding: EdgeInsets.only(right: 52.0)),

                  MaterialButton(
                    child: Text("Start streaming"),
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccelerometerStream()),
                      );
                    },
                  ),

                ],
              ),

              Text(
                "[2](Z) = ${_accelData[2].toStringAsFixed(3)}",
                textAlign: TextAlign.center,
              ),



              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "Gyroscope Enabled: $_gyroAvailable",
                textAlign: TextAlign.center,
              ),

              Padding(padding: EdgeInsets.only(top: 16.0)),

              Text(
                "[0](X) = ${_gyroData[0].toStringAsFixed(3)}",
                textAlign: TextAlign.center,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "[1](Y) = ${_gyroData[1].toStringAsFixed(3)}",
                    textAlign: TextAlign.center,
                  ),

                  Padding(padding: EdgeInsets.only(right: 52.0)),

                  MaterialButton(
                    child: Text("Start streaming"),
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GyroscopeStream()),
                      );
                    },
                  ),

                ],
              ),

              Text(
                "[2](Z) = ${_gyroData[2].toStringAsFixed(3)}",
                textAlign: TextAlign.center,
              ),

              Padding(padding: EdgeInsets.only(top: 16.0)),

              Text(
                "Magnetometer Enabled: $_magnetometerAvailable",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Text(
                "[0](X) = ${_magnetometerData[0].toStringAsFixed(3)}",
                textAlign: TextAlign.center,
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "[1](Y) = ${_magnetometerData[1].toStringAsFixed(3)}",
                    textAlign: TextAlign.center,
                  ),
                  Padding(padding: EdgeInsets.only(right: 52.0)),

                  MaterialButton(
                    child: Text("Start streaming"),
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MagnetometerStream()),
                      );
                    },
                  ),

                ],
              ),

              Text(
                "[2](Z) = ${_magnetometerData[2].toStringAsFixed(3)}",
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 50.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    child: Text("Start"),
                    color: Colors.green,
                    onPressed: _allAvailable ? () => _startAll() : null,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  MaterialButton(
                    child: Text("Stop"),
                    color: Colors.red,
                    onPressed: _allAvailable ? () => _stopAll() : null,
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                MaterialButton(
                  child: Text("Set Acc Sensor Threshold"),
                  color: condition ? Colors.orange : Colors.grey ,
                  onPressed: (){
                    _getAccThreshold();
                  },
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    child: Text("Set Gyro Sensor Threshold"),
                    color: condition ? Colors.orange : Colors.grey ,
                    onPressed: (){
                      _getGyroThreshold();
                    },
                  ),
                ],
              ),


            ],

          ),

        ),
      ),
      
    );
  }
}