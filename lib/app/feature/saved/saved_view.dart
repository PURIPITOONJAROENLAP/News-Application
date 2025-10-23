import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../widgets/article_card.dart';
import 'saved_controller.dart';

class SavedView extends GetView<SavedController> {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: Obx(() {
        if (controller.saved.isEmpty) {
          return const Center(child: Text('No saved articles'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.saved.length,
          itemBuilder: (_, i) {
            final article = controller.saved[i];
            return ArticleCard(
              article: article,
              onTap: () => Get.toNamed(Routes.detail, arguments: article)
            );
          },
        );
      }),
    );
  }
}
