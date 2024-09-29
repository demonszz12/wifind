import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Distance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DistancePage(),
    );
  }
}

class DistancePage extends StatefulWidget {
  @override
  _DistancePageState createState() => _DistancePageState();
}

class _DistancePageState extends State<DistancePage> {
  String message = "Fetching data...";
  Color backgroundColor = Colors.white;
  double? previousDistance;
  bool isDecreasing = false;

  @override
  void initState() {
    super.initState();
    // Start fetching data
    fetchData();
  }

  // Function to fetch the data from ESP32-S2
  Future<void> fetchData() async {
    try {
      // Make HTTP GET request to ESP32-S2
      final response = await http.get(Uri.parse('http://192.168.43.78/sensor_data'));

      if (response.statusCode == 200) {
        // Parse the JSON data
        final data = jsonDecode(response.body);
        double currentDistance = double.parse(data['distance'].toString());

        // Check if the distance is constantly decreasing or increasing
        if (previousDistance != null) {
          if (currentDistance < previousDistance!) {
            // If decreasing, set background to green
            setState(() {
              backgroundColor = Colors.green;
              message = "You're in the right way!";
              isDecreasing = true;
            });
          } else if (currentDistance > previousDistance!) {
            // If increasing, set background to red
            setState(() {
              backgroundColor = Colors.red;
              message = "Oops! Something went wrong.";
              isDecreasing = false;
            });
          }
        }

        // Update previous distance
        previousDistance = currentDistance;
      } else {
        // Handle server error
        setState(() {
          message = "Failed to fetch data";
        });
      }
    } catch (e) {
      // Handle request error
      setState(() {
        message = "Error: Could not connect to ESP32";
      });
    }

    // Fetch data every 2 seconds
    await Future.delayed(Duration(seconds: 2));
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 24, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
