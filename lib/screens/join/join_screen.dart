import 'package:flutter/material.dart';

import '../../main.dart';
import '../../router/game_route_path.dart';
import '../../services/game_service.dart';

class JoinScreen extends StatefulWidget {
  final String gameId;
  const JoinScreen(this.gameId);

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String? _nickname;

  @override
  void initState() {
    super.initState();

    GameService.getJoinAllowed(widget.gameId).then((joinAllowed) {
      if (joinAllowed == true) {
        WizardApp.of(context).open(GameRoutePath.game(widget.gameId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Nickname"),
            onChanged: (text) {
              _nickname = text;
            },
          ),
          TextButton(
            onPressed: () async {
              if (_nickname == null) return;

              bool allowJoin = await GameService.joinGame(widget.gameId, _nickname!);

              if (allowJoin) {
                WizardApp.of(context).open(GameRoutePath.game(widget.gameId));
              } else {
                print("NOT ALLOWED");
              }
            },
            child: const Text("Beitreten"),
          )
        ],
      ),
    );
  }
}
