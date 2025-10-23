import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../data/local/shared_prefs_storage.dart';
import '../../data/models/news_response.dart';

class SavedController extends GetxController {
  final LocalStorage storage = Get.find<LocalStorage>();
  final saved = <Item>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSaved();
  }

  void loadSaved() {
    saved.assignAll(storage.getSavedArticles());
  }

  Future<void> saveArticle(Item article) async {
    await storage.saveArticle(article);
    loadSaved();
  }

  Future<void> removeArticle(Item article) async {
    await storage.removeArticle(article.newsUrl ?? '');
    loadSaved();
  }

  bool isSaved(Item article) {
    return saved.any((a) => a.newsUrl == article.newsUrl);
  }
}