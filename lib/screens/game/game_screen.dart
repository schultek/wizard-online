import 'package:flutter/material.dart';
import 'package:wizard_online/services/game_service.dart';

class GameScreen extends StatefulWidget {
  final String gameId;
  const GameScreen(this.gameId);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class Player {
  String id;
  String nickname;

  Player(this.id, this.nickname);
}

class _GameScreenState extends State<GameScreen> {
  String get gameId => widget.gameId;

  String gameState = "waiting";
  List<Player> players = [];

  @override
  void initState() {
    super.initState();

    GameService.db.ref("games/$gameId/state").onValue.listen((event) {
      setState(() {
        gameState = event.snapshot.val() as String;
      });
    });

    GameService.db.ref("games/$gameId/players").onValue.listen((event) {
      setState(() {
        var playerMap = event.snapshot.val() as Map<String, dynamic>;

        players = playerMap.entries.map((entry) {
          return Player(entry.key, entry.value["nickname"] as String);
        }).toList();

        print(players);
      });
    });
  }

  Future<void> startGame() async {
    await GameService.db.ref("games/$gameId/state").set("playing");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildTable(
        child: gameState == "waiting" ? buildWaitingArea() : buildPlayArea(),
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
                startGame();
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
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return Text(
                    players[index].nickname,
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
    return Text("Play");
  }
}
