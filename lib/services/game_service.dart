import 'package:firebase/firebase.dart';
import 'package:shortid/shortid.dart';

class GameService {
  static Database get db => database();

  static Future<String> createUserId() async {
    if (auth().currentUser != null) {
      return auth().currentUser.uid;
    } else {
      UserCredential userId = await auth().signInAnonymously();
      return userId.user.uid;
    }
  }

  static Future<bool?> getJoinAllowed(String gameId) async {
    String userId = await createUserId();
    var joinRef = await db.ref("games/$gameId/join/$userId").once("value");

    if (joinRef.snapshot.exists()) {
      return joinRef.snapshot.val()["allowed"] as bool? ?? false;
    } else {
      return null;
    }
  }

  static Future<bool> joinGame(String gameId, String nickname) async {
    var joinAllowed = await getJoinAllowed(gameId);
    if (joinAllowed != null) {
      return joinAllowed;
    }

    String userId = await createUserId();
    await db.ref("games/$gameId/join/$userId").set({
      "nickname": nickname,
      "allowed": null,
    });

    var allowedEntry = await db.ref("games/$gameId/join/$userId/allowed").onValue.firstWhere((event) {
      return event.snapshot.exists();
    });

    return allowedEntry.snapshot.val() as bool;
  }

  static Future<String> createGame() async {
    String gameId = shortid.generate();

    removeOldGames();

    var gameRef = db.ref("games/$gameId");

    await gameRef.set({
      "creatorUserId": await createUserId(),
      "state": "waiting",
      "currentRound": null,
      "currentPlayer": null,
      "players": {},
      "lastHeartbeat": DateTime.now().toUtc().toIso8601String(),
    });

    gameRef.child("join").onChildAdded.listen((event) async {
      var players = (await gameRef.child("players").once("value")).snapshot.val() as Map? ?? {};

      if (players.length < 6) {
        var userId = event.snapshot.key;
        var nickname = event.snapshot.val()["nickname"];

        await gameRef.child("players/$userId").set({
          "nickname": nickname,
          "roundsWon": 0,
        });

        await event.snapshot.ref.child("allowed").set(true);
      } else {
        await event.snapshot.ref.child("allowed").set(false);
      }
    });

    return gameId;
  }

  static Future<void> removeOldGames() async {
    var query = await db
        .ref("games")
        .orderByChild("lastHeartbeat")
        .endAt(DateTime.now().subtract(Duration(hours: 2)).toUtc().toIso8601String())
        .once("value");
    query.snapshot.forEach((child) => child.ref.remove());
  }
}
