import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkdy/constants/enums.dart';
import 'package:linkdy/constants/shared_preferences_keys.dart';
import 'package:linkdy/models/data/bookmark_bundles.dart';
import 'package:linkdy/models/server_instance.dart';
import 'package:linkdy/providers/api_client.provider.dart';
import 'package:linkdy/providers/shared_preferences.provider.dart';
import 'package:linkdy/screens/bundles/ui/bundles.dart';
import 'package:linkdy/screens/filtered_bookmarks/ui/filtered_bookmarks.dart';
import 'package:linkdy/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('loads bundles and opens the creation form', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..httpClientAdapter = _BundlesAdapter();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);
    container.read(apiClientProvider.notifier).setApiClient(
          ApiClientService(
            serverInstance: const ServerInstance(
              id: 'test',
              method: 'https',
              ipDomain: 'example.test',
              token: 'test-token',
            ),
            dioInstance: dio,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BundlesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bundles'), findsAtLeastNWidgets(1));
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.textContaining('Any tags: ios'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create bundle'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('loads bundle contents without a manual refresh', (tester) async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesKeys.showFavicon: false,
      SharedPreferencesKeys.enableSlideOptions: false,
    });
    final preferences = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..httpClientAdapter = _BundlesAdapter();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);
    container.read(apiClientProvider.notifier).setApiClient(
          ApiClientService(
            serverInstance: const ServerInstance(
              id: 'test',
              method: 'https',
              ipDomain: 'example.test',
              token: 'test-token',
            ),
            dioInstance: dio,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: FilteredBookmarksScreen(
            filteredBookmarksMode: FilteredBookmarksMode.bundle,
            bundle: BookmarkBundle(id: 42, name: 'Mobile'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bundle bookmark'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

class _BundlesAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = options.path == '/tags/'
        ? {
            'count': 1,
            'next': null,
            'previous': null,
            'results': [
              {'id': 1, 'name': 'ios'},
            ],
          }
        : options.path == '/bookmarks/'
            ? {
                'count': 1,
                'next': null,
                'previous': null,
                'results': [
                  {
                    'id': 7,
                    'url': 'https://example.test/bookmark',
                    'title': 'Bundle bookmark',
                    'description': 'Loaded automatically',
                    'notes': '',
                    'website_title': '',
                    'website_description': '',
                    'is_archived': false,
                    'unread': false,
                    'shared': false,
                    'tag_names': ['ios'],
                    'date_added': '2026-09-20T08:00:00Z',
                    'date_modified': '2026-09-20T09:00:00Z',
                  },
                ],
              }
        : {
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
          };
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
