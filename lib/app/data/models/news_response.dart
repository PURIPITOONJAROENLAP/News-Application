import 'package:json_annotation/json_annotation.dart';
part 'news_response.g.dart';

@JsonSerializable(explicitToJson: true)
class NewsResponse {
  final String? status;
  final List<Item>? items;

  NewsResponse({
    this.status,
    this.items,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NewsResponseToJson(this);

  @override
  String toString() {
    return 'NewsResponse{status: $status, items: $items}';
  }

}

@JsonSerializable(explicitToJson: true)
class Item {
  final String? timestamp;
  final String? title;
  final String? snippet;
  final Images? images;
  final List<Item>? subnews;
  final bool? hasSubnews;
  final String? newsUrl;
  final String? publisher;

  Item({
    this.timestamp,
    this.title,
    this.snippet,
    this.images,
    this.subnews,
    this.hasSubnews,
    this.newsUrl,
    this.publisher,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  String toString() {
    return 'Item{timestamp: $timestamp, title: $title, snippet: $snippet, images: $images, subnews: $subnews, hasSubnews: $hasSubnews, newsUrl: $newsUrl, publisher: $publisher}';
  }

}

@JsonSerializable()
class Images {
  final String? thumbnail;
  final String? thumbnailProxied;

  Images({
    this.thumbnail,
    this.thumbnailProxied,
  });

  factory Images.fromJson(Map<String, dynamic> json) => _$ImagesFromJson(json);
  Map<String, dynamic> toJson() => _$ImagesToJson(this);
}
