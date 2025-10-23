import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/news_response.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  String _formatTs(String timestamp) {
    final dt = DateTime.tryParse(timestamp)?.toLocal();
    if (dt == null) return timestamp;
    return DateFormat('EEE, dd MMM yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as Item;
    final thumb = item.images?.thumbnail ?? '';
    final proxied = item.images?.thumbnailProxied ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('News Detail')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///-----------Thumbnail----------
              if (thumb.isNotEmpty || proxied.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    thumb.isNotEmpty ? thumb : proxied,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              ///------------Title-------------
              Text(
                '${item.title}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              ///-----------publisher -----------
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text('${item.publisher}'),
                    avatar: const Icon(Icons.person, size: 18),
                  ),
                  Chip(
                    label: Text(_formatTs('${item.timestamp}')),
                    avatar: const Icon(Icons.access_time, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                '${item.snippet}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              if ((item.subnews ?? []).isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  'Sub news',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: item.subnews!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final sub = item.subnews![i];
                    final sThumb =
                        sub.images?.thumbnail ??
                        sub.images?.thumbnailProxied ??
                        '';
                    return InkWell(
                      onTap: () =>
                          Get.toNamed(Get.currentRoute, arguments: sub),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sThumb.isNotEmpty) const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${sub.title}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${sub.snippet}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTs('${sub.timestamp}'),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          if (sThumb.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                sThumb,
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 80,
                                  height: 60,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),

              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      final uri = Uri.tryParse('${item.newsUrl}');
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Get.snackbar('Error', 'Cannot open URL');
                      }
                    },
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Open full article'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Copied',
                        'Link copied: ${item.newsUrl}',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.copy_all),
                    label: const Text('Copy link'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
