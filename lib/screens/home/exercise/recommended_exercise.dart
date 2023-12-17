import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:prototype/screens/home/exercise/fitness.dart';
import 'exercise_screen.dart';

class RecommendedExercisesPage extends StatefulWidget {
  final List<Exercise> recommendedExercises;

  RecommendedExercisesPage({required this.recommendedExercises});

  @override
  _RecommendedExercisesPageState createState() =>
      _RecommendedExercisesPageState();
}

class _RecommendedExercisesPageState extends State<RecommendedExercisesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended Exercises'),
      ),
      body: ListView.builder(
        itemCount: widget.recommendedExercises.length,
        itemBuilder: (context, index) {
          Exercise exercise = widget.recommendedExercises[index];
          TextEditingController repsController =
              TextEditingController(text: exercise.reps.toString());
          TextEditingController timeController =
              TextEditingController(text: exercise.timeForOneSet.toString());

          return Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Center(
                child: Text(exercise.name),
              ),
              subtitle: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Reps: ${exercise.reps}'),
                    Text('Time for a Set: ${exercise.timeForOneSet} secs'),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editExercise(context, exercise,
                                  (updatedExercise) {
                                setState(() {
                                  widget.recommendedExercises[index] =
                                      updatedExercise;
                                });
                              });
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _openYouTubeVideo(context, exercise.youtubeLink);
                          },
                          style: TextButton.styleFrom(
                            primary: Colors.blue,
                          ),
                          child: Row(
                            children: [
                              Text('Watch Video'),
                              Icon(
                                Icons.play_arrow,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseScreen(
                exercises: widget.recommendedExercises,
              ),
            ),
          );
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  void _openYouTubeVideo(BuildContext context, String youtubeLink) {
    var videoController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(youtubeLink) ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YoutubePlayer(
                controller: videoController,
                liveUIColor: Colors.amber,
                bottomActions: [
                  CurrentPosition(),
                  ProgressBar(isExpanded: true),
                  RemainingDuration(),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editExercise(BuildContext context, Exercise exercise,
      Function(Exercise) onUpdate) async {
    TextEditingController repsController =
        TextEditingController(text: exercise.reps.toString());
    TextEditingController timeController =
        TextEditingController(text: exercise.timeForOneSet.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Exercise'),
          content: Container(
            height: MediaQuery.of(context).size.width *
                0.42, // Set the desired width (80% of the screen width)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reps:'),
                TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                Text('Time for 1 Set (seconds):'),
                TextField(
                  controller: timeController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                exercise.reps = int.parse(repsController.text);
                exercise.timeForOneSet = int.parse(timeController.text);

                onUpdate(exercise);

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
