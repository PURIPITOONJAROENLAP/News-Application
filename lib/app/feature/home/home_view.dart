import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/enums/news_endpoint.dart';
import '../../routes/app_pages.dart';
import '../../widgets/article_card.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => Get.toNamed(Routes.saved),
          ),
          IconButton(
            onPressed: controller.refreshFromApi,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Obx(() => Row(
                children: NewsEndpoint.values.map((ep) {
                  final selected = controller.endpoint.value == ep;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(ep.title),
                      selected: selected,
                      onSelected: (_) => controller.getDataFromCache(ep),
                    ),
                  );
                }).toList(),
              )),
            ),
          ),
          Flexible(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.value == 'No data in memory') {
                return Center(
                  child: const Text('No data in local memory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                );
              }
              if (controller.error.value == 'Rate limit exceeded') {
                return Center(
                  child: const Text('You have exceeded the MONTHLY quota for Requests on your current plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                );
              }
              final article = controller.current;
              if (article == null) return const Center(child: Text('No articles found.'));
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(onPressed: controller.hasPrev ? controller.prev : null, icon: const Icon(Icons.arrow_back)),
                            Text('previous'),
                          ],
                        ),
                        Row(
                          children: [
                            Text('next'),
                            IconButton(onPressed: controller.hasNext ? controller.next : null, icon: const Icon(Icons.arrow_forward)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ArticleCard(
                      article: article,
                      onTap: () => Get.toNamed(Routes.detail, arguments: article)
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
