class StreakEntry {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String note;
  final String badgeName;
  final int daysReached;

  StreakEntry({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.badgeName,
    required this.daysReached,
  });

  // Convert StreakEntry → JSON map (for saving)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'note': note,
      'badgeName': badgeName,
      'daysReached': daysReached,
    };
  }

  // Convert JSON map → StreakEntry (for loading)
  factory StreakEntry.fromJson(Map<String, dynamic> json) {
    return StreakEntry(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      note: json['note'],
      badgeName: json['badgeName'],
      daysReached: json['daysReached'],
    );
  }
}
