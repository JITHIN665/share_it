import 'package:flutter/material.dart';
import 'media_picker_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Start', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MediaPickerScreen())),
            ),
          )
        ],
      ),
    );
  }
}
