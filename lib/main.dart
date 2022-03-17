// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, deprecated_member_use

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double x = 0, y = 0, z = 0;
  double absAcceleration = 0;

  List<String> absAccelerationList = <String>[];

  StreamSubscription? accel;
  Timer? timer;
  UserAccelerometerEvent? event;

  @override
  void initState() {
    super.initState();
  }

  startTimer() {
    // if the accelerometer subscription hasn't been created, go ahead and create it
    if (accel == null) {
      accel = userAccelerometerEvents.listen((UserAccelerometerEvent eve) {
        setState(() {
          event = eve;
        });
      });
    } else {
      // it has already ben created so just resume it
      accel?.resume();
    }

    // Accelerometer events come faster than we need them so a timer is used to only process them every 200 milliseconds
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 200), (_) {
        setState(() {
          x = event!.x;
          y = event!.y;
          z = event!.z;
          absAcceleration = getAbsoluteValue();
        });
      });
    }
  }

  pauseTimer() {
    // stop the timer and pause the accelerometer stream
    timer!.cancel();
    accel!.pause();

    // set the success color and reset the count
    setState(() {});
  }

  getAbsoluteValue() {
    double absoluteX = x.abs();
    double absoluteY = y.abs();
    double absoluteZ = z.abs();

    absAcceleration = absoluteX + absoluteY + absoluteZ;

    absAccelerationList.add(absAcceleration.toString());
  }

  generateCsv() async {
    //List<String> stringList = absAccelerationList.cast<String>();
    List<List<String>> data = [
      absAccelerationList,
    ];
    String csvData = ListToCsvConverter().convert(data);
    String directory = (await getExternalStorageDirectory())!.absolute.path;
    final path = "$directory/gyroscope_data-${DateTime.now()}.csv";
    print(path);
    final File file = File(path);
    await file.writeAsString(csvData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Flutter Sensor Library"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "An Example How on Flutter Sensor library is used",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
                ),
              ),
              Table(
                border: TableBorder.all(
                    width: 2.0,
                    color: Colors.blueAccent,
                    style: BorderStyle.solid),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "X Axis : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            x.toStringAsFixed(
                                2), //trim the axis value to 2 digit after decimal point
                            style: TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Y Axis : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            y.toStringAsFixed(
                                2), //trim the axis value to 2 digit after decimal point
                            style: TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Z Axis : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            z.toStringAsFixed(
                                2), //trim the axis value to 2 digit after decimal point
                            style: TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Absolute Acceleration : ",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            absAcceleration.toStringAsFixed(
                                2), //trim the axis value to 2 digit after decimal point
                            style: TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                  onPressed: startTimer,
                  child: Text('Begin'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                  onPressed: pauseTimer,
                  child: Text('Stop'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                  onPressed: generateCsv,
                  child: Text('Export CSV'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                ),
              )
            ],
          ),
        ));
  }
}
