import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkdy/models/data/bookmark_bundles.dart';
import 'package:linkdy/models/server_instance.dart';
import 'package:linkdy/services/api_client.dart';

void main() {
  late _RecordingAdapter adapter;
  late ApiClientService apiClient;

  setUp(() {
    adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..httpClientAdapter = adapter;
    apiClient = ApiClientService(
      serverInstance: const ServerInstance(
        id: 'test',
        method: 'https',
        ipDomain: 'example.test',
        token: 'test-token',
      ),
      dioInstance: dio,
    );
  });

  test('fetchBookmarkBundles calls the trailing-slash endpoint', () async {
    final result = await apiClient.fetchBookmarkBundles(limit: 100, offset: 5);

    expect(result.successful, isTrue);
    expect(result.content?.results?.single.name, 'Mobile');
    expect(adapter.lastRequest.uri.path, '/api/bundles/');
    expect(adapter.lastRequest.uri.queryParameters, {
      'limit': '100',
      'offset': '5',
    });
  });

  test('fetchBookmarks sends the bundle filter', () async {
    final result = await apiClient.fetchBookmarks(
      bundleId: 42,
      limit: 20,
      offset: 40,
    );

    expect(result.successful, isTrue);
    expect(adapter.lastRequest.uri.path, '/api/bookmarks/');
    expect(adapter.lastRequest.uri.queryParameters['bundle'], '42');
  });

  test('bundle mutations use collection and detail endpoints', () async {
    await apiClient.postBookmarkBundle(
      const SetBookmarkBundleData(name: 'Mobile'),
    );
    expect(adapter.lastRequest.method, 'POST');
    expect(adapter.lastRequest.uri.path, '/api/bundles/');

    await apiClient.patchBookmarkBundle(42, {'name': 'iOS'});
    expect(adapter.lastRequest.method, 'PATCH');
    expect(adapter.lastRequest.uri.path, '/api/bundles/42/');

    final result = await apiClient.deleteBookmarkBundle(42);
    expect(result.successful, isTrue);
    expect(adapter.lastRequest.method, 'DELETE');
    expect(adapter.lastRequest.uri.path, '/api/bundles/42/');
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  late RequestOptions lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final response = options.path == '/bookmarks/'
        ? {
            'count': 0,
            'next': null,
            'previous': null,
            'results': <Object>[],
          }
        : options.method == 'DELETE'
            ? <String, Object?>{}
            : options.path == '/bundles/' && options.method == 'GET'
                ? {
                    'count': 1,
                    'next': null,
                    'previous': null,
                    'results': [
                      {
                        'id': 42,
                        'name': 'Mobile',
                        'search': '',
                        'any_tags': 'ios',
                        'all_tags': '',
                        'excluded_tags': '',
                        'order': 0,
                      },
                    ],
                  }
                : {
                    'id': 42,
                    'name': 'Mobile',
                    'search': '',
                    'any_tags': 'ios',
                    'all_tags': '',
                    'excluded_tags': '',
                    'order': 0,
                  };

    return ResponseBody.fromString(
      jsonEncode(response),
      options.method == 'DELETE' ? 204 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
