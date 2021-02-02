import 'package:flutter/material.dart';

import 'game_route_path.dart';

class GameRouteInformationParser extends RouteInformationParser<GameRoutePath> {
  @override
  Future<GameRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    var uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'game') {
      return GameRoutePath.game(uri.pathSegments[1]);
    } else if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'join') {
      return GameRoutePath.join(uri.pathSegments[1]);
    } else {
      return GameRoutePath.home();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(GameRoutePath configuration) {
    return RouteInformation(location: configuration.path);
  }
}
