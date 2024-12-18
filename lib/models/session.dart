class Session {
  final int steps;
  final DateTime date;
  final Duration duration;

  Session({
    required this.steps,
    required this.date,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'date': date.toIso8601String(),
      'duration': duration.inSeconds,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      steps: json['steps'] as int,
      date: DateTime.parse(json['date'] as String),
      duration: Duration(seconds: json['duration'] as int),
    );
  }
}
