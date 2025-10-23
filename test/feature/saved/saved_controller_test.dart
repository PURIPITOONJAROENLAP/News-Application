import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:news_app/app/feature/saved/saved_controller.dart';
import 'package:news_app/app/data/local/shared_prefs_storage.dart';
import 'package:news_app/app/data/models/news_response.dart';

class _MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late _MockLocalStorage storage;
  late SavedController controller;

  Item makeItem(String url, [String title = 'Title']) {
    return Item(
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      snippet: 'snippet',
      images: Images(thumbnail: 'thumb', thumbnailProxied: 'thumbP'),
      subnews: const [],
      hasSubnews: false,
      newsUrl: url,
      publisher: 'pub',
    );
  }

  setUp(() {
    Get.testMode = true;
    Get.reset();
    storage = _MockLocalStorage();
    Get.put<LocalStorage>(storage);
    controller = SavedController();
  });

  tearDown(() {
    Get.reset();
  });

  group('SavedController', () {
    test("onInit() should load data from storage", () {
      final fakeList = [makeItem('1'), makeItem('2')];
      when(() => storage.getSavedArticles()).thenReturn(fakeList);

      controller.onInit();

      expect(controller.saved.length, 2);
      expect(controller.saved.first.newsUrl, '1');
      verify(() => storage.getSavedArticles()).called(1);
    });

    test('loadSaved() should update saved from storage', () {
      final fakeList = [makeItem('a')];
      when(() => storage.getSavedArticles()).thenReturn(fakeList);

      controller.loadSaved();

      expect(controller.saved.length, 1);
      expect(controller.saved.first.newsUrl, 'a');
    });

    test('saveArticle() should save to storage and then reload', () async {
      final item = makeItem('abc');
      when(() => storage.saveArticle(item)).thenAnswer((_) async {});
      when(() => storage.getSavedArticles()).thenReturn([item]);

      await controller.saveArticle(item);

      verify(() => storage.saveArticle(item)).called(1);
      verify(() => storage.getSavedArticles()).called(1);
      expect(controller.saved.length, 1);
      expect(controller.saved.first.newsUrl, 'abc');
    });

    test('removeArticle() should call storage.removeArticle and then reload', () async {
      final item = makeItem('test');
      when(() => storage.removeArticle(item.newsUrl ?? '')).thenAnswer((_) async {});
      when(() => storage.getSavedArticles()).thenReturn([]);

      await controller.removeArticle(item);

      verify(() => storage.removeArticle(item.newsUrl ?? '')).called(1);
      verify(() => storage.getSavedArticles()).called(1);
      expect(controller.saved.isEmpty, true);
    });

    test("isSaved() should return true when the article is saved", () {
      final item = makeItem('1');
      controller.saved.assignAll([item]);

      final result = controller.isSaved(item);

      expect(result, true);
    });

    test("isSaved() should return false when there are no articles in saved", () {
      final item = makeItem('notfound');
      controller.saved.clear();

      final result = controller.isSaved(item);

      expect(result, false);
    });
  });
}
