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

Future<void> createStep(Paso step) async {
  // Get a reference to the database.
  var db = await openDatabase('steps_database.db');
  await db.insert(
    'steps',
    step.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Paso>> getAllStep() async {
  var db = await openDatabase('steps_database.db');
  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('steps');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Paso(
      steps: maps[i]['steps'],
      date: DateTime.parse(maps[i]['date']),
    );
  });
}
