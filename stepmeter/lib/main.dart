import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stepmeter/StepsList.dart';
import 'package:stepmeter/consultas.dart';
import 'challengeCompleted.dart';
import 'dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'estadistics.dart';

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
  String _status = '?';
  int _steps = 0;
  double percentage = 0.0;

  var counter;
  var stepCounter;
  var actualDay;
  var realSteps = 0;
  var challenge;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initializePreference().whenComplete(() {
      setState(() {
        //if (_steps != 0) {
        //  this.preferences.setInt("counter", _steps);
        //}else{
        //  this.preferences.setInt("counter", 0);
        //}

        if (this.preferences.getInt("counter") == null) {
          this.preferences.setInt("counter", 0);
        }

        if (this.preferences.getString("day") == null) {
          DateTime now = new DateTime.now();
          DateTime date = new DateTime(now.year, now.month, now.day);
          this.preferences.setString("day", date.toString());
        }

        stepCounter = this.preferences.getInt("counter");

        challenge = 10000;
      });
    });
  }

  Future<void> initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
      actualDay = this.preferences.getString("day");

      if (actualDay != null) {
        DateTime now = new DateTime.now();
        String today = new DateTime(now.year, now.month, now.day).toString();
        if (actualDay.toString() != today) {
          this.preferences.setInt("counter", _steps);
          this.preferences.setString("day", today.toString());
          stepCounter = this.preferences.getInt("counter");
        }
      }

      realSteps = _steps - stepCounter;
      percentage = double.parse(realSteps.toString()) / challenge;
      if (percentage > 1 || percentage < 0) {
        challenge = challenge + 5000;
      }
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
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
      _steps = 0;
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
                      realSteps.toString(),
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
                      setState(() {
                        DateTime now = new DateTime.now();
                        DateTime date =
                            new DateTime(now.year, now.month, now.day);
                        deleteStep(date);
                        realSteps = 0;
                        this.preferences.setInt("counter", _steps);
                        stepCounter = this.preferences.getInt("counter");
                      });
                    },
                    child: Text("Borrar", style: TextStyle(fontSize: 20)),
                  ),
                  new ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_steps != 0) {
                          stepCounter = this.preferences.getInt("counter");
                          if (stepCounter == null) {
                            stepCounter = 0;
                          }

                          createOrUpdate(realSteps);
                        }
                      });
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChallengeCompleted()),
                );
              },
              child: Text("Reto cumplido")),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Estadistics()),
                );
              },
              child: Text("Estadísticas")),
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
