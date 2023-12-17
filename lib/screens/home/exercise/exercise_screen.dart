import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prototype/screens/home/exercise/after_exercise_bp.dart';
import 'package:prototype/screens/home/exercise/fitness.dart';

class ExerciseScreen extends StatefulWidget {
  final List<Exercise> exercises;

  ExerciseScreen({required this.exercises});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _currentExerciseIndex = 0;
  late Timer _timer;
  bool _isTimerPaused = false;
  int _totalTime = 0;
  bool _showRestartButton = false;
  bool _showNextButton = true;
  bool _showDoneButton = false;
  double totalTime = 0;

  // List to store the original timeForOneSet values
  List<int> originalTimeForOneSetValues = [];

  @override
  void initState() {
    super.initState();
    // Initialize the originalTimeForOneSetValues list
    originalTimeForOneSetValues =
        widget.exercises.map((exercise) => exercise.timeForOneSet).toList();
    _startTimer();
  }

  void _startTimer() {
    Exercise currentExercise = widget.exercises[_currentExerciseIndex];
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (!_isTimerPaused) {
          if (currentExercise.timeForOneSet > 0) {
            currentExercise.timeForOneSet--;
            _totalTime++;
            totalTime++;
          } else {
            _timer.cancel();
            // Exercise completed, show restart button
            _showRestartButton = true;
            if (!_showNextButton) {
              _showDoneButton = true;
            }
          }
        }
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isTimerPaused = !_isTimerPaused;
    });
  }

  void _restartExercise() {
    setState(() {
      // Restore the original timeForOneSet value
      widget.exercises[_currentExerciseIndex].timeForOneSet =
          originalTimeForOneSetValues[_currentExerciseIndex];
      _totalTime = 0;

      _showRestartButton = false;
    });
    _startTimer();
  }

  void _moveToNextExercise() {
    setState(() {
      _showRestartButton = false;
      _isTimerPaused = false;
      _showNextButton = true;
      if (_currentExerciseIndex < widget.exercises.length - 1) {
        // Move to the next exercise
        _currentExerciseIndex++;
        _timer.cancel();
        _startTimer();

        if (_currentExerciseIndex == widget.exercises.length - 1) {
          _showNextButton = false;

          print(totalTime);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _completeExercise() {
    // Navigate to the AfterExerciseBp screen and pass necessary data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AfterExerciseBp(
          exercises: widget.exercises,
          totalTime: _totalTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Exercise currentExercise = widget.exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reps : ${currentExercise.reps}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${currentExercise.name}',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Exercise Timer: ${currentExercise.timeForOneSet} seconds',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _togglePause(); // Pause / Resume button
              },
              child: Text(_isTimerPaused ? 'Resume' : 'Pause'),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: _showNextButton,
              child: ElevatedButton(
                onPressed: () {
                  _moveToNextExercise();
                },
                child: Text('Next Exercise'),
              ),
            ),
            Visibility(
              visible: _showDoneButton,
              child: ElevatedButton(
                onPressed: () {
                  _completeExercise();
                },
                child: Text('Complete'),
              ),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: _showRestartButton,
              child: ElevatedButton(
                onPressed: () {
                  _restartExercise();
                },
                child: Text('Restart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
