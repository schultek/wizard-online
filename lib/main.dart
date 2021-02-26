// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:wizard_online/router/game_route_path.dart';

import 'router/game_route_information_parser.dart';
import 'router/game_router_delegate.dart';

void main() {
  setPathUrlStrategy();
  runApp(WizardApp());
}

class WizardApp extends StatefulWidget {
  @override
  _WizardAppState createState() => _WizardAppState();

  static _WizardAppState of(BuildContext context) {
    return context.findAncestorStateOfType()!;
  }
}

class _WizardAppState extends State<WizardApp> {
  late final GameRouterDelegate _routerDelegate;
  late final GameRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();

    _routerDelegate = GameRouterDelegate();
    _routeInformationParser = GameRouteInformationParser();

    if (apps.isEmpty) {
      initializeApp(
        apiKey: "AIzaSyCUjrVTdax42q71UngHODzb8EnrNd68aeg",
        authDomain: "wizard-game-online.firebaseapp.com",
        databaseURL: "https://wizard-game-online-default-rtdb.europe-west1.firebasedatabase.app",
        storageBucket: "wizard-game-online.appspot.com",
        projectId: "wizard-game-online",
      );

      Database db = database();
      DatabaseReference ref = db.ref("root");

      ref.onValue.listen((e) {
        DataSnapshot datasnapshot = e.snapshot;
        print(datasnapshot.val());
      });
    }
  }

  void open(GameRoutePath path) {
    _routerDelegate.setNewRoutePath(path);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wizard Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.cinzelTextTheme(),
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

/*

Home Screen
  -> Create Game
  -> Join Game

Create Game Screen
  actions:
    - create game

  -> Waiting Room Screen

Join Game Screen
  actions:
    - enter code

  -> Waiting Room Screen

Waiting Room Screen
  actions
    - copy game link
    - start game (only game creator)

  -> InGame Screen

InGame Screen

 */

/*

Routing:

/ -> Home
/:gameId -> Waiting / InGame

 */

/*

Database:


games:
  - $gameId
    - creatorUserId
    - playerUserIds []
    - state (waiting, running, finished)
    - currentRound
    - currentPlayer
    - players
      - $playerId
        - roundsWon
        - initialGuess
        - cards []
        - plannedCard
        - playedCard





 */
