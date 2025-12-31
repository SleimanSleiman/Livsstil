import 'package:uuid/uuid.dart';

class DailyReflection {
  final String id;
  final DateTime date;
  final String? gratitude;       // Vad är jag tacksam för idag?
  final String? highlight;       // Dagens höjdpunkt
  final String? challenge;       // Vad var utmanande?
  final String? tomorrowFocus;   // Vad vill jag fokusera på imorgon?
  final int? moodRating;         // 1-5 humör

  DailyReflection({
    String? id,
    required this.date,
    this.gratitude,
    this.highlight,
    this.challenge,
    this.tomorrowFocus,
    this.moodRating,
  }) : id = id ?? const Uuid().v4();

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DailyReflection copyWith({
    String? gratitude,
    String? highlight,
    String? challenge,
    String? tomorrowFocus,
    int? moodRating,
  }) {
    return DailyReflection(
      id: id,
      date: date,
      gratitude: gratitude ?? this.gratitude,
      highlight: highlight ?? this.highlight,
      challenge: challenge ?? this.challenge,
      tomorrowFocus: tomorrowFocus ?? this.tomorrowFocus,
      moodRating: moodRating ?? this.moodRating,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'gratitude': gratitude,
    'highlight': highlight,
    'challenge': challenge,
    'tomorrowFocus': tomorrowFocus,
    'moodRating': moodRating,
  };

  factory DailyReflection.fromJson(Map<String, dynamic> json) => DailyReflection(
    id: json['id'],
    date: DateTime.parse(json['date']),
    gratitude: json['gratitude'],
    highlight: json['highlight'],
    challenge: json['challenge'],
    tomorrowFocus: json['tomorrowFocus'],
    moodRating: json['moodRating'],
  );

  static String moodEmoji(int mood) {
    switch (mood) {
      case 1: return '😔';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😊';
      default: return '😐';
    }
  }
}
