import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stepmeter/StepsList.dart';
import 'package:stepmeter/step.dart';
import 'package:stepmeter/consultas.dart';
import 'dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MaterialApp(title: "App", home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences preferences;
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  double percentage = 0.0;

  var counter;
  var stepCounter;
  var actualDay;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initializePreference().whenComplete(() {
      setState(() {
        if (_steps != '?') {
          this.preferences.setInt("counter", int.parse(_steps));
        }

        actualDay = this.preferences.getString("day");
        if (actualDay != null) {
          if (actualDay != DateTime.now().toString()) {
            _steps = "0";
          }
        }

        DateTime now = new DateTime.now();
        DateTime date = new DateTime(now.year, now.month, now.day);
        this.preferences.setString("day", date.toString());

        stepCounter = this.preferences.getInt("counter");
        if (stepCounter == null) {
          stepCounter = 0;
          _steps = "0";
        }
      });
    });
  }

  Future<void> initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
      percentage = double.parse(_steps) / 1000;
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
    counter = _stepCountStream.listen(onStepCount);
    counter.onError(onStepCountError);

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
                      (int.parse(_steps) - stepCounter).toString(),
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
                      DateTime now = new DateTime.now();
                      DateTime date =
                          new DateTime(now.year, now.month, now.day);
                      deleteStep(date);
                    },
                    child: Text("Borrar", style: TextStyle(fontSize: 20)),
                  ),
                  new ElevatedButton(
                    onPressed: () {
                      if (_steps.isNotEmpty) {
                        stepCounter = this.preferences.getInt("counter");
                        if (stepCounter == null) {
                          stepCounter = 0;
                        }

                        var realSteps = int.parse(_steps) - stepCounter;
                        createOrUpdate(realSteps);
                        getAllStep().then((value) => print(value));
                        this.preferences.setInt("counter", int.parse(_steps));
                      }
                    },
                    child: Text("Guardar", style: TextStyle(fontSize: 20)),
                  ),
                  new ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildPopupDialog(context),
                      );
                    },
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

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Seleccione una consulta'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
              onPressed: () {
                getAllDaysChallengeCompleted().then((value) => print(value));
              },
              child: Text("Reto cumplido")),
          ElevatedButton(
              onPressed: () {
                //
              },
              child: Text("Pasos totales")),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StepList()),
                );
              },
              child: Text("Listado")),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarScreen()),
                );
              },
              child: Text("Calendario")),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
