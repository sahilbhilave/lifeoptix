import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prototype/screens/home/home.dart';
import 'package:prototype/screens/inputdata/infopage.dart';
import 'package:prototype/screens/inputdata/inputdata.dart';

class FitnessGoal extends StatefulWidget {
  bool isAdmin;
  List<String> conditions;

  FitnessGoal({required this.isAdmin, required this.conditions});

  @override
  _FitnessGoalState createState() =>
      _FitnessGoalState(isAdmin: isAdmin, conditions: conditions);
}

class _FitnessGoalState extends State<FitnessGoal> {
  bool isAdmin;
  List<String> conditions;

  _FitnessGoalState({required this.isAdmin, required this.conditions});

  late String userName;
  late int age;
  late String selectedFitnessGoal;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    age = 0;
    selectedFitnessGoal = "Weight Loss";
  }

  // Validate name and age
  void validateInputs() {
    setState(() {
      // Check if name is not empty and age is between 0 and 100
      isButtonEnabled = userName.isNotEmpty && age >= 8 && age <= 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 22, 26, 48),
      ),
      backgroundColor: Color.fromARGB(255, 22, 26, 48),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Input Details",
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 45),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Name",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 150, // Set the width as needed
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          userName = value;
                          validateInputs(); // Validate when the name changes
                        });
                      },
                      decoration: InputDecoration(
                        filled: false,
                        contentPadding: EdgeInsets.only(left: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintStyle: TextStyle(fontSize: 14.0),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    " Age",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 150, // Set the width as needed
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          age = int.tryParse(value) ?? 0;
                          validateInputs(); // Validate when the age changes
                        });
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // Allow only digits
                      decoration: InputDecoration(
                        filled: false,
                        contentPadding: EdgeInsets.only(left: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintStyle: TextStyle(fontSize: 14.0),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              const Text(
                "Select a Fitness Goal",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ToggleButtons(
                isSelected: [
                  selectedFitnessGoal == "Weight Loss",
                  selectedFitnessGoal == "Weight Gain",
                  selectedFitnessGoal == "Maintain Health",
                ],
                onPressed: (int index) {
                  setState(() {
                    selectedFitnessGoal = [
                      "Weight Loss",
                      "Weight Gain",
                      "Maintain Health"
                    ][index];
                  });
                },
                selectedColor: Colors.lightGreen,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Text("Weight Loss",
                        style: TextStyle(color: Colors.white)),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Text("Weight Gain",
                        style: TextStyle(color: Colors.white)),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Text("Maintain Health",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: isButtonEnabled
                    ? () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => InfoPage(
                                  isAdmin: isAdmin,
                                  conditions: conditions,
                                  name: userName,
                                  age: age,
                                  fitnessGoal: selectedFitnessGoal,
                                )));
                        print("Let's go");
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
            ],
          ),
        ),
      ),
    );
  }
}
