import 'package:dio/dio.dart';

class NewsApi {
  static const _baseUrl = 'https://google-news13.p.rapidapi.com';
  static const _host = 'google-news13.p.rapidapi.com';
  static const _apiKey = 'xxxxxxxx';

  final Dio _dio;

  NewsApi([Dio? dio])
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': _host,
          'Accept': 'application/json',
        },
      ));

  Future<Map<String, dynamic>> fetch(String endpoint) async {
    try {
      final res = await _dio.get('/$endpoint', queryParameters: {'lr': 'en-US'});
      if (res.statusCode == 200) {
        final json = res.data;
        return json;
      }
      else{
        return {
          "status":"Error ${res.statusCode}",
          "items":[]
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return  {
          "status":"Rate limit exceeded",
          "items":[]
        };
      }
      return  {
        "status":"Error ${e.response?.statusCode } : $e",
        "items":[]
      };
    }
  }
}
