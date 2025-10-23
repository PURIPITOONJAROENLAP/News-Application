import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_response.dart';
import '../enums/news_endpoint.dart';

class LocalStorage {
  LocalStorage(this._prefs);
  final SharedPreferences _prefs;

  ///--------Cache------
  String _cacheKey(NewsEndpoint ep) => 'cache_${ep.name}';

  List<Item> getCachedArticles(NewsEndpoint ep) {
    final raw = _prefs.getString(_cacheKey(ep));
    if (raw == null || raw.isEmpty) return const <Item>[];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Item.fromJson).toList();
  }

  Future<void> cacheArticles(NewsEndpoint ep, List<Item> items) async {
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_cacheKey(ep), jsonStr);
  }


  ///--------Saved------------
  static const _savedKey = 'saved_articles';

  List<Item> getSavedArticles() {
    final raw = _prefs.getString(_savedKey);
    if (raw == null || raw.isEmpty) return <Item>[];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return List<Item>.from(list.map(Item.fromJson));
  }

  Future<void> saveArticle(Item item) async {
    final current = List<Item>.from(getSavedArticles());
    final exists = current.any((e) => e.newsUrl == item.newsUrl);
    if (!exists) {
      current.insert(0, item);
      await _prefs.setString(
        _savedKey,
        jsonEncode(current.map((e) => e.toJson()).toList()),
      );
    }
  }

  Future<void> removeArticle(String newsUrl) async {
    final current = List<Item>.from(getSavedArticles());
    current.removeWhere((e) => e.newsUrl == newsUrl);
    await _prefs.setString(
      _savedKey,
      jsonEncode(current.map((e) => e.toJson()).toList()),
    );
  }

  bool isSaved(String newsUrl) => getSavedArticles().any((e) => e.newsUrl == newsUrl);
}