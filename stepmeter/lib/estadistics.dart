import 'package:flutter/material.dart';
import 'dbService.dart';

class Estadistics extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EstadisticsState();
  }
}

class _EstadisticsState extends State<Estadistics> {
  var pasos;

  @override
  void initState() {
    super.initState();
    pasos = getEstadistics();
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
                    child: Column(
                  children: [
                    Container(
                      margin: new EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(children: [
                        Text("Pasos totales: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Text(snapshot.data["total"].toString(),
                            style: TextStyle(fontSize: 20))
                      ]),
                    ),
                    Container(
                      margin: new EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(children: [
                        Text("Máximo de pasos: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Text(snapshot.data["max"].toString(),
                            style: TextStyle(fontSize: 20))
                      ]),
                    ),
                    Container(
                      margin: new EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(children: [
                        Text("Mínimo de pasos: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Text(snapshot.data["min"].toString(),
                            style: TextStyle(fontSize: 20))
                      ]),
                    ),
                    Container(
                      margin: new EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(children: [
                        Text("Media de pasos: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Text(snapshot.data["avg"].toStringAsFixed(2),
                            style: TextStyle(fontSize: 20))
                      ]),
                    ),
                    Container(
                      margin: new EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(children: [
                        Text("Días registrados: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Text(snapshot.data["dias"].toString(),
                            style: TextStyle(fontSize: 20))
                      ]),
                    ),
                  ],
                ));
              }
            }));
  }
}
