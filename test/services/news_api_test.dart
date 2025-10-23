import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:news_app/app/data/services/news_api.dart';


class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late NewsApi api;

  setUp(() {
    dio = _MockDio();
    api = NewsApi(dio);
  });

  Response _res({
    required int status,
    required dynamic data,
    String path = '/latest',
  }) {
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: status,
      data: data,
    );
  }

  DioException _dioErr({
    required int status,
    String path = '/latest',
  }) {
    return DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(requestOptions: RequestOptions(path: path), statusCode: status),
      type: DioExceptionType.badResponse,
    );
  }

  group('NewsApi.fetch', () {
    test('returns JSON map when statusCode == 200', () async {
      final fake = {
        'status': 'ok',
        'items': [
          {'title': 'A', 'timestamp': '1761141180000', 'newsUrl': '', 'publisher': 'X'}
        ],
      };

      when(() => dio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => _res(status: 200, data: fake));

      final result = await api.fetch('latest');

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'ok');
      expect((result['items'] as List).length, 1);
      verify(() => dio.get('/latest', queryParameters: {'lr': 'en-US'})).called(1);
    });

    test('returns {status: Error <code>, items: []} when non-200', () async {
      when(() => dio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => _res(status: 500, data: {'message': 'oops'}));

      final result = await api.fetch('latest');

      expect(result['status'], 'Error 500');
      expect(result['items'], isA<List>());
      expect((result['items'] as List).isEmpty, true);
    });

    test('returns {status: Rate limit exceeded, items: []} on 429 DioException', () async {
      when(() => dio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenThrow(_dioErr(status: 429));

      final result = await api.fetch('latest');

      expect(result['status'], 'Rate limit exceeded');
      expect((result['items'] as List).isEmpty, true);
    });

    test('returns {status: Error <code> : <exception>, items: []} for other DioException', () async {
      when(() => dio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenThrow(_dioErr(status: 503));

      final result = await api.fetch('latest');

      expect(result['status'], startsWith('Error 503'));
      expect((result['items'] as List).isEmpty, true);
    });
  });
}
