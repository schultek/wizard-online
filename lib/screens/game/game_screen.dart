import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  final String gameId;
  const GameScreen(this.gameId);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("in Game"),
    );
  }
}
