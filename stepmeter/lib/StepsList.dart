import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dbService.dart';

class StepList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StepListState();
  }
}

class _StepListState extends State<StepList> {
  var pasos;

  @override
  void initState() {
    super.initState();
    pasos = getAllStep();
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
                                    " - " +
                                    snapshot.data[index].steps.toString() +
                                    " pasos",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    deleteStep(snapshot.data[index].date);
                                    pasos = getAllStep();
                                  });
                                })
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
