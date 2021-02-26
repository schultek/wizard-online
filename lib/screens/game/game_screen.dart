import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/game.dart';

class GameScreen extends StatefulWidget {
  final Game game;
  const GameScreen(this.game);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Game get game => widget.game;

  @override
  void initState() {
    super.initState();

    game.state.addListener(() => setState(() {}));
    game.players.addListener(() => setState(() {}));
    game.currentRound.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildTable(
        child: game.state.value == "waiting" ? buildWaitingArea() : buildPlayArea(),
      ),
    );
  }

  Widget buildTable({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("lib/assets/tabletop.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(child: child),
    );
  }

  Widget buildWaitingArea() {
    return Row(
      children: [
        Flexible(
          child: Center(
            child: GestureDetector(
              onTap: () {
                game.startGame();
              },
              child: Container(
                width: 400,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  boxShadow: const [BoxShadow(blurRadius: 4)],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Spiel starten",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Spieler", style: Theme.of(context).textTheme.headline2),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: game.players.value?.length ?? 0,
                itemBuilder: (context, index) {
                  return Text(
                    game.players.value![index].nickname,
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildPlayArea() {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Text("Aktuelle Runde ${game.currentRound.value}"),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Text("Trumpf ${game.currentTopps.value}"),
          ),
          ...playerAvatars(constraints),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: Builder(
                builder: (context) {
                  var currentPlayer = game.players.value!.firstWhere((p) => p.id == game.playerId);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: currentPlayer.cards.map((card) {
                      return Container(
                        color: Colors.blue,
                        padding: const EdgeInsets.all(20),
                        child: Text(card),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> playerAvatars(BoxConstraints constraints) {
    var otherPlayers = game.players.value!.where((p) => p.id != game.playerId).toList();

    var playerCount = otherPlayers.length;

    var startAngle = (playerCount - 1) * -20;

    var centerX = constraints.maxWidth / 2, centerY = constraints.maxHeight / 2;
    var radius = min(constraints.maxWidth, constraints.maxHeight) / 2 - 30;

    // 1 [  0    ]
    // 2 [  -20, 20  ]
    // 3 [  -40, 0, 40  ]
    // 4 [  -60, -20, 20, 60  ]
    // 5 [  -80, -40, 0, 40, 80  ]

    var avatars = <Widget>[];

    for (var i = 0; i < playerCount; i++) {
      var angle = (startAngle + (i * 40)) / 180 * pi;

      var x = centerX + sin(angle) * radius;
      var y = centerY - cos(angle) * radius;

      print("$x $y");

      avatars.add(
        Positioned(
          top: y,
          left: x - 50,
          width: 100,
          height: 100,
          child: Center(
            child: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(otherPlayers[i].nickname),
            ),
          ),
        ),
      );
    }

    return avatars;
  }
}
