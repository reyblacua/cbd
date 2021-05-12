import 'package:flutter/material.dart';

import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'dbService.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<CalendarScreen>
    with WidgetsBindingObserver {
  ScrollController _scrollController = new ScrollController();

  //Cambia los valores de día seleccionado y los eventos seleccionado cuando se presiona un día en el calendario
  void _handleNewDate(pasos, date) {
    setState(() {
      _selectedDay = date;
      _selectedEvents = pasos[_selectedDay] ?? [];
    });
  }

  List _selectedEvents;
  DateTime _selectedDay;
  Map finalMap;

  String formatDate(DateTime d) {
    return d.toString().substring(0, 19);
  }

  var pasos;
  String fromDate;
  String toDate;

  @override
  void initState() {
    super.initState();
    fromDate = DateTime(DateTime.now().year, DateTime.now().month).toString();
    toDate = DateTime(DateTime.now().year, DateTime.now().month + 1).toString();
    pasos = getAllStepFiltered(fromDate, toDate);
    _selectedEvents = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Barra superior de la vista
      appBar: AppBar(
        title: const Text('Stepmeter'),
      ),
      body: FutureBuilder<Map<DateTime, List>>(
        future: pasos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_selectedDay == null) {
              _selectedDay = DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day);

              finalMap = new Map<DateTime, List<Map<String, dynamic>>>();
              snapshot.data.forEach((key, value) {
                Map<String, dynamic> data = new Map<String, dynamic>();
                List<Map<String, dynamic>> list = List.empty(growable: true);
                data.putIfAbsent("name", () => value);
                data.putIfAbsent("isDone", () => true);
                list.add(data);
                finalMap.putIfAbsent(key, () => list);
              });

              _selectedEvents = snapshot.data[_selectedDay] ?? [];
            }
            return Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    //Creación del calendario
                    child: Calendar(
                      isExpanded: true,
                      startOnMonday: true,
                      weekDays: [
                        'Lunes',
                        'Martes',
                        'Miércoles',
                        'Jueves',
                        'Viernes',
                        'Sábado',
                        'Domingo'
                      ],
                      //Se pasan las citas a los eventos para que se muestren en el calendario
                      events: finalMap,
                      //Al cambiar del mes, se vuelve a realizar la consulta con el nuevo rango de fechas
                      onRangeSelected: (range) {
                        setState(() {
                          pasos = getAllStepFiltered(
                              range.from.toString(), range.to.toString());
                        });
                      },
                      //Si se selecciona una fecha, se llama al método definido anteriormente
                      onDateSelected: (date) =>
                          _handleNewDate(snapshot.data, date),
                      isExpandable: true,
                      eventDoneColor: Colors.blue,
                      selectedColor: Colors.blue[900],
                      todayColor: Colors.blue[900],
                      eventColor: Colors.grey,
                      dayOfWeekStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 11),
                    ),
                  ),
                  //Método para construir el listado de evento de un dia seleccionado
                  _buildEventList()
                ],
              ),
            );
            //Si la lista de resultados no es nula o se ha producido un error al obtener los datos de la bd, se muestra un mensaje de error
          } else if (snapshot.hasError) {
            return (Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: Text(snapshot.error.toString(),
                          style: DefaultTextStyle.of(context)
                              .style
                              .apply(fontSizeFactor: 1.2)))
                ]));
          }
          //Muestra un círculo de carga
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  //Construye el listado de eventos de un día
  Widget _buildEventList() {
    return Expanded(
      child: ListView.builder(
          controller: _scrollController,
          itemCount: _selectedEvents.length,
          itemBuilder: (BuildContext context, int index) {
            //Se implementan las traducciones de las razones de cita en la vista calendario
            var name = _selectedEvents[index].toString();
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.black12),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
              child: ListTile(
                title: Text(name + " pasos"),
                onTap: () {},
              ),
            );
          }),
    );
  }
}
