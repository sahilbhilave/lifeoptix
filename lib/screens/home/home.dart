import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype/services/auth.dart';

final api = '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';
bool isDelete = false;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int healthScore = 0;
  int workScore = 0;
  int socialScore = 0;
  int fitnessScore = 0;
  int mindScore = 0;
  List<Task> tasks = [];
  double iconSize = 36.0;

  bool isHeartBeating = false;
  bool _isAddingTask = false;
  //late User _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    //_fetchHealthScore();
    _loadTasks();
  }

  void checkforRequests() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get the current user's email
      List<String> access = [];
      DocumentSnapshot<Map<String, dynamic>> userDoc2 = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      String myEmail = userDoc2['email'];

      // Check for requests in the 'requests' collection
      QuerySnapshot<Map<String, dynamic>> requestQuery = await FirebaseFirestore
          .instance
          .collection('requests')
          .where('to', isEqualTo: myEmail)
          .get();

      if (requestQuery.docs.isNotEmpty) {
        // If there are requests, show an AlertDialog
        QueryDocumentSnapshot<Map<String, dynamic>> requestDoc =
            requestQuery.docs[0];

        String em = requestDoc['senderemail'];
        String requestId = requestDoc.id; // Get the request ID

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Received Request",
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sent By: ${requestDoc['sendername']}\nYou received a request from ${requestDoc['senderemail']}",
                    textAlign: TextAlign.center,
                  ),
                  // SizedBox(height: 20),
                  // CheckboxListTile(
                  //   title: const Text('Give Access to Work'),
                  //   value:
                  //       false, // Use a state variable if you want to track the state
                  //   onChanged: (bool? value) {
                  //     // Handle checkbox state change
                  //     // You can set the state to use these values later
                  //     if (value != null && value) {
                  //       access.add('Work');
                  //     }
                  //   },
                  // ),
                  // CheckboxListTile(
                  //   title: const Text('Give Access to Fitness'),
                  //   value:
                  //       false, // Use a state variable if you want to track the state
                  //   onChanged: (bool? value) {
                  //     // Handle checkbox state change
                  //     // You can set the state to use these values later
                  //     if (value != null && value) {
                  //       access.add('Fitness');
                  //     }
                  //   },
                  // ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Implement logic for accepting the request
                    print('Request Accepted');

                    final DateTime now = DateTime.now();
                    final String todayDate =
                        '${now.year}-${now.month}-${now.day}';

                    // Store the request information in the 'follow' collection
                    await FirebaseFirestore.instance.collection('follow').add({
                      'from': requestDoc['senderemail'],
                      'to': myEmail,
                      'date': todayDate,
                      'access': access,
                    });

                    // Assuming you have a Firestore collection named 'requests'
                    await FirebaseFirestore.instance
                        .collection('requests')
                        .doc(requestId)
                        .delete();

                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('Accept Request'),
                ),
                TextButton(
                  onPressed: () async {
                    // Implement logic for declining the request
                    print('Request Declined');

                    // Assuming you have a Firestore collection named 'requests'
                    await FirebaseFirestore.instance
                        .collection('requests')
                        .doc(requestId)
                        .delete();

                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('Decline Request'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _fetchHealthScore() async {
    try {
      //_user = FirebaseAuth.instance.currentUser!;
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user?.uid)
          .get();

      // Assuming 'healthScore' is the field in Firestore containing the health score
      //if (userDoc.exists) {
      //setState(() {
      print("Her");
      healthScore = userDoc['healthScore'] ??
          0; // Use a default value if 'healthScore' is not present
      //});
      // }
    } catch (e) {
      print("Error fetching health score: $e");
    }

    setState(() {});
  }

  void _loadTasks() async {
    checkforRequests();
    String category = "user-task";
    print("Loading");
    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('tasks')
            .orderBy('priority', descending: true) // Order by priority
            .get();

    tasks = snapshot.docs
        .map((doc) => Task(
              id: doc.id,
              name: doc['name'],
              deadline: (doc['deadline'] as Timestamp?)?.toDate(),
              priority: doc['priority'] ?? 5.0,
              description: doc['description'],
              category: doc['category'],
            ))
        .toList();

    // DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
    //     .instance
    //     .collection('users')
    //     .doc(user?.uid)
    //     .get();
    // healthScore = userDoc['healthScore'];

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data()!;
        Map<String, dynamic> points = userData['points'] ?? {};
        setState(() {
          workScore = points['work'] ?? 0;
          socialScore = points['social'] ?? 0;
          fitnessScore = points['fitness'] ?? 0;
          mindScore = points['meditation'] ?? 0;
          healthScore = workScore + socialScore + fitnessScore + mindScore;
        });
      }
    }
    // healthScore = userDoc['healthScore'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _calculateBackgroundColor();
    return Scaffold(
      appBar:
          AppBar(backgroundColor: backgroundColor, toolbarHeight: 35, actions: [
        IconButton(
          onPressed: () {
            _signOut();
          },
          icon: const Icon(Icons.logout),
        ),
      ]),
      body: Column(
        children: [
          ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(
              color: backgroundColor,
              padding: const EdgeInsets.only(left: 18, right: 18, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Work Score : $workScore',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Social Score : $socialScore',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Fitness Score : $fitnessScore',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mind Score : $mindScore',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  //SizedBox(height: 24),
                  const Text(
                    'Today\'s Health Score',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$healthScore / 100',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 36.0, end: iconSize),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return GestureDetector(
                            onTap: () {
                              _loadTasks();
                              setState(() {
                                iconSize = isHeartBeating ? 36.0 : 40.0;
                                isHeartBeating = !isHeartBeating;
                              });
                            },
                            child: Icon(
                              Icons.favorite,
                              size: value,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              _showRecommendSocialTasksPopup(context);
            },
            child: const Text('Recommend Tasks'),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            'Total Tasks',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text('No tasks available'),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskListTile(
                        task: tasks[index],
                        onEdit: () => _showTaskEditor(context, tasks[index]),
                        onDelete: () =>
                            _showDeleteConfirmation(context, tasks[index]),
                        onComplete: () => _completeTask(context, tasks[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskAdder(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const AuthPage(), // Replace with your initial route
        ),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _showRecommendSocialTasksPopup(BuildContext context) {
    String userInput = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Recommend Social Tasks'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      userInput = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'What are you doing today?',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (!userInput.isEmpty) {
                        setState(() {
                          _isLoading = true;
                        });

                        String response = await _getOpenAIResponse2(userInput);

                        setState(() {
                          _isLoading = false;
                        });

                        _displayRecommendedTasksPopup(context, response);
                      }
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator() // Show loading indicator
                        : const Text('Get Recommendations'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _displayRecommendedTasksPopup(BuildContext context, String response) {
    print(response);
    List<SocialTask> socialTasks = _parseResponse(response);
    print(socialTasks);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recommended Tasks'),
          content: Container(
            width: 300, // Set the desired width
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the recommended tasks as a checkbox list
                  if (socialTasks.isEmpty)
                    const Text("No Recommendations, try again!!"),
                  for (int i = 0; i < socialTasks.length; i++)
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return ListTile(
                          title: Text(socialTasks[i].title),
                          subtitle: Text(socialTasks[i].description),
                          trailing: Checkbox(
                            value: socialTasks[i].isChecked,
                            onChanged: (bool? value) {
                              // Update the task's isChecked status using StateSetter
                              setState(() {
                                socialTasks[i].isChecked = value!;
                              });
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Add the selected tasks to the 'social tasks' collection in Firebase

                _addSelectedSocialTasksToFirebase(socialTasks);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  List<SocialTask> _parseResponse(String response) {
    RegExp regex = RegExp(r'({.*?})', dotAll: true);
    Match? match = regex.firstMatch(response);

    if (match != null) {
      String systemOutput = match.group(1)!;
      Map<String, dynamic> data = json.decode(systemOutput);
      print("data $data");

      List<SocialTask> tasks = [];

      for (int i = 1; i <= 5; i++) {
        String titleKey = 'title$i';
        String descriptionKey = 'description$i';

        if (data.containsKey(titleKey) && data.containsKey(descriptionKey)) {
          tasks.add(
            SocialTask(
              title: data[titleKey],
              description: data[descriptionKey],
            ),
          );
        }
      }

      return tasks;
    } else {
      print("No match found");
      return [];
    }
  }

  void _addSelectedSocialTaskssToFirebase(List<SocialTask> socialTasks) async {
    // Get the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Reference to the 'social_tasks' collection in Firestore
      CollectionReference socialTasksCollection =
          FirebaseFirestore.instance.collection('social_tasks');

      // Iterate through selected tasks and add them to Firestore
      for (SocialTask task in socialTasks) {
        if (task.isChecked) {
          // Create a new document with a unique ID
          await socialTasksCollection.add({
            'title': task.title,
            'description': task.description,
            'userId': user.uid, // Store the user ID for authentication
          });
        }
      }
    } else {
      // Handle the case where the user is not authenticated
      print('User not authenticated. Unable to add tasks to Firebase.');
    }
  }

  Future<void> _addSelectedSocialTasksToFirebase(
      List<SocialTask> socialTasks) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Add user data to Firestore
      for (SocialTask task in socialTasks) {
        if (task.isChecked) {
          DateTime? deadline = null;
          double a = 10.0;
          _addTaskToFirestore(
              task.title, task.description, deadline, 10.0, "ai-task");
          // Create a new document with a unique ID
          // await FirebaseFirestore.instance
          //     .collection('users')
          //     .doc(user.uid)
          //     .collection('tasks')
          //     .add({
          //   'name': task.title,
          //   'description': task.description,
          //   'category': 'ai-task',
          //   'deadline': deadline,
          //   'priority': 10,
          // });
        }
      }
    } else {
      // Handle the case where the user is not authenticated
      print('User not authenticated. Unable to add tasks to Firebase.');
    }
    _loadTasks();
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Home(),
    //   ),
    // );

    print("Task added successfully.");
  }

  Color _calculateBackgroundColor() {
    // You can adjust the thresholds and colors based on your requirements
    if (healthScore >= 80) {
      // Green color when health score is 80 or above
      return Colors.green;
    } else if (healthScore >= 60) {
      // Gradual transition from orange to green for health score between 60 and 79
      return Color.lerp(Colors.orange, Colors.green, (healthScore - 60) / 20)!;
    } else {
      // Orange color when health score is below 60
      return const Color.fromARGB(255, 199, 175, 255);
    }
  }

  Future<void> _showTaskAdder(BuildContext context) async {
    String taskName = '';
    DateTime? deadline;

    setState(() {
      _isAddingTask = true;
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskAdderDialog(
          onTaskAdded: (name, description, selectedDeadline, priority) async {
            await _addTaskToFirestore(
                name, description, selectedDeadline, priority, "user-task");
            _loadTasks(); // Refresh the task list
            Navigator.of(context).pop();
            setState(() {
              _isAddingTask = false;
            });
          },
        );
      },
    );
  }

  Future<void> _showTaskEditor(BuildContext context, Task task) async {
    String editedTaskName = task.name;
    DateTime? editedDeadline = task.deadline;
    double editedPriority = task.priority;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskEditorDialog(
          task: task,
          onTaskUpdated: (name, selectedDeadline, priority) async {
            await _updateTaskInFirestore(
                task.id, name, selectedDeadline, priority);
            _loadTasks(); // Refresh the task list
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Task task) async {
    isDelete = true;

    print(isDelete);
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _completeTask(context, task);
    }
    isDelete = false;
  }

  Future<void> _addTaskToFirestore(String name, String description,
      DateTime? deadline, double priority, String category) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add({
        'name': name,
        'description': description,
        'deadline': deadline,
        'category': category,
        'priority': priority,
      });

      print("Task added successfully.");
    }
  }

  Future<void> _updateTaskInFirestore(
      String taskId, String name, DateTime? deadline, double priority) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Update task data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .update({
        'name': name,
        'deadline': deadline,
        'priority': priority,
      });

      print("Task updated successfully.");
    }
  }

  Future<void> _deleteTask(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Delete task from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .delete();

      _loadTasks(); // Refresh the task list
      print("Task deleted successfully.");
    }

    isDelete = false;
  }

  Future<void> _completeTask(BuildContext context, Task task) async {
    // Display popup for user input
    if (isDelete == true) {
      _deleteTask(task);
      return;
    }

    String? completionNote = await _showCompletionNoteInput(context);

    if (completionNote != null) {
      // Send completion note to OpenAI and get response
      String openAIResponse = await _getOpenAIResponse(completionNote);
      print(openAIResponse);
      // Display the OpenAI response in the menu
      //_displayOpenAIResponse(openAIResponse);
      _showPopupMessage(context, openAIResponse);
    } else {
      // Handle cancellation
      print('Task completion canceled');

      return; // Return without further processing for cancellation
    }

    // Close the menu
    //Navigator.of(context).pop();

    User? user = FirebaseAuth.instance.currentUser;

    // Add user data to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('completedTasks')
        .add({
      'name': task.name,
      'description': task.description,
      'deadline': task.deadline,
      'category': task.category,
      'priority': task.priority,
    });

    print("Task added successfully.");

    _deleteTask(task);
    return;
  }

  void _showPopupMessage(BuildContext context, String response) async {
    Map<String, dynamic> resultMap;
    dynamic value;

    String key = "";

    RegExp regExp = RegExp(r'\{[^{}]*\}');
    Iterable<Match> matches = regExp.allMatches(response);

    for (Match match in matches) {
      String jsonSubstring = match.group(0) ?? '';
      resultMap = jsonDecode(jsonSubstring);
      key = resultMap.keys.first;
      value = resultMap[key];

      key = key.toLowerCase();
      print(key);
      // Check if the key is "work score" or "social score"
      if (key == "work score" || key == "social score") {
        // Update Firebase Cloud data
        String message = "You are awarded $value $key";

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
          duration: const Duration(seconds: 2),
        );

        // Show SnackBar at the top center
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await _updateFirebaseData(key, value);

        _loadTasks();
      }
    }
  }

  Future<void> _updateFirebaseData(String key, dynamic value) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Replace 'users' with the actual name of your Firebase collection
      DocumentReference<Map<String, dynamic>> userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get the current data
      DocumentSnapshot<Map<String, dynamic>> snapshot = await userDocRef.get();
      Map<String, dynamic> userData = snapshot.data() ?? {};

      // Get the current points map
      Map<String, dynamic> points =
          userData['points'] ?? {'work': 0, 'social': 0};

      // Update the points map based on the key
      if (key == "work score") {
        points['work'] = (points['work'] ?? 0) + value;
      } else if (key == "social score") {
        points['social'] = (points['social'] ?? 0) + value;
      }

      // Update the Firestore document with the new points map
      await userDocRef.update({'points': points});
    }
  }

  Future<String?> _showCompletionNoteInput(BuildContext context) async {
    String completionNote = '';
    Completer<String?> completer = Completer<String?>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Task Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('What did you do to complete this task?'),
              TextField(
                onChanged: (value) {
                  completionNote = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                completer.complete(null); // Complete with null when canceled
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (!completionNote.isEmpty) {
                  completer.complete(completionNote);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  Future<String> _getOpenAIResponse(String input) async {
    print("Response");
    try {
      final apiKey = api;
      const apiUrl = "https://api.openai.com/v1/completions";
      final prompt = '''
"You are a strict teacher who grades students based on their tasks and social work activities. You have to give either a work score or a social score. Now, imagine a student comes to you with a task completed with the following description: '$input'. What would you grade him on a scale of 1-5? Give the output in JSON format only. You don't give marks easily, and you even give 0 sometimes.

Please only provide output in JSON format like this. If a task is social, then don't give a work score, and if a task is work-related, then don't give social points:
{ "Work Score": points } or { "Social Score": points }"
''';

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      };

      final data = {
        "model": "gpt-3.5-turbo-instruct",
        "prompt": prompt,
        "max_tokens": 300,
        "temperature": 1,
        "top_p": 1,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        //String decodedResponse = json.decode(response.body).toString();
        Map<String, dynamic> responseMap = json.decode(response.body);
        final values = responseMap["choices"][0]["text"];
        print(values);
        return values;
      } else {
        print("error");
        return '{"Work Score" : 23}';
      }
      //return '{"Work Score" : 3}';
    } catch (e) {
      print(e);
      return '{"Work Score" : 23}';
    }
  }

  Future<String> _getOpenAIResponse2(String input) async {
    print("Response");
    try {
      final apiKey = api;
      const apiUrl = "https://api.openai.com/v1/completions";
      final prompt = '''
Generate at least 5 specific and manageable social interaction recommendations suitable for introverted students when the user mentions their intention, such as 'I am going to attend a session on a hackathon.' Ensure the recommendations are thoughtful, practical, considerate of sensitivity, and easy to incorporate into their routine. Also provide description as if you are talking to the users. Please provide the title of each task followed by a short description in the format: { "title1": "Task desc1", "title2": "Task desc2", ... }. 
User Input : "I am going to attend a session on hackathon"
System output : {
  "title1": "Solo Prep Time",
  "description1": "Allocate quiet time for personal research and prep before the hackathon session.",
  "title2": "Online Forum Engagement",
  "description2": "Participate in online forums or discussion boards related to the hackathon topic for virtual interaction.",
  "title3": "Selective Networking",
  "description3": "Connect with a few key individuals or groups for one-on-one discussions or collaborations.",
  "title4": "Pre-session Webinars",
  "description4": "Attend webinars or virtual meetups associated with the hackathon before the main session.",
  "title5": "Post-Session Reflection",
  "description5": "Reflect on the hackathon experience by jotting down thoughts and lessons learned."
}
Give only one output in json format. Dont give multiple outputs 
User Input : "$input" 
''';

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      };

      final data = {
        "model": "gpt-3.5-turbo-instruct",
        "prompt": prompt,
        "max_tokens": 300,
        "temperature": 1,
        "top_p": 1,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        //String decodedResponse = json.decode(response.body).toString();
        Map<String, dynamic> responseMap = json.decode(response.body);
        final values = responseMap["choices"][0]["text"];
        print(values);
        return values;
      } else {
        print("error");
        return '{"Work Score" : 23}';
      }
      //return '{"Work Score" : 3}';
    } catch (e) {
      print(e);
      return '{"Work Score" : 23}';
    }
  }
}

class TaskListTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  TaskListTile({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // tileColor: _calculateBackgroundColor(task),
      title: Text(task.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deadline: ${task.formattedDeadline}',
          ),
          Text(
            'Priority: ${task.formattedPriority}',
          ),
          if (task.category == "ai-task")
            Text(
              '${task.category}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
      trailing: Container(
        // margin: EdgeInsets.all(0),
        //width: 15,
        child: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
          ),
          elevation: 4,
          onSelected: (String value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              setState() {
                isDelete = true;
              }

              onDelete();
            } else if (value == 'complete') {
              onComplete();
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  title: Icon(
                    Icons.edit,
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  title: Icon(Icons.delete),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'complete',
                child: ListTile(
                  title: Icon(Icons.check),
                ),
              ),
            ];
          },
          offset: const Offset(0, 2),
        ),
      ),
      onTap: () {
        _showTaskDetailsDialog(context, task);
      },
    );
  }
}

void _showTaskDetailsDialog(BuildContext context, Task task) {
  Color backgroundColors = _calculateBackgroundColor(task);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: backgroundColors,
        title: const Text(
          'Task Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Title', task.name),
            _buildDetailRow('Deadline', task.formattedDeadline),
            _buildDetailRow('Priority', task.formattedPriority),
            _buildDetailRow('Description', task.description),
            _buildDetailRow('Category', task.category),
            // Add more details as needed...
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Close',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

Color _calculateBackgroundColor(Task task) {
  if (task.category == 'ai-task') {
    return const Color.fromARGB(255, 219, 204, 149);
  } else {
    // Handle other categories or use a default color
    return Colors.white;
    //return Color.fromARGB(255, 219, 204, 149);
  }
}

class TaskEditorDialog extends StatefulWidget {
  final Task task;
  final Function(String, DateTime?, double) onTaskUpdated;

  const TaskEditorDialog({
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  _TaskEditorDialogState createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  late TextEditingController _taskNameController;
  late DateTime? _deadline;
  late double _priority;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task.name);
    _deadline = widget.task.deadline;
    _priority = widget.task.priority;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskNameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: _deadline ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                setState(() {
                  _deadline = selectedDate;
                });
              }
            },
            child: const Text(
              'Select Deadline',
            ),
          ),
          const SizedBox(height: 16),
          Text('Set Priority: $_priority'),
          Slider(
            value: _priority,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                _priority = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onTaskUpdated(
                _taskNameController.text, _deadline, _priority);
          },
          child: const Text('Update Task'),
        ),
      ],
    );
  }
}

