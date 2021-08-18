import 'package:flutter/material.dart';
import 'chronometer/chronometer.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      title: 'Timer Bloc Example',
      home: const TimerPage(),
    );
  }
}
