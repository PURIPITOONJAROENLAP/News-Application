import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';

import 'package:news_app/app/feature/home/home_controller.dart';
import 'package:news_app/app/data/repositories/news_repository.dart';
import 'package:news_app/app/data/local/shared_prefs_storage.dart';
import 'package:news_app/app/data/models/news_response.dart';
import 'package:news_app/app/data/enums/news_endpoint.dart';

// -------------------- Mocks --------------------
class _MockRepo extends Mock implements NewsRepository {}
class _MockStorage extends Mock implements LocalStorage {}

void main() {
  late _MockRepo repo;
  late _MockStorage storage;

  Item makeItem({String url = 'https://example.com/a', String title = 'Title A'}) {
    return Item(
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      snippet: 'snippet',
      images: Images(thumbnail: 't', thumbnailProxied: 'tp'),
      subnews: const [],
      hasSubnews: false,
      newsUrl: url,
      publisher: 'pub',
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    repo = _MockRepo();
    storage = _MockStorage();
    // ใส่ LocalStorage ลง DI ตามที่ HomeController เรียกใช้ด้วย Get.find<LocalStorage>()
    Get.put<LocalStorage>(storage, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController.getDataFromCache', () {
    test("When cache has data: should load into articles and set index = 0", () {
      // arrange
      final cached = [makeItem(title: 'A'), makeItem(title: 'B')];
      when(() => storage.getCachedArticles(NewsEndpoint.latest))
          .thenReturn(cached);

      final controller = HomeController(repo);

      // act
      controller.getDataFromCache();

      // assert
      expect(controller.isLoading.value, false);
      expect(controller.error.value, isNull);
      expect(controller.articles.length, 2);
      expect(controller.index.value, 0);
      expect(controller.current?.title, 'A');

      verify(() => storage.getCachedArticles(NewsEndpoint.latest)).called(1);
    });

    test("When cache is empty: should set error = 'No data in memory' and articles should be empty", () {
      when(() => storage.getCachedArticles(NewsEndpoint.latest))
          .thenReturn(<Item>[]);

      final controller = HomeController(repo);

      controller.getDataFromCache();

      expect(controller.isLoading.value, false);
      expect(controller.error.value, 'No data in memory');
      expect(controller.articles, isEmpty);
      verify(() => storage.getCachedArticles(NewsEndpoint.latest)).called(1);
    });

    test("Specify a new endpoint: should update the endpoint and read the cache for that endpoint", () {
      when(() => storage.getCachedArticles(NewsEndpoint.world))
          .thenReturn([makeItem(title: 'World')]);

      final controller = HomeController(repo);

      controller.getDataFromCache(NewsEndpoint.world);

      expect(controller.endpoint.value, NewsEndpoint.world);
      expect(controller.articles.length, 1);
      expect(controller.current?.title, 'World');
      verify(() => storage.getCachedArticles(NewsEndpoint.world)).called(1);
    });
  });

  group('HomeController.refreshFromApi', () {
    test("When API success: should save cache and set articles from the result with error = null", () async {
      final items = [makeItem(title: 'X'), makeItem(title: 'Y')];
      final resp = NewsResponse(status: 'success', items: items);

      when(() => repo.getTodayArticles(NewsEndpoint.latest))
          .thenAnswer((_) async => resp);
      when(() => storage.cacheArticles(NewsEndpoint.latest, items))
          .thenAnswer((_) async {});

      final controller = HomeController(repo);

      await controller.refreshFromApi();

      expect(controller.isLoading.value, false);
      expect(controller.error.value, isNull);
      expect(controller.articles.length, 2);
      expect(controller.index.value, 0);

      verify(() => repo.getTodayArticles(NewsEndpoint.latest)).called(1);
      verify(() => storage.cacheArticles(NewsEndpoint.latest, items)).called(1);
    });

    test("When API returns status != success: should set error = status and still cache the result", () async {
      final items = [makeItem(title: 'Z')];
      final resp = NewsResponse(status: 'Rate limit exceeded', items: items);

      when(() => repo.getTodayArticles(NewsEndpoint.latest))
          .thenAnswer((_) async => resp);
      when(() => storage.cacheArticles(NewsEndpoint.latest, items))
          .thenAnswer((_) async {});

      final controller = HomeController(repo);

      await controller.refreshFromApi();

      expect(controller.error.value, 'Rate limit exceeded');
      expect(controller.articles.length, 1); // ยังใส่ข้อมูลกลับมา
      verify(() => storage.cacheArticles(NewsEndpoint.latest, items)).called(1);
    });

    test("When repo throws an error: should set error to the exception message and isLoading = false", () async {
      when(() => repo.getTodayArticles(NewsEndpoint.latest))
          .thenThrow(Exception('network down'));

      final controller = HomeController(repo);

      await controller.refreshFromApi();

      expect(controller.isLoading.value, false);
      expect(controller.error.value, contains('network down'));
      expect(controller.articles, isEmpty);
    });

  });

  group('Navigation next/prev', () {
    test("hasNext/hasPrev and next()/prev() should work correctly", () {
      final controller = HomeController(repo);
      controller.articles.assignAll([
        makeItem(title: 'A'),
        makeItem(title: 'B'),
        makeItem(title: 'C'),
      ]);
      controller.index.value = 0;

      expect(controller.hasPrev, false);
      expect(controller.hasNext, true);
      expect(controller.current?.title, 'A');

      controller.next();
      expect(controller.index.value, 1);
      expect(controller.current?.title, 'B');
      expect(controller.hasPrev, true);
      expect(controller.hasNext, true);

      controller.next();
      expect(controller.index.value, 2);
      expect(controller.current?.title, 'C');
      expect(controller.hasNext, false);

      controller.next(); // เกินขอบ → index ต้องไม่เปลี่ยน
      expect(controller.index.value, 2);

      controller.prev();
      expect(controller.index.value, 1);
      expect(controller.current?.title, 'B');

      controller.prev();
      expect(controller.index.value, 0);
      expect(controller.hasPrev, false);

      controller.prev(); // เกินขอบล่าง
      expect(controller.index.value, 0);
    });
  });

  group('onInit', () {
    test('onInit() จะโหลดจาก cache อัตโนมัติ', () {
      when(() => storage.getCachedArticles(NewsEndpoint.latest))
          .thenReturn([makeItem(title: 'Cached')]);

      final controller = HomeController(repo);
      controller.onInit(); // เรียกเองเพื่อยืนยันเจตนา

      expect(controller.articles.length, 1);
      expect(controller.current?.title, 'Cached');
      verify(() => storage.getCachedArticles(NewsEndpoint.latest)).called(1);
    });
  });
}
