// models.dart

class Exercise {
  final String exerciseName;
  final String category;
  final List<String> healthConditions;
  final List<int> ageRange;
  final List<String> equipmentRequired;
  final int reps;
  final int averageTime; // Use camelCase for variable names
  final String youtube;
  final String difficulty;

  Exercise({
    required this.exerciseName,
    required this.category,
    required this.healthConditions,
    required this.ageRange,
    required this.equipmentRequired,
    required this.reps,
    required this.averageTime, // camelCase
    required this.youtube,
    required this.difficulty,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseName: json['exercise_name'] ?? '',
      category: json['category'] ?? '',
      healthConditions: List<String>.from(json['health_conditions'] ?? []),
      ageRange: List<int>.from(json['age_range'] ?? []),
      equipmentRequired: List<String>.from(json['equipment_required'] ?? []),
      reps: json['reps'] ?? 0,
      averageTime: json['average_time'] ?? 0,
      youtube: json['youtube'] ?? '',
      difficulty: json['difficulty'] ?? '',
    );
  }
}

class Recommendation {
  final String exerciseName;
  final String category;

  Recommendation({
    required this.exerciseName,
    required this.category,
  });
}
