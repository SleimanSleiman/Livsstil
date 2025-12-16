class WeightEntry {
  final DateTime date;
  final double weight;
  final String? reflection;

  WeightEntry({
    required this.date,
    required this.weight,
    this.reflection,
  });

  String get monthKey => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
    'reflection': reflection,
  };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    date: DateTime.parse(json['date']),
    weight: (json['weight'] as num).toDouble(),
    reflection: json['reflection'],
  );
}
