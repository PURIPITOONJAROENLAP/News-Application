import 'package:intl/intl.dart';
import '../enums/news_endpoint.dart';
import '../models/news_response.dart';
import '../services/news_api.dart';

class NewsRepository {
  final NewsApi api;
  NewsRepository(this.api);

  Future<NewsResponse> getTodayArticles(NewsEndpoint ep) async {
    final jsonMap = await api.fetch(ep.path);
    final response = NewsResponse.fromJson(jsonMap);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentNews = response.items?.where((article) {
      final ts = article.timestamp;
      if (ts == null) return false;
      final millis = int.tryParse(ts);
      if (millis == null) return false;
      final dt = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
      final dateStr = DateFormat('yyyy-MM-dd').format(dt);
     return dateStr == today;
    }).toList();

    return NewsResponse(
        status: response.status,
        items: (currentNews?.isEmpty ?? true)
          ? response.items
          : currentNews,
    );
  }
}
