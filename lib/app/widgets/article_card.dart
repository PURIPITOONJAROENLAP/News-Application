import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../data/models/news_response.dart';
import '../feature/saved/saved_controller.dart';

class ArticleCard extends StatelessWidget {
  final Item article;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final savedCtrl = Get.put(SavedController());
    final thumb = article.images?.thumbnail ?? '';

    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumb.isNotEmpty)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: thumb,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                  // ==== ปุ่ม Save มุมขวาบน ====
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() {
                      final isSaved = savedCtrl.isSaved(article);
                      return IconButton(
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_add_outlined,
                          color: isSaved ? Colors.amber : Colors.white,
                        ),
                        onPressed: () {
                          if (isSaved) {
                            savedCtrl.removeArticle(article);
                            Get.snackbar(
                              'Removed',
                              'Article is removed',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor:
                              Colors.redAccent.withOpacity(0.8),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            savedCtrl.saveArticle(article);
                            Get.snackbar(
                              'Saved',
                              'Article is saved',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor:
                              Colors.green.withOpacity(0.8),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                      );
                    }),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${article.title}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${article.snippet}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                   '${article.timestamp}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
