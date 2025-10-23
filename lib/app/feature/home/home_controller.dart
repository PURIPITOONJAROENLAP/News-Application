import 'package:get/get.dart';
import '../../data/enums/news_endpoint.dart';
import '../../data/local/shared_prefs_storage.dart';
import '../../data/models/news_response.dart';
import '../../data/repositories/news_repository.dart';

class HomeController extends GetxController {
  final NewsRepository repo;
  HomeController(this.repo);

  final LocalStorage _storage = Get.find<LocalStorage>();
  final endpoint = NewsEndpoint.latest.obs;
  final isLoading = false.obs;
  final error = RxnString();
  final articles = <Item>[].obs;
  final index = 0.obs;

  Item? get current => articles.isEmpty ? null : articles[index.value];
  bool get hasNext => index.value < articles.length - 1;
  bool get hasPrev => index.value > 0;


  void getDataFromCache([NewsEndpoint? ep]) {
    if (ep != null) endpoint.value = ep;
    isLoading.value = true;
    error.value = null;
    final cached = _storage.getCachedArticles(endpoint.value);

    if (cached.isNotEmpty) {
      articles.assignAll(cached);
      index.value = 0;
    } else {
      error.value = 'No data in memory';
      articles.clear();
    }
    isLoading.value = false;
  }


  Future<void> refreshFromApi() async {
    articles.clear();
    index.value = 0;
    isLoading.value = true;
    error.value = null;
    try {
      final result = await repo.getTodayArticles(endpoint.value);
      if(result.status != 'success'){
        error.value = result.status;
      }
      await _storage.cacheArticles(endpoint.value, result.items ?? []);
      articles.assignAll(result.items  ?? []);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void next() => hasNext ? index.value++ : null;
  void prev() => hasPrev ? index.value-- : null;

  @override
  void onInit() {
    super.onInit();
    getDataFromCache();
  }
}
