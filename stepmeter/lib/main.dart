import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stepmeter/step.dart';
import 'dbService.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  double percentage = 0.0;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    createDB().then((value) {
      Paso paso = new Paso(steps: 4000, date: DateTime.now());
      createStep(paso);
      getAllStep().then((value) => print(value));
    });
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
      percentage = double.parse(_steps) / 10000;
      print(percentage);
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stepmeter'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  child: Text(
                'Pasos dados:',
                style: TextStyle(fontSize: 30),
              )),
              Container(
                  margin: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                  child: new CircularPercentIndicator(
                    radius: 200.0,
                    lineWidth: 13.0,
                    animation: true,
                    percent: percentage,
                    center: new Text(
                      _steps,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 50.0),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.purple,
                  )),
              Text(
                'Estado:',
                style: TextStyle(fontSize: 25),
              ),
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 80,
              ),
              Container(
                  margin: const EdgeInsets.only(bottom: 30.0),
                  child: Center(
                    child: Text(
                      _status,
                      style: _status == 'walking' || _status == 'stopped'
                          ? TextStyle(fontSize: 30)
                          : TextStyle(fontSize: 20, color: Colors.red),
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new ElevatedButton(
                    onPressed: () {
                      _steps = "0";
                    },
                    child: Text("Borrar", style: TextStyle(fontSize: 20)),
                  ),
                  new ElevatedButton(
                    onPressed: () {},
                    child: Text("Guardar", style: TextStyle(fontSize: 20)),
                  ),
                  new ElevatedButton(
                    onPressed: () {},
                    child: Text("Consultas", style: TextStyle(fontSize: 20)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
