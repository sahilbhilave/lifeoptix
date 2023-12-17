import 'package:flutter/material.dart';
import 'models.dart';
import 'api.dart';

class myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Recommendation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecommendationPage(),
    );
  }
}

class RecommendationPage extends StatefulWidget {
  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  late List<Recommendation> recommendations;
  late List<String> allEquipments;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Fetch exercise data from the API
    List<Exercise> exercises = await fetchExerciseData();

    // Extract all equipment names from the exercises
    allEquipments = exercises
        .expand((exercise) => exercise.equipmentRequired)
        .toSet()
        .toList();

    // Perform the API call (replace with your actual API call)
    // For now, using sample data
    List<String> likedExercises = ["Running", "Yoga"];
    List<String> userHealthConditions = ["Asthma"];
    List<String> recentExercises = [
      "Yoga",
      "Running",
      "Dancing",
      "Mountain Climbers",
      "Lunges"
    ];
    List<String> userEquipment = [];

    // Logic for getting recommendations based on API response
    // Replace this with your actual logic
    recommendations = getRecommendations(exercises, likedExercises,
        userHealthConditions, recentExercises, userEquipment);

    setState(() {});
  }

  List<Recommendation> getRecommendations(
      List<Exercise> exercises,
      List<String> likedExercises,
      List<String> userHealthConditions,
      List<String> recentExercises,
      List<String> userEquipment) {
    // Implement your logic to get recommendations based on user preferences
    // Replace this with your actual logic

    // For now, returning the first 5 exercises as recommendations
    return exercises
        .where((exercise) =>
            likedExercises.contains(exercise.exerciseName) ||
            exercise.healthConditions.every(
                (condition) => !userHealthConditions.contains(condition)) ||
            exercise.equipmentRequired
                .every((equipment) => userEquipment.contains(equipment)))
        .take(5)
        .map((exercise) => Recommendation(
              exerciseName: exercise.exerciseName,
              category: exercise.category,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Recommendations'),
      ),
      body: recommendations == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // TextField for user equipment input
                TextField(
                  onChanged: (value) {
                    // Filter equipment suggestions based on user input
                    List<String> filteredEquipments = allEquipments
                        .where((equipment) => equipment
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                    // TODO: Update UI with filteredEquipments (e.g., show suggestions)
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter Your Equipment',
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      Recommendation recommendation = recommendations[index];
                      return ListTile(
                        title: Text(recommendation.exerciseName),
                        subtitle: Text(recommendation.category),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
