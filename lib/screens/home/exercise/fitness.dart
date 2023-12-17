import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prototype/screens/home/exercise/recommended_exercise.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ExerciseListScreen(),
    );
  }
}

class ExerciseListScreen extends StatefulWidget {
  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late List<Exercise> exercises;
  late List<String> equipmentRequiredList;
  late List<String> healthConditionsList;
  late List<String> selectedEquipmentList = [];
  late List<String> selectedHealthConditionsList = [];
  late List<String> recentExercisesList = [];
  DateTime selectedDate = DateTime.now();
  String dateString = "";
  List<String> filteredEquipmentList = [];
  List<String> filteredHealthConditionsList = [];
  String url = 'http://127.0.0.1:5000/recommend';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<VisualizeExercise> exercisesData = [];
  String selectedExercise = '';
  TextEditingController _equipmentTextController = TextEditingController();
  TextEditingController _healthConditionsTextController =
      TextEditingController();

  int fitnessScore = 0;

  late String selectedDifficulty = 'Advanced';
  late int selectedTime = 30;
  late String selectedCategory = 'Core';

  List<String> difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];
  List<String> exerciseCategories = ['Lower Body', 'Core', 'Flexibility'];

  @override
  void initState() {
    super.initState();
    DateTime currentDate = DateTime.now();
    dateString =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    fetchExerciseData();
    fetchFitnessScore();
  }

  Future<void> fetchExerciseData() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/sahilbhilave/training_data/main/exercise_data.json'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      List<Exercise> exercisesList =
          jsonList.map((json) => Exercise.fromJson(json)).toList();

      equipmentRequiredList = exercisesList
          .map((exercise) => exercise.equipmentRequired)
          .expand((i) => i)
          .toSet()
          .toList();
      healthConditionsList = exercisesList
          .map((exercise) => exercise.healthConditions)
          .expand((i) => i)
          .toSet()
          .toList();

      difficultyLevels = exercisesList
          .map((exercise) => exercise.difficulty)
          .toSet() // Use a Set to eliminate duplicates
          .toList();

      exerciseCategories = exercisesList
          .map((exercise) => exercise.category)
          .toSet() // Use a Set to eliminate duplicates
          .toList();

      setState(() {
        exercises = exercisesList;
      });
    } else {
      throw Exception('Failed to load exercise data');
    }
  }

  Future<void> fetchFitnessScore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data()!;
          Map<String, dynamic> points = userData['points'] ?? {};
          setState(() {
            fitnessScore = points['fitness'] ?? 0;
          });
        }
      }
    } catch (e) {
      print("Error fetching fitness score: $e");
    }
  }

  void filterList(
      List<String> sourceList, String query, List<String> targetList) {
    setState(() {
      if (query.isNotEmpty) {
        targetList.clear();
        targetList.addAll(sourceList
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList());
      } else {
        targetList.clear();
      }
    });
  }

  void deleteSelectedEquipment(String equipment) {
    setState(() {
      selectedEquipmentList.remove(equipment);
    });
  }

  void deleteSelectedHealthCondition(String healthCondition) {
    setState(() {
      selectedHealthConditionsList.remove(healthCondition);
    });
  }

  Future<void> getRecentExercise() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Reference to the user's exercises collection
        CollectionReference userExercises = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('exercises');

        // Query to retrieve the latest exercise document
        QuerySnapshot querySnapshot = await userExercises
            .orderBy('name', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the latest exercise document
          DocumentSnapshot latestExercise = querySnapshot.docs.first;

          // Extract the exercise data
          String dateString = latestExercise['name'];
          List<String> exerciseList =
              List<String>.from(latestExercise['exercises']);
          recentExercisesList = exerciseList;
          // Print or use the data as needed
          print('Latest Exercise Date: $dateString');
          print('Exercise Names: $recentExercisesList');
        } else {
          print('No exercises found for the user');
        }
      } else {
        print('User not signed in');
      }
    } catch (e) {
      print('Error getting recent exercise: $e');
    }
  }

  Future<void> recommendExercises() async {
    getRecentExercise();
    final Map<String, dynamic> requestBody = {
      "user_age": 30,
      "liked_exercises": [],
      "user_health_conditions": selectedHealthConditionsList,
      "recent_exercises": recentExercisesList,
      "user_equipment": selectedEquipmentList.toSet().toList(),
      "difficulty": selectedDifficulty,
      "time": selectedTime,
      "category": selectedCategory,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print("Recommended Exercises: ${response.body}");
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<Map<String, dynamic>> recommendedExercises =
          List<Map<String, dynamic>>.from(
              responseBody['recommended_exercises']);

      List<Exercise> recommendedExercisesList = recommendedExercises
          .map((exercise) => Exercise(
              name: exercise['exercise_name'],
              equipmentRequired: [],
              healthConditions: [],
              difficulty: '',
              category: '',
              reps: exercise['reps'],
              averageTime: 0,
              youtubeLink: exercise['youtube_link'],
              timeForOneSet: 60))
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendedExercisesPage(
            recommendedExercises: recommendedExercisesList,
          ),
        ),
      );
    } else {
      print(
          "Failed to recommend exercises. Status code: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Fitness Score : $fitnessScore',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 3.0),
                      child: TextFormField(
                        controller: _equipmentTextController,
                        decoration: const InputDecoration(
                          labelText: 'Equipment',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fitness_center),
                        ),
                        onChanged: (value) {
                          filterList(equipmentRequiredList, value,
                              filteredEquipmentList);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 3.0),
                      child: TextFormField(
                        controller: _healthConditionsTextController,
                        decoration: const InputDecoration(
                          labelText: 'Problems',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        onChanged: (value) {
                          filterList(healthConditionsList, value,
                              filteredHealthConditionsList);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (filteredEquipmentList.isNotEmpty)
                Container(
                  height: 150,
                  color: const Color.fromARGB(255, 234, 236, 204),
                  child: ListView.builder(
                    itemCount: filteredEquipmentList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredEquipmentList[index]),
                        onTap: () {
                          setState(() {
                            String selectedEquipment =
                                filteredEquipmentList[index];
                            if (!selectedEquipmentList
                                .contains(selectedEquipment)) {
                              selectedEquipmentList.add(selectedEquipment);
                            }
                            filteredEquipmentList.clear();
                          });
                          _equipmentTextController.clear();
                        },
                      );
                    },
                  ),
                ),
              if (filteredHealthConditionsList.isNotEmpty)
                Container(
                  height: 150,
                  color: const Color.fromARGB(255, 192, 226, 194),
                  child: ListView.builder(
                    itemCount: filteredHealthConditionsList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredHealthConditionsList[index]),
                        onTap: () {
                          setState(() {
                            String selectedHealthCondition =
                                filteredHealthConditionsList[index];
                            if (!selectedHealthConditionsList
                                .contains(selectedHealthCondition)) {
                              selectedHealthConditionsList
                                  .add(selectedHealthCondition);
                            }
                            filteredHealthConditionsList.clear();
                          });
                          _healthConditionsTextController.clear();
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Selected Equipment: ${selectedEquipmentList.join(', ')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  for (String selectedEquipment in selectedEquipmentList)
                    ElevatedButton(
                      onPressed: () =>
                          deleteSelectedEquipment(selectedEquipment),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 3),
                        // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        '$selectedEquipment',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Selected Health Conditions: ${selectedHealthConditionsList.join(', ')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  for (String selectedHealthCondition
                      in selectedHealthConditionsList)
                    ElevatedButton(
                      onPressed: () => deleteSelectedHealthCondition(
                          selectedHealthCondition),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('$selectedHealthCondition'),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  // Expanded(
                  //   child: Container(
                  //     margin: EdgeInsets.only(right: 8.0),
                  //     child: TextFormField(
                  //       keyboardType: TextInputType.number,
                  //       decoration: InputDecoration(
                  //         labelText: 'Exercise Time (minutes)',
                  //         border: OutlineInputBorder(),
                  //         prefixIcon: Icon(Icons.timer),
                  //       ),
                  //       onChanged: (value) {
                  //         setState(() {
                  //           selectedTime = int.tryParse(value) ?? 0;
                  //         });
                  //       },
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 0.0),
                      width: 10,
                      child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: exerciseCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      child: DropdownButtonFormField<String>(
                        value: selectedDifficulty,
                        items: difficultyLevels.map((difficulty) {
                          return DropdownMenuItem<String>(
                            value: difficulty,
                            child: Text(difficulty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDifficulty = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.star),
                        ),
                        style: const TextStyle(
                            fontSize: 14.0, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    url = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),

              // Button to use the URL inside uri.parse()
              ElevatedButton(
                onPressed: () {
                  // Use the URL inside uri.parse()
                  Uri parsedUri = Uri.parse(url);
                  // Now you can use the parsedUri as needed
                  print('Parsed URL: $parsedUri');
                },
                child: const Text('Parse URL'),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: recommendExercises,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(), // Make it circular
                  //primary: Colors.greenAccent, // Set the button color
                ),
                child: Ink(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, // Match the button shape
                  ),
                  child: InkWell(
                    onTap: recommendExercises,
                    borderRadius:
                        BorderRadius.circular(50.0), // Match the button shape
                    child: Container(
                      width: 80.0, // Set the desired width
                      height: 80.0, // Set the desired height

                      alignment: Alignment.center,
                      child: const Text(
                        'Begin',
                        style: TextStyle(
                          fontSize: 16.0,

                          //color: Colors.white, // Set the text color
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // New Code for Date Picker and Fitness Graph
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        "Past Data",
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () => _selectDate(context),
                    //   style: ElevatedButton.styleFrom(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //     ),
                    //   ),
                    //   child: const Text('Select Date'),
                    // ),
                    if (selectedDate != null)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          // Text(
                          //   'Fitness Data for ${dateString}',
                          //   style: const TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          FutureBuilder(
                            future: _fetchFitnessDataAll(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Column(
                                  children: [
                                    _buildScoreGraph(),
                                    _buildTimeGraph(),
                                    _displayExercises(),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _displayExercises() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Exercises Data:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (exercisesData.isNotEmpty)
          for (VisualizeExercise exercise in exercisesData)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text('Exercise Date: ${exercise.name}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fitness Points Earned: ${exercise.score}'),
                    Text('BP after Exercise: ${exercise.bp}'),
                    Text('Total Time: ${exercise.totalTime} seconds'),
                    Text('Exercises: ${exercise.exercises.join(', ')}'),
                  ],
                ),
              ),
            ),
        if (exercisesData.isEmpty)
          Text(
            'No exercises data available for the selected date.',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Future<void> _fetchFitnessData(bool selectedDate) async {
    print("Searching!!");

    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user?.uid)
        .collection('exercises')
        .where('name', isEqualTo: dateString)
        .get();

    exercisesData = snapshot.docs
        .map((doc) => VisualizeExercise(
            id: doc.id,
            name: doc['name'],
            exercises: doc['exercises'],
            totalTime: doc['totalTime'] ?? 5.0,
            bp: doc['averageBp'],
            score: doc['score']))
        .toList();

    if (selectedDate) {
      setState(() {});
    }
  }

  Widget _buildScoreGraph() {
    return Container(
      height: 300,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        legend: Legend(isVisible: true, position: LegendPosition.top),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        series: <ChartSeries<VisualizeExercise, String>>[
          SplineSeries<VisualizeExercise, String>(
            dataSource: exercisesData,
            xValueMapper: (VisualizeExercise exercise, _) => exercise.name,
            yValueMapper: (VisualizeExercise exercise, _) => exercise.score,
            color: Colors.black,
            name: 'Points Earned',
            enableTooltip: true,
            animationDuration: 1000,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
            ),
          ),
        ],
        trackballBehavior: TrackballBehavior(
          enable: true,
          tooltipSettings: InteractiveTooltip(
            enable: true,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeGraph() {
    return Container(
      height: 300,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        legend: Legend(isVisible: true, position: LegendPosition.top),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        series: <ChartSeries<VisualizeExercise, String>>[
          SplineSeries<VisualizeExercise, String>(
            dataSource: exercisesData,
            xValueMapper: (VisualizeExercise exercise, _) => exercise.name,
            yValueMapper: (VisualizeExercise exercise, _) => exercise.totalTime,
            color: Colors.green,
            name: 'Total Time Spent',
            enableTooltip: true,
            animationDuration: 1000,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
            ),
          ),
        ],
        trackballBehavior: TrackballBehavior(
          enable: true,
          tooltipSettings: InteractiveTooltip(
            enable: true,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        dateString =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        selectedDate = picked;
      });

      // Fetch new fitness data for the selected date
      await _fetchFitnessData(true);
    }
  }

  Future<void> _fetchFitnessDataAll() async {
    print("Searching!!");

    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user?.uid)
        .collection('exercises')
        .orderBy('name', descending: false)
        .get();
    exercisesData = snapshot.docs
        .map((doc) => VisualizeExercise(
            id: doc.id,
            name: doc['name'],
            exercises: doc['exercises'],
            totalTime: doc['totalTime'] ?? 5.0,
            bp: doc['averageBp'],
            score: doc['score']))
        .toList();
  }
}

class VisualizeExercise {
  final String id;
  final String name;
  final int bp;
  final int score;
  final int totalTime;
  final List<dynamic> exercises;

  VisualizeExercise({
    required this.id,
    required this.name,
    required this.bp,
    required this.score,
    required this.totalTime,
    required this.exercises,
  });
}

class Exercise {
  final String name;
  final List<String> equipmentRequired;
  final List<String> healthConditions;
  final String difficulty;
  int reps;
  int averageTime;
  final String youtubeLink;
  final String category;
  int timeForOneSet;

  Exercise(
      {required this.name,
      required this.equipmentRequired,
      required this.healthConditions,
      required this.difficulty,
      required this.reps,
      required this.averageTime,
      required this.youtubeLink,
      required this.category,
      required this.timeForOneSet});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['exercise_name'] ?? '',
      equipmentRequired: (json['equipment_required'] as List<dynamic>? ?? [])
          .map((dynamic e) => e as String)
          .toList(),
      healthConditions: (json['health_conditions'] as List<dynamic>? ?? [])
          .map((dynamic e) => e as String)
          .toList(),
      difficulty: json['difficulty'] ?? '',
      reps: json['reps'] ?? 0,
      averageTime: json['average_time'] ?? 0,
      youtubeLink: json['youtube_link'] ?? '',
      category: json['category'] ?? '',
      timeForOneSet: 60,
    );
  }
  Map<String, dynamic> toMap() {
    return {'name': name, 'category': category, 'difficulty': difficulty};
  }
}
