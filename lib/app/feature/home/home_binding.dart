import 'package:get/get.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/services/news_api.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NewsApi());
    Get.lazyPut(() => NewsRepository(
      Get.find<NewsApi>(),
    ));
    Get.put(HomeController(Get.find<NewsRepository>()));
  }
}
