import 'package:flutter/material.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/backgrounds/back1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 24.0, top: 50.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Tasks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Verdana',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
