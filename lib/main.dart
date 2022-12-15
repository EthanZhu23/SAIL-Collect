import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:path_provider/path_provider.dart';
import 'acc_thresh.dart';
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

  //sensor status
  bool _accelAvailable = true;
  bool _gyroAvailable = true;
  bool _magnetometerAvailable = true;
  bool _allAvailable = true;
  bool condition = true;

  //list to hold each event from the sensor
  List<double> _accelData = List.filled(3, 0.0);
  List<double> _gyroData = List.filled(3, 0.0);
  List<double> _magnetometerData = List.filled(3, 0.0);

  //streaming sub for each sensor
  StreamSubscription? _accelSubscription;
  StreamSubscription? _gyroSubscription;
  StreamSubscription? _magnetometerSubscription;

  //list to hold the whole listened data
  List _entriesAcc = [];
  List _entriesGyro = [];
  List _entriesMag = [];

  //init threshold with a large value
  int acc_thresh = 50000;
  int gyro_thresh = 50000;

  @override
  void initState() {
    super.initState();
    //check the status of all sensors(active or not?)
    _checkAll();

  }

  @override
  void dispose() {
    _stopAccelerometer();
    _stopGyroscope();
    _stopMagnetometer();
    super.dispose();
  }

  void _checkAccelerometerStatus() async {

    _accelAvailable = await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);
  }


  void _checkGyroscopeStatus() async {

    _gyroAvailable = await SensorManager().isSensorAvailable(Sensors.GYROSCOPE);
  }

  void _checkMagnetometer() async {

    _magnetometerAvailable = await SensorManager().isSensorAvailable(Sensors.MAGNETIC_FIELD);
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

  void _stopAccelerometer() {
    if (_accelSubscription == null) return;
    _accelSubscription?.cancel();

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

  //start accelerometer, listen to the sensor data, and vibrate if exceed the threshold
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

  //start gyroscope, listen to the sensor data, and vibrate if exceed the threshold
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

  //start magnetometer, listen to the sensor data
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


  //write file to the internal storage and ask permission to write
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


    //MAGNETOMETER
    String csvMagnetometer = _entriesMag.join("\n");
    print("Magnetometer Csv:  $csvMagnetometer");
    String magnetometerfilename = "Magnetometer.csv";
    File magnetometer = File(directory1.path  + "/$magnetometerfilename");
    magnetometer.writeAsString(csvMagnetometer);

    return 1;
  }

  //get the acc threshold from the setting page
  Future<void> _getAccThreshold() async{
    acc_thresh = await Navigator.push(context,
        MaterialPageRoute(

        builder: (context) => Acc_range(),
    )
    );

  }

  //get the gyro threshold from the setting page
  Future<void> _getGyroThreshold() async{
    gyro_thresh = await Navigator.push(context,
        MaterialPageRoute(

          builder: (context) => Gyro_range(),
        )
    );

  }

  //vibration function
  Future<void> _vibrate() async{
    Vibration.vibrate(duration: 1000);
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonWidth = 135;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Sensors App'),
        ),
        body: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          alignment: AlignmentDirectional.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[

                Text(
                  "Accelerometer Enabled: $_accelAvailable",
                  textAlign: TextAlign.center,
                ),

                Padding(padding: EdgeInsets.only(top: screenHeight * 0.01)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "[0](X) = ${_accelData[0].toStringAsFixed(3)}",
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      width: screenWidth * 0.02,
                    ),

                    SizedBox(
                      width: buttonWidth,
                    )
                  ],
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "[1](Y) = ${_accelData[1].toStringAsFixed(3)}",
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      width: screenWidth * 0.02,
                    ),

                    SizedBox(
                      width: buttonWidth,
                      child: MaterialButton(
                        child: Text("Start streaming"),
                        color: Colors.green,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AccelerometerStream()),
                          );
                        },
                      ),
                    ),

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "[2](Z) = ${_accelData[2].toStringAsFixed(3)}",
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      width: screenWidth * 0.02,
                    ),

                    SizedBox(
                      width: buttonWidth,
                    )
                  ],
                ),



                Padding(padding: EdgeInsets.only(top: screenHeight *0.01)),
                Text(
                  "Gyroscope Enabled: $_gyroAvailable",
                  textAlign: TextAlign.center,
                ),

                Padding(padding: EdgeInsets.only(top: screenHeight *0.01)),

                Row (
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                    "[0](X) = ${_gyroData[0].toStringAsFixed(3)}",
                    textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      width: screenWidth * 0.02,
                    ),

                    SizedBox(
                      width: buttonWidth,
                    )
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "[1](Y) = ${_gyroData[1].toStringAsFixed(3)}",
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      width: screenWidth * 0.02,
                    ),


                    SizedBox(
                      width: buttonWidth,
                      child: MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GyroscopeStream()),
                          );
                        },
                        child: Text("Start streaming"),
                      ),
                    ),

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "[2](Z) = ${_gyroData[2].toStringAsFixed(3)}",
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      width: screenWidth * 0.02,
                    ),

                    SizedBox(
                      width: buttonWidth,
                    )
                  ],
                ),

                Padding(padding: EdgeInsets.only(top: screenHeight *0.01)),

                Text(
                  "Magnetometer Enabled: $_magnetometerAvailable",
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "[0](X) = ${_magnetometerData[0].toStringAsFixed(3)}",
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      width: screenWidth * 0.02,
                    ),

                    SizedBox(
                      width: buttonWidth,
                    )
                  ],
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "[1](Y) = ${_magnetometerData[1].toStringAsFixed(3)}",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: screenWidth * 0.02,
                    ),

                    SizedBox(
                      width: buttonWidth,
                      child: MaterialButton(
                        child: Text("Start streaming"),
                        color: Colors.green,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MagnetometerStream()),
                          );
                        },
                      ),
                    ),

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "[2](Z) = ${_magnetometerData[2].toStringAsFixed(3)}",
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      width: screenWidth * 0.02,
                    ),

                    SizedBox(
                      width: buttonWidth,
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: screenHeight * 0.05)),
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
                Padding(padding: EdgeInsets.only(top: screenHeight *0.01)),
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
                Padding(padding: EdgeInsets.only(top: screenHeight *0.01)),
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
      ),

    );
  }
}