class GameRoutePath {
  final String path;

  GameRoutePath.home() : path = "";
  GameRoutePath.game(String gameId) : path = "game/$gameId";
  GameRoutePath.join(String gameId) : path = "join/$gameId";

  bool get isHome => path == "";
  bool get isGame => path.startsWith("game/");
  bool get isJoin => path.startsWith("join/");

  String? get gameId => isGame || isJoin ? path.split("/")[1] : null;
}
