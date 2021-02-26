import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/game.dart';
import '../../router/game_route_path.dart';

class JoinScreen extends StatefulWidget {
  final Game game;
  const JoinScreen(this.game);

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String? _nickname;

  @override
  void initState() {
    super.initState();

    widget.game.canJoin().then((canJoin) {
      if (canJoin == true) {
        WizardApp.of(context).open(GameRoutePath.game(widget.game));
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

              bool allowJoin = await widget.game.join(_nickname!);
              if (allowJoin) {
                WizardApp.of(context).open(GameRoutePath.game(widget.game));
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
