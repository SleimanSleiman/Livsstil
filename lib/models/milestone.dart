class Milestone {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final String icon;
  final bool achieved;
  final DateTime? achievedDate;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.icon,
    this.achieved = false,
    this.achievedDate,
  });

  Milestone copyWith({
    bool? achieved,
    DateTime? achievedDate,
  }) {
    return Milestone(
      id: id,
      title: title,
      description: description,
      targetCount: targetCount,
      icon: icon,
      achieved: achieved ?? this.achieved,
      achievedDate: achievedDate ?? this.achievedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'targetCount': targetCount,
    'icon': icon,
    'achieved': achieved,
    'achievedDate': achievedDate?.toIso8601String(),
  };

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    targetCount: json['targetCount'],
    icon: json['icon'],
    achieved: json['achieved'] ?? false,
    achievedDate: json['achievedDate'] != null 
        ? DateTime.parse(json['achievedDate']) 
        : null,
  );

  static List<Milestone> defaultMilestones = [
    Milestone(
      id: 'first_week',
      title: 'Första veckan',
      description: '7 dagar av medvetna val',
      targetCount: 7,
      icon: '🌱',
    ),
    Milestone(
      id: 'thirty_days',
      title: '30 dagar',
      description: 'En månad av identitetsbeteenden',
      targetCount: 30,
      icon: '🌿',
    ),
    Milestone(
      id: 'hundred_walks',
      title: '100 promenader',
      description: 'Du har rört på dig 100 gånger',
      targetCount: 100,
      icon: '🚶‍♂️',
    ),
    Milestone(
      id: 'fifty_meals',
      title: '50 medvetna måltider',
      description: 'Du har ätit medvetet 50 gånger',
      targetCount: 50,
      icon: '🥗',
    ),
    Milestone(
      id: 'ninety_days',
      title: '90 dagar',
      description: 'Tre månader av hållbara val',
      targetCount: 90,
      icon: '🌳',
    ),
  ];
}
