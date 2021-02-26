import 'dart:ui';

import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/game.dart';
import '../../router/game_route_path.dart';
import '../../services/game_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/background.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.blue, BlendMode.color),
          ),
        ),
        child: Center(
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Wizard",
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.w900,
                    color: Colors.pinkAccent,
                    shadows: [
                      Shadow(
                        color: Colors.purpleAccent,
                        blurRadius: 5,
                        offset: Offset(3, 3),
                      ),
                      Shadow(
                        color: Colors.white,
                        blurRadius: 5,
                        offset: Offset(-3, -3),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 100,
                ),
                ElevatedButton(
                  onPressed: () async {
                    Game game = await GameService.createGame();
                    WizardApp.of(context).open(GameRoutePath.join(game));
                  },
                  style: ButtonStyle(
                    shadowColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Colors.pinkAccent),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                    child: Text(
                      "Neues Spiel erstellen",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "ODER",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.pinkAccent, boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent,
                      blurRadius: 5,
                      offset: Offset(3, 3),
                    ),
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 5,
                      offset: Offset(-3, -3),
                    )
                  ]),
                  child: TextField(
                    onSubmitted: (String id) async {
                      var game = await GameService.getGame(id);
                      WizardApp.of(context).open(GameRoutePath.join(game));
                    },
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: "Code eingeben",
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.purpleAccent,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.purpleAccent),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
