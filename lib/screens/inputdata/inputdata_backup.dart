import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prototype/key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:prototype/screens/inputdata/fitnessgoal.dart';

final api = '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';

bool isAdmin = false;

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void toggleAdmin(bool newValue) {
    setState(() {
      isAdmin = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeScreen(isAdmin: isAdmin, toggleAdmin: toggleAdmin),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final bool isAdmin;
  final Function(bool) toggleAdmin;

  WelcomeScreen({required this.isAdmin, required this.toggleAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 26, 48),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 30, color: Colors.white),
                children: [
                  TextSpan(text: "Welcome to "),
                  TextSpan(
                    text: "LifeOptiX",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const Text(
              'Let\'s start your journey',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 20),
            ToggleButtons(
              isSelected: [!isAdmin, isAdmin],
              onPressed: (index) {
                toggleAdmin(index == 1); // Pass the new value to the callback
              },
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'User',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Admin',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NextPage(isAdmin: isAdmin),
                  ),
                );
              },
              child: Icon(Icons.arrow_forward),
              style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white),
            ),
            SizedBox(height: 20),
            Text.rich(
              TextSpan(
                text: 'You are creating ',
                style: TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: isAdmin ? 'Admin ' : 'User ',
                    style: TextStyle(color: Colors.white),
                  ),
                  const TextSpan(
                    text: 'account \n',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: isAdmin
                        ? 'For maintaining a group'
                        : 'Users only work on themselves',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NextPage extends StatefulWidget {
  final bool isAdmin;

  NextPage({required this.isAdmin});

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<String> healthConditions = [];
  List<String> deletedConditions = [];
  List<String> detectedConditions = ["", "", "", "", ""];
  TextEditingController conditionController = TextEditingController();
  bool isLoading = false;
  bool isButtonEnabled = true;

  Future<String> getGPT3Response(List<String> conditions) async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiKey = api; // Replace with your OpenAI API key
      const apiUrl = "https://api.openai.com/v1/completions";
      final prompt = '''
You are a health professional working for a health app. Users can input their health conditions in their own way. Your task is to detect and provide the names of their conditions. If you do not find a user input to be valid, it should be marked as "false". Respond in a JSON format line, for example: { "condition1": bool, "condition2": bool, "condition3": bool, etc. }.
User input: ${conditions.join(', ')}
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
        updateHealthConditions(response.body);
        // Uncomment the code below if you want to display the response in an AlertDialog
        if (deletedConditions.length > 0) {
          final decodedResponse = json.decode(response.body);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Invalid Condition'),
                content: Text(deletedConditions.toString() +
                    " are not valid health conditions"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error in getting response, please try again!!'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to get response from GPT-3.');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    print("Admin: ${widget.isAdmin}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 22, 26, 48),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color.fromARGB(255, 22, 26, 48),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Any Health Conditions?',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 60),
                    child: TextField(
                      controller: conditionController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add health conditions...',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          addHealthCondition(value.trim());
                          isButtonEnabled = false;
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 70),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      isButtonEnabled = false;
                      String newCondition = conditionController.text.trim();
                      addHealthCondition(newCondition);
                    },
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(left: 50, right: 45),
                itemCount: healthConditions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            healthConditions[index],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        if (detectedConditions[index] != "")
                          Text(
                            "Detected: " + detectedConditions[index],
                            style: TextStyle(color: Colors.green),
                          ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              healthConditions.removeAt(index);
                              detectedConditions.removeAt(index);
                            });
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding:
                  EdgeInsets.only(bottom: 30), // Adjust the padding as needed
              child: ElevatedButton(
                onPressed: () async {
                  if (healthConditions.isNotEmpty) {
                    try {
                      await getGPT3Response(healthConditions);
                    } catch (e) {
                      print('Error: $e');
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please add health conditions before testing.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  isButtonEnabled = true;
                },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        'Test Health Conditions',
                        style: TextStyle(color: Colors.black),
                      ),
              ),
            ),
            GestureDetector(
              onTap: isButtonEnabled
                  ? () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FitnessGoal(
                              isAdmin: isAdmin, conditions: detectedConditions),
                        ),
                      );
                      print("Lets go");
                    }
                  : null,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isButtonEnabled ? Colors.green : Colors.grey,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void updateHealthConditions(String gpt3Response) {
    deletedConditions.clear();
    try {
      Map<String, dynamic> responseMap = json.decode(gpt3Response);
      List<String> updatedConditions = [];
      List<int> deleteValues = [];
      List<String> currdeletedConditions = [];
      int i = 0;
      List<String> currdetectedValues = [];

      final values = responseMap["choices"][0]["text"];
      Map<String, dynamic> resultMap = json.decode(values);
      for (var entry in resultMap.entries) {
        print('${entry.key}: ${entry.value}');
        String value = entry.value.toString();
        if ((value.toLowerCase() == "false")) {
          deleteValues.add(i);
        } else {
          if (!currdetectedValues.contains(entry.key)) {
            currdetectedValues.add(entry.key);
          }
        }
        i++;
      }
      for (int i = 0; i < healthConditions.length; i++) {
        if (deleteValues.contains(i)) {
          currdeletedConditions.add(healthConditions[i]);
        } else {
          updatedConditions.add(healthConditions[i]);
        }
      }

      setState(() {
        for (int i = 0; i < currdetectedValues.length; i++)
          detectedConditions[i] = currdetectedValues[i];
        deletedConditions = currdeletedConditions;
        healthConditions = updatedConditions;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Condition'),
            content: Text(" Error while getting response, please try again!!"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      print('Error parsing GPT-3 response: $e');
    }
  }

  void addHealthCondition(String value) {
    if (healthConditions.length < 5) {
      setState(() {
        healthConditions.add(value);
        conditionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot add more than 5 conditions.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
