import 'package:flutter_test/flutter_test.dart';
import 'package:linkdy/models/data/bookmark_bundles.dart';

void main() {
  group('BookmarkBundle', () {
    test('parses the fields available since linkding 1.41', () {
      final bundle = BookmarkBundle.fromJson({
        'id': 12,
        'name': 'Unread Flutter',
        'search': 'flutter',
        'any_tags': 'mobile dart',
        'all_tags': 'development',
        'excluded_tags': 'archived',
        'order': 3,
        'date_created': '2026-09-20T08:00:00Z',
        'date_modified': '2026-09-20T09:00:00Z',
      });

      expect(bundle.id, 12);
      expect(bundle.name, 'Unread Flutter');
      expect(bundle.search, 'flutter');
      expect(bundle.anyTags, 'mobile dart');
      expect(bundle.allTags, 'development');
      expect(bundle.excludedTags, 'archived');
      expect(bundle.order, 3);
      expect(bundle.dateCreated, DateTime.utc(2026, 9, 20, 8));
      expect(bundle.dateModified, DateTime.utc(2026, 9, 20, 9));
    });

    test('accepts optional filters exposed by newer servers', () {
      final bundle = BookmarkBundle.fromJson({
        'id': 13,
        'name': 'Shared',
        'filter_unread': 'yes',
        'filter_shared': 'yes',
      });

      expect(bundle.filterUnread, 'yes');
      expect(bundle.filterShared, 'yes');
      expect(bundle.search, isEmpty);
      expect(bundle.order, 0);
    });
  });

  test('SetBookmarkBundleData uses the linkding API field names', () {
    const data = SetBookmarkBundleData(
      name: 'Mobile',
      search: 'flutter',
      anyTags: 'ios android',
      allTags: 'mobile',
      excludedTags: 'archived',
      order: 2,
    );

    expect(data.toJson(), {
      'name': 'Mobile',
      'search': 'flutter',
      'any_tags': 'ios android',
      'all_tags': 'mobile',
      'excluded_tags': 'archived',
      'order': 2,
    });
  });
}
