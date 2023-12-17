import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heart_bpm/chart.dart';
import 'package:heart_bpm/heart_bpm.dart';

class Heart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart BPM Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SensorValue> data = [];
  List<SensorValue> bpmValues = [];
  double currentBPM = 0.0;
  double averageBPM = 0.0;

  bool isBPMEnabled = false;
  int measurementDuration = 30;
  int remainingTime = 30;
  late Timer _timer;
  DateTime measurementStartTime = DateTime.now(); // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Heart BPM Demo'),
      ),
      body: Column(
        children: [
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
                    bpmValues.add(SensorValue(
                        value: value.toDouble(), time: DateTime.now()));
                    currentBPM = value.toDouble();
                  }),
                )
              : const SizedBox(),
          isBPMEnabled && data.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(border: Border.all()),
                  height: 180,
                  child: BPMChart(data),
                )
              : const SizedBox(),
          isBPMEnabled && bpmValues.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(border: Border.all()),
                  constraints: const BoxConstraints.expand(height: 180),
                  child: BPMChart(bpmValues),
                )
              : const SizedBox(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Current BPM: ${currentBPM.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.favorite_rounded),
                  label:
                      Text(isBPMEnabled ? "Stop Measurement" : "Measure BPM"),
                  onPressed: _toggleBPMMeasurement,
                ),
                const SizedBox(height: 10),
                if (isBPMEnabled)
                  Text(
                    'Time remaining: $remainingTime s',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                if (!isBPMEnabled && averageBPM > 0)
                  Text(
                    'Average BPM: ${averageBPM.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
      } else {
        isBPMEnabled = true;
        measurementStartTime = DateTime.now();
        _startTimer();
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
        }
      });
    });
  }

  void _calculateAverageBPM() {
    if (bpmValues.isNotEmpty) {
      num sum = bpmValues.map((value) => value.value).reduce((a, b) => a + b);
      averageBPM = sum / bpmValues.length;
    }
  }
}
