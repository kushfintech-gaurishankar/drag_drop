import 'package:drag_drop/seat/presentation/pages/seat.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builder) => const Seat(),
              ),
            ),
            child: const Text("Seats"),
          ),
        ],
      ),
    );
  }
}
