// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsResponse _$NewsResponseFromJson(Map<String, dynamic> json) => NewsResponse(
  status: json['status'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NewsResponseToJson(NewsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  timestamp: json['timestamp'] as String?,
  title: json['title'] as String?,
  snippet: json['snippet'] as String?,
  images: json['images'] == null
      ? null
      : Images.fromJson(json['images'] as Map<String, dynamic>),
  subnews: (json['subnews'] as List<dynamic>?)
      ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasSubnews: json['hasSubnews'] as bool?,
  newsUrl: json['newsUrl'] as String?,
  publisher: json['publisher'] as String?,
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'timestamp': instance.timestamp,
  'title': instance.title,
  'snippet': instance.snippet,
  'images': instance.images?.toJson(),
  'subnews': instance.subnews?.map((e) => e.toJson()).toList(),
  'hasSubnews': instance.hasSubnews,
  'newsUrl': instance.newsUrl,
  'publisher': instance.publisher,
};

Images _$ImagesFromJson(Map<String, dynamic> json) => Images(
  thumbnail: json['thumbnail'] as String?,
  thumbnailProxied: json['thumbnailProxied'] as String?,
);

Map<String, dynamic> _$ImagesToJson(Images instance) => <String, dynamic>{
  'thumbnail': instance.thumbnail,
  'thumbnailProxied': instance.thumbnailProxied,
};
