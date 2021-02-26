// ignore: import_of_legacy_library_into_null_safe
import 'dart:math';

import 'package:firebase/firebase.dart';

import 'value_subscription.dart';

class Player {
  String id;
  String nickname;
  List<String> cards;

  Player(this.id, this.nickname, this.cards);
}

class Game {
  String id;
  String playerId;

  DatabaseReference gameRef;

  Game._(this.id, this.playerId) : gameRef = database().ref("games/$id");

  Map<String, ValueSubscription> subscriptions = {};

  ValueSubscription<T> subscribedValue<T, U>(String path, [T Function(U data)? mapper]) {
    if (subscriptions[path] == null) {
      subscriptions[path] = ValueSubscription<T>(gameRef.child(path), (data) => mapper?.call(data as U) ?? data as T);
    }
    return subscriptions[path] as ValueSubscription<T>;
  }

  ValueSubscription<String> get state => subscribedValue("state");
  ValueSubscription<List<Player>> get players => subscribedValue(
        "players",
        (Map<String, dynamic> playerMap) {
          return playerMap.entries.map((entry) {
            List<String> cards = (entry.value["cards"] as List?)?.cast<String>() ?? [];
            return Player(entry.key, entry.value["nickname"] as String, cards);
          }).toList();
        },
      );

  ValueSubscription<int> get currentRound => subscribedValue("currentRound");
  ValueSubscription<String> get currentTopps => subscribedValue("currentTopps");
  ValueSubscription<String> get currentPlayer => subscribedValue("currentPlayer");

  static Future<Game> setup(String id, String playerId) async {
    var game = Game._(id, playerId);
    await game._setup();
    return game;
  }

  Future<void> _setup() async {
    var creatorUserId = (await gameRef.child("creatorUserId").once("value")).snapshot.val();

    if (creatorUserId == playerId) {
      gameRef.child("join").onChildAdded.listen((event) async {
        var players = (await gameRef.child("players").once("value")).snapshot.val() as Map? ?? {};
        var state = (await gameRef.child("state").once("value")).snapshot.val() as String;

        if (state == "waiting" && players.length < 6) {
          var userId = event.snapshot.key;
          var nickname = event.snapshot.val()["nickname"];

          await gameRef.child("players/$userId").set({
            "nickname": nickname,
            "points": 0,
            "roundsWon": 0,
          });

          await event.snapshot.ref.child("allowed").set(true);
        } else {
          await event.snapshot.ref.child("allowed").set(false);
        }
      });
    }
  }

  Future<bool?> canJoin() async {
    var joinRef = await gameRef.child("join/$playerId").once("value");

    if (joinRef.snapshot.exists()) {
      return joinRef.snapshot.val()["allowed"] as bool? ?? false;
    } else {
      return null;
    }
  }

  Future<bool> join(String nickname) async {
    var joinAllowed = await canJoin();
    if (joinAllowed != null) {
      return joinAllowed;
    }

    await gameRef.child("join/$playerId").set({
      "nickname": nickname,
      "allowed": null,
    });

    var allowedEntry = await gameRef.child("join/$playerId/allowed").onValue.firstWhere((event) {
      return event.snapshot.exists();
    });

    return allowedEntry.snapshot.val() as bool;
  }

  Future<void> startGame() async {
    await startNextRound(5);

    await state.set("playing");
  }

  Future<void> startNextRound(int round) async {
    var cards = [
      ...List.generate(13, (i) => "r${i + 1}"),
      ...List.generate(13, (i) => "y${i + 1}"),
      ...List.generate(13, (i) => "g${i + 1}"),
      ...List.generate(13, (i) => "b${i + 1}"),
      ...List.filled(4, "Z"),
      ...List.filled(4, "N"),
    ]..shuffle();

    for (var player in players.value!) {
      var playerCards = [];
      for (var i = 0; i <= round; i++) {
        var card = cards.removeAt(0);
        playerCards.add(card);
      }

      await gameRef.child("players/${player.id}/cards").set(playerCards);
    }

    var topps = ["r", "y", "g", "b"][Random().nextInt(4)];
    await currentTopps.set(topps);

    var player = players.value![Random().nextInt(players.value!.length)].id;
    await currentPlayer.set(player);

    await currentRound.set(round);
  }

  Future<void> finishRound() async {
    // punkte setzen

    startNextRound(currentRound.value! + 1);
  }
}
