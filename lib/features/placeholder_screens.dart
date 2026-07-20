import 'package:flutter/material.dart';

// Dummy screens representing feature modules before they are built in full.
// This allows the navigation system to be fully functional immediately.

class DummyTheoryScreen extends StatelessWidget {
  const DummyTheoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Theory Test Dashboard\n(Feature Coming in Part 3)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DummyHighwayCodeScreen extends StatelessWidget {
  const DummyHighwayCodeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Highway Code Manual\n(Feature Coming in Part 5)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DummyRoadSignsScreen extends StatelessWidget {
  const DummyRoadSignsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Road Signs Flashcards & Game\n(Feature Coming in Part 6)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
