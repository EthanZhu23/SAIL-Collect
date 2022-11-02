import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class InternalStorage{
  // static final InternalStorage _singleton = new InternalStorage._internal();
  //
  // factory InternalStorage() {
  //   return _singleton;
  // }
  //
  // InternalStorage._internal();

  List _entriesAcc = [];
  List _entriesGyro = [];
  List _entriesMag = [];
  List _entriesGeo = [];

  double _latitude = 0.0;
  double _longitude = 0.0;

  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;

  Vector3 _gyroscope = Vector3.zero();

  double _magnetometerX = 0.0;
  double _magnetometerY = 0.0;
  double _magnetometerZ = 0.0;

  double accValues = 0.0;
  double gyroValues = 0.0;
  double magValues = 0.0;

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  setLatitudeLongitudeInternal(double latitude, double longitude) {
    this._latitude = latitude;
    this._longitude = longitude;
  }

  setAccelerometerDataInternal(double x, double y, double z){
    this._accelerometerX = x;
    this._accelerometerY = y;
    this._accelerometerZ = z;
  }

  setGyroscopeDataInternal(_gyroscope){
    this._gyroscope = _gyroscope;
  }

  setMagnetometerDataInternal(double x, double y, double z){
    this._magnetometerX = x;
    this._magnetometerY = y;
    this._magnetometerZ = z;
  }

  addAccelerometerEntryInternal(_accelerometerX,_accelerometerY,_accelerometerZ) async{
    _entriesAcc.add("${DateTime.now().toString()}, $_accelerometerX,$_accelerometerY,$_accelerometerZ");
    //_entriesAcc.add("${DateTime.now().toString()}, $accValues");
    print("Accelerometer :  $_entriesAcc");
  }

  addGyroscopeEntryInternal(_gyroscope) async{
    _entriesGyro.add("${DateTime.now().toString()}, $_gyroscope");
    print("Gyroscope : $_entriesGyro");
  }

  addMagnetometerEntryInternal(_magnetometerX,_magnetometerY,_magnetometerZ) async{
    _entriesMag.add("${DateTime.now().toString()}, $_magnetometerX,$_magnetometerY,$_magnetometerZ");
    //print("Magnetometer: $_entriesMag");
  }

  addGeolocatorEntryInternal(_latitude, _longitude) async{
    _entriesGeo.add("${DateTime.now().toString()},$_latitude,$_longitude");
    //print("Geolocation: $_entriesGeo");
  }

  clearEntries() {
    _latitude = 0.0;
    _longitude = 0.0;

    _accelerometerX = 0.0;
    _accelerometerY = 0.0;
    _accelerometerZ = 0.0;

    _gyroscope = 0.0 as Vector3;

    _magnetometerX =0.0;
    _magnetometerY = 0.0;
    _magnetometerZ = 0.0;

    _entriesAcc.clear();
    _entriesGyro.clear();
    _entriesMag.clear();
    _entriesGeo.clear();
  }

  Future<bool> saveFile(_entriesAcc, _entriesGyro, _entriesMag) async{
    Directory? directory;

    final status = await Permission.storage.request();
    var state = await Permission.manageExternalStorage.status;
    var state2 = await Permission.storage.status;

    try{
      if(Platform.isAndroid){
        //if(await _requestPermission(Permission.storage))
        if(status.isGranted){
          //print("Permission storage: $_requestPermission(Permission.storage)");
          directory = await getExternalStorageDirectory();
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
          newPath = newPath + "/sensor_model";
          directory = Directory(newPath);
          print(directory.path);
        } else{
          return false;
        }
      }else{
        //if (await _requestPermission(Permission.storage))
        if (status.isGranted){
          directory = await getTemporaryDirectory();
        } else{
          return false;
        }
      }
      if (!state2.isGranted) {
        await Permission.storage.request();
      }

      if (!state.isGranted) {
        await Permission.manageExternalStorage.request();
      }

      if(!await directory.exists()){
        await directory.create(recursive: true);
      }
      if(await directory.exists()){
        // ACCELEROMETER
        print("Directory exists: $directory.exists()");
        String csvAccelerometer = _entriesAcc.join("\n");
        print("Accelerometer Csv:  $csvAccelerometer");
        String accelerometerfilename = "Accelerometer.csv";
        File accelerometer = File(directory.path + "/$accelerometerfilename");
        accelerometer.writeAsString(csvAccelerometer);
        //print(accelerometer);

        //GYROSCOPE
        String csvGyroscope = _entriesGyro.join("\n");
        print("Gyroscope Csv:  $csvGyroscope");
        String gyroscopefilename = "Gyroscope.csv";
        File gyroscope = File(directory.path + "/$gyroscopefilename");
        gyroscope.writeAsString(csvGyroscope);
        //print(accelerometer);

        //MAGNETOMETER
        String csvMagnetometer = _entriesMag.join("\n");
        print("Magnetometer Csv:  $csvMagnetometer");
        String magnetometerfilename = "Magnetometer.csv";
        File magnetometer = File(directory.path + "/$magnetometerfilename");
        magnetometer.writeAsString(csvMagnetometer);
        //print(accelerometer);


        //print(accelerometer);
      }
    }catch (e){
      print(e.toString());
    }
    return false;
  }

  Future<bool> _requestPermission(Permission permission) async{
    if(await permission.isGranted){
      return true;
    } else{
      var result = await permission.request();
      if(result == PermissionStatus.granted){
        return true;
      }
    }
    return false;
  }
}