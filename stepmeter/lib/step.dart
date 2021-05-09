class Paso {
  int steps;
  DateTime date;

  Paso({this.steps, this.date});

  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'date': date.toString(),
    };
  }
}
