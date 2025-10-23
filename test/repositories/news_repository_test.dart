import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:news_app/app/data/enums/news_endpoint.dart';
import 'package:news_app/app/data/repositories/news_repository.dart';
import 'package:news_app/app/data/services/news_api.dart';

class _MockApi extends Mock implements NewsApi {}

void main() {
  late _MockApi api;
  late NewsRepository repo;

  setUp(() {
    api = _MockApi();
    repo = NewsRepository(api);
  });

  group('NewsRepository.getTodayArticles', () {
    test('keeps only today items when available', () async {
      final now = DateTime.now();
      final todayMs = now.millisecondsSinceEpoch.toString();
      final oldMs = DateTime(2020, 1, 1).millisecondsSinceEpoch.toString();

      final json = {
        'status': 'ok',
        'items': [
          {
            'timestamp': todayMs,
            'title': 'Today 1',
            'snippet': 's',
            'newsUrl': '',
            'publisher': 'X',
            'images': null,
            'subnews': null,
            'hasSubnews': null,
          },
          {
            'timestamp': oldMs,
            'title': 'Old',
            'snippet': 's',
            'newsUrl': '',
            'publisher': 'X',
            'images': null,
            'subnews': null,
            'hasSubnews': null,
          },
        ],
      };

      when(() => api.fetch(any())).thenAnswer((_) async => json);

      final result = await repo.getTodayArticles(NewsEndpoint.latest);

      expect(result.status, 'ok');
      expect(result.items, isNotNull);
      expect(result.items!.length, 1);
      expect(result.items!.first.title, 'Today 1');

      verify(() => api.fetch(NewsEndpoint.latest.path)).called(1);
    });

    test('falls back to all items when there is no today item', () async {
      final oldMs1 = DateTime(2020, 1, 1).millisecondsSinceEpoch.toString();
      final oldMs2 = DateTime(2020, 1, 2).millisecondsSinceEpoch.toString();

      final json = {
        'status': 'ok',
        'items': [
          {
            'timestamp': oldMs1,
            'title': 'Old 1',
            'snippet': 's',
            'newsUrl': '',
            'publisher': 'X',
            'images': null,
            'subnews': null,
            'hasSubnews': null,
          },
          {
            'timestamp': oldMs2,
            'title': 'Old 2',
            'snippet': 's',
            'newsUrl': '',
            'publisher': 'X',
            'images': null,
            'subnews': null,
            'hasSubnews': null,
          },
        ],
      };

      when(() => api.fetch(any())).thenAnswer((_) async => json);

      final result = await repo.getTodayArticles(NewsEndpoint.latest);

      expect(result.items, isNotNull);
      expect(result.items!.length, 2);
      expect(result.items!.first.title, 'Old 1');
      expect(result.items![1].title, 'Old 2');
    });

    test('handles null or empty items safely', () async {
      when(() => api.fetch(any())).thenAnswer((_) async => {
        'status': 'ok',
        'items': null,
      });

      final r1 = await repo.getTodayArticles(NewsEndpoint.latest);
      expect(r1.items, isNull);

      when(() => api.fetch(any())).thenAnswer((_) async => {
        'status': 'ok',
        'items': [],
      });

      final r2 = await repo.getTodayArticles(NewsEndpoint.latest);
      expect(r2.items, isEmpty);
    });
  });
}
