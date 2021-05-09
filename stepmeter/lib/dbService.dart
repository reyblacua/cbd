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

Future<void> checkExists(steps) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);

  Paso step = await getStep(date);

  if (step != null) {
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
    whereArgs: [date],
  );
}

Future<void> deleteStep(date) async {
  var db = await openDatabase('steps_database.db');

  await db.delete(
    'steps',
    where: "date = ?",
    whereArgs: [date],
  );
}
