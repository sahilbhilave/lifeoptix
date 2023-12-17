// api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prototype/screens/home/exercise/exercise.dart';
import 'package:prototype/screens/home/exercise/models.dart';

Future<List<Exercise>> fetchExerciseData() async {
  final response = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/sahilbhilave/training_data/main/exercise_data.json'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((exercise) => Exercise.fromJson(exercise)).toList();
  } else {
    throw Exception('Failed to load exercise data');
  }
}
