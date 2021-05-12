import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stepmeter/step.dart';

Future<Database> createDB() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'steps_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE steps(date TEXT PRIMARY KEY, steps INT)",
      );
    },
    version: 1,
  );

  return database;
}

Future<Paso> getStep(date) async {
  var db = await openDatabase('steps_database.db');

  final List<Map<String, dynamic>> maps =
      await db.query('steps', where: "date = ?", whereArgs: [date]);

  List listPasos = List.generate(maps.length, (i) {
    return Paso(
      steps: maps[i]['steps'],
      date: DateTime.parse(maps[i]['date']),
    );
  });

  if (listPasos.isEmpty) {
    return null;
  }

  return listPasos[0];
}

Future<Map<DateTime, List<dynamic>>> getAllStepFiltered(
    fromDate, toDate) async {
  var db = await openDatabase('steps_database.db');

  final List<Map<String, dynamic>> maps = await db.query('steps',
      where: "date BETWEEN ? AND ?", whereArgs: [fromDate, toDate]);

  Map<DateTime, List<dynamic>> map = Map();
  for (Map i in maps) {
    List list = [];
    list.add(i['steps']);
    map[DateTime.parse(i['date'])] = list;
  }

  return map;
}

Future<List<Paso>> getAllDaysChallengeCompleted() async {
  var db = await openDatabase('steps_database.db');

  final List<Map<String, dynamic>> maps =
      await db.query('steps', where: "steps >= 100 ");

  return List.generate(maps.length, (i) {
    return Paso(
      steps: maps[i]['steps'],
      date: DateTime.parse(maps[i]['date']),
    );
  });
}

Future<List<Paso>> getAllStep() async {
  var db = await openDatabase('steps_database.db');

  final List<Map<String, dynamic>> maps = await db.query('steps');

  return List.generate(maps.length, (i) {
    return Paso(
      steps: maps[i]['steps'],
      date: DateTime.parse(maps[i]['date']),
    );
  });
}

Future<void> createOrUpdate(steps) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);

  Paso step = await getStep(date.toString());

  if (step == null) {
    await createStep(steps, date);
  } else {
    await updateStep(steps, date);
  }
}

Future<void> createStep(steps, date) async {
  Paso paso = new Paso(steps: steps, date: date);

  var db = await openDatabase('steps_database.db');
  await db.insert(
    'steps',
    paso.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateStep(steps, date) async {
  var db = await openDatabase('steps_database.db');

  Paso paso = new Paso(steps: steps, date: date);

  await db.update(
    'steps',
    paso.toMap(),
    where: "date = ?",
    whereArgs: [date.toString()],
  );
}

Future<void> deleteStep(date) async {
  var db = await openDatabase('steps_database.db');

  await db.delete(
    'steps',
    where: "date = ?",
    whereArgs: [date.toString()],
  );
}

Future<int> sumSteps() async {
  var db = await openDatabase('steps_database.db');

  final sum = await db.rawQuery("SELECT sum(steps) as sum FROM steps");
  return sum[0]["sum"];
}

Future<int> minSteps() async {
  var db = await openDatabase('steps_database.db');

  final min = await db.rawQuery("SELECT min(steps) as min FROM steps");
  return min[0]["min"];
}

Future<int> maxSteps() async {
  var db = await openDatabase('steps_database.db');

  final max = await db.rawQuery("SELECT max(steps) as max FROM steps");
  return max[0]["max"];
}

Future<double> averageSteps() async {
  var db = await openDatabase('steps_database.db');

  final avg = await db.rawQuery("SELECT avg(steps) as avg FROM steps");
  return avg[0]["avg"];
}

Future<int> daysRegistred() async {
  var db = await openDatabase('steps_database.db');

  final count = await db.rawQuery("SELECT count(*) as count FROM steps");
  return count[0]["count"];
}

Future<Map<String, dynamic>> getEstadistics() async {
  Map<String, dynamic> lista = new Map();
  int totalPasos = await sumSteps();
  int maxPasos = await maxSteps();
  int minPasos = await minSteps();
  double mediaPasos = await averageSteps();
  int diasRegistrados = await daysRegistred();

  lista.putIfAbsent("total", () => totalPasos);
  lista.putIfAbsent("max", () => maxPasos);
  lista.putIfAbsent("min", () => minPasos);
  lista.putIfAbsent("avg", () => mediaPasos);
  lista.putIfAbsent("dias", () => diasRegistrados);

  return lista;
}
