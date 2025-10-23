enum NewsEndpoint {
  latest, world, business, technology, entertainment, sport, science, health
}

extension NewsEndpointX on NewsEndpoint {
  String get path => switch (this) {
    NewsEndpoint.latest => 'latest',
    NewsEndpoint.world => 'world',
    NewsEndpoint.business => 'business',
    NewsEndpoint.technology => 'technology',
    NewsEndpoint.entertainment => 'entertainment',
    NewsEndpoint.sport => 'sport',
    NewsEndpoint.science => 'science',
    NewsEndpoint.health => 'health',
  };

  String get title => path.toUpperCase();
}
