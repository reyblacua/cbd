class Paso {
  int steps;
  DateTime date;

  Paso({required this.steps, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'date': date.toString(),
    };
  }
}
