import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:prototype/screens/home/exercise/fitness.dart';
import 'package:prototype/screens/home/home.dart';

class AfterExerciseBp extends StatelessWidget {
  List<Exercise> exercises = [];
  int totalTime = 0;

  AfterExerciseBp({required this.exercises, required this.totalTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart BPM Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(
        exercises: exercises,
        totalTime: totalTime,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<Exercise> exercises;
  final int totalTime;

  HomePage({required this.exercises, required this.totalTime});

  @override
  _HomePageState createState() => _HomePageState(
        exercises: exercises,
        totalTime: totalTime,
      );
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<SensorValue> data = [];
  List<SensorValue> bpmValues = [];
  int currentBPM = 0;
  int averageBPM = 0;
  List<String> exerciseList = [];
  bool isBPMEnabled = false;
  int measurementDuration = 30;
  int remainingTime = 30;
  late Timer _timer;
  DateTime measurementStartTime = DateTime.now();
  List<Exercise> exercises = [];
  int totalTime = 0;

  _HomePageState({
    required this.exercises,
    required this.totalTime,
  });

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: measurementDuration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Heart BPM'),
      ),
      body: Column(
        children: [
          SizedBox(height: 200),
          isBPMEnabled
              ? HeartBPMDialog(
                  context: context,
                  showTextValues: true,
                  borderRadius: 10,
                  onRawData: (value) {
                    setState(() {
                      if (data.length >= 100) data.removeAt(0);
                      data.add(value);
                    });
                  },
                  onBPM: (value) => setState(() {
                    if (bpmValues.length >= 100) bpmValues.removeAt(0);
                    bpmValues
                        .add(SensorValue(value: value, time: DateTime.now()));
                    currentBPM = value;
                  }),
                )
              : const SizedBox(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Current BPM: ${averageBPM.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.favorite_rounded),
                  label: Text(
                    isBPMEnabled ? "Stop Measurement" : "Measure BPM",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _toggleBPMMeasurement,
                  style: ElevatedButton.styleFrom(
                    primary: isBPMEnabled ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                if (isBPMEnabled)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Text(
                        'Time remaining: ${remainingTime}s',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                if (!isBPMEnabled && averageBPM > 0)
                  Text(
                    'Average BPM: ${averageBPM.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),
                if (!isBPMEnabled && averageBPM > 0)
                  ElevatedButton(
                    onPressed: () {
                      _handleWorkoutCompletion();
                    },
                    child: Text(
                      "Complete Workout",
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBPMMeasurement() {
    setState(() {
      if (isBPMEnabled) {
        isBPMEnabled = false;
        _calculateAverageBPM();
        remainingTime = measurementDuration;
        _timer.cancel();
        _animationController.stop();
        //_storeWorkoutData();
      } else {
        isBPMEnabled = true;
        measurementStartTime = DateTime.now();
        _startTimer();
        _animationController.forward(from: 0.0);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          isBPMEnabled = false;
          _calculateAverageBPM();
          remainingTime = measurementDuration;
          _timer.cancel();
          _animationController.stop();
          //_storeWorkoutData();
        }
      });
    });
  }

  void _calculateAverageBPM() {
    if (bpmValues.isNotEmpty) {
      num sum = bpmValues.map((value) => value.value).reduce((a, b) => a + b);
      averageBPM = (sum / bpmValues.length).ceil() as int;
    }
  }

  void _handleWorkoutCompletion() {
    _storeWorkoutData();
    print("Workout Completed!");
  }

  void _storeWorkoutData() async {
    for (int i = 0; i < exercises.length; i++) {
      exerciseList.add(exercises[i].name);
    }
    // Get the current user
    DateTime currentDate = DateTime.now();
    String dateString =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      CollectionReference userExercises =
          _firestore.collection('users').doc(user.uid).collection('exercises');

      double score = ((totalTime + averageBPM) / 100);
      int fitnessScore = score.ceil();
      if (fitnessScore > 20) fitnessScore = 20;
      // Add a document under the user's exercises collection
      await userExercises.add({
        'name': dateString,
        'score': fitnessScore,
        'exercises': exerciseList,
        'totalTime': totalTime,
        'averageBp': averageBPM,
      });

      _updateFirebaseData(fitnessScore);

      String message = "You are awarded $fitnessScore Fitness Points";

      // Colorful Text
      Text colorfulText = Text(
        message,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );

      final snackBar = SnackBar(
        content: colorfulText,
        duration: Duration(seconds: 2),
      );

      // Show SnackBar at the top center
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ExercisePage()),
      );
      print('Workout data stored successfully!');
    }
  }

  Future<void> _updateFirebaseData(dynamic value) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Replace 'users' with the actual name of your Firebase collection
      DocumentReference<Map<String, dynamic>> userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get the current data
      DocumentSnapshot<Map<String, dynamic>> snapshot = await userDocRef.get();
      Map<String, dynamic> userData = snapshot.data() ?? {};

      // Get the current points map
      Map<String, dynamic> points = userData['points'] ?? {'fitness': 0};

      // Update the points map based on the key
      points['fitness'] = (points['fitness'] ?? 0) + value;

      // Update the Firestore document with the new points map
      await userDocRef.update({'points': points});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