class TaskAdderDialog extends StatefulWidget {
  final Function(
    String,
    String,
    DateTime?,
    double,
  ) onTaskAdded;

  const TaskAdderDialog({required this.onTaskAdded});

  @override
  _TaskAdderDialogState createState() => _TaskAdderDialogState();
}

class _TaskAdderDialogState extends State<TaskAdderDialog> {
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _descriptionController =
      TextEditingController(); // Add this line

  DateTime? _deadline;
  double _priority = 5.0;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskNameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            // Add this TextField for the description
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                setState(() {
                  _deadline = selectedDate;
                });
              }
            },
            child: const Text('Select Deadline'),
          ),
          const SizedBox(height: 16),
          Text('Set Priority: $_priority'),
          Slider(
            value: _priority,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                _priority = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Check if the task name is not blank before adding
            String taskName = _taskNameController.text.trim();
            String description =
                _descriptionController.text.trim(); // Add this line
            if (taskName.isNotEmpty) {
              widget.onTaskAdded(taskName, description, _deadline,
                  _priority); // Update this line
            } else {
              // Show an error message or handle the case where the task name is blank
              // For now, just print an error message
              print('Task name cannot be blank');
            }
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}

class Task {
  final String id;
  final String name;
  final DateTime? deadline;
  double priority;
  final String description;
  final String category;

  Task(
      {required this.id,
      required this.name,
      required this.deadline,
      required this.description,
      required this.category,
      this.priority = 5.0});

  String get formattedDeadline => deadline != null
      ? deadline!.toLocal().toString().split(' ')[0]
      : "No deadline";

  String get formattedPriority => priority.toStringAsFixed(1);
}

class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.9);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.9,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class SocialTask {
  String title;
  String description;
  bool isChecked;

  SocialTask({
    required this.title,
    required this.description,
    this.isChecked = false,
  });
}
