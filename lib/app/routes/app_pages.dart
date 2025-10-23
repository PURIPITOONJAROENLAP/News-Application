import 'package:get/get_navigation/src/routes/get_route.dart';
import '../feature/detail/detail_view.dart';
import '../feature/home/home_binding.dart';
import '../feature/home/home_view.dart';
import '../feature/saved/saved_binding.dart';
import '../feature/saved/saved_view.dart';

abstract class  Routes {
  static const home = '/';
  static const saved = '/saved';
  static const detail = '/detail';
}

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: Routes.saved,
      page: () => const SavedView(),
      binding: SavedBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.detail,
      page: () => const DetailView(),
    ),
  ];
}
