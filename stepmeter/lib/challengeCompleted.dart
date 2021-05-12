import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dbService.dart';

class ChallengeCompleted extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChallengeCompletedState();
  }
}

class _ChallengeCompletedState extends State<ChallengeCompleted> {
  var pasos;

  @override
  void initState() {
    super.initState();
    pasos = getAllDaysChallengeCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Barra superior de la vista
        appBar: AppBar(
          title: const Text('Stepmeter'),
        ),
        body: FutureBuilder(
            future: pasos,
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Container(
                    child: ListView.separated(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final f = new DateFormat('yyyy-MM-dd');
                    var fecha = f.format(snapshot.data[index].date);
                    return Container(
                        margin: new EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Column(children: [
                          Row(children: [
                            Text(
                                fecha +
                                    " : " +
                                    snapshot.data[index].steps.toString() +
                                    " pasos",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ])
                        ]));
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(height: 3, color: Colors.black);
                  },
                ));
              }
            }));
  }
}
