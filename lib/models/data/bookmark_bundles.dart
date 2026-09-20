class BookmarkBundlesResponse {
  final int? count;
  final String? next;
  final String? previous;
  final List<BookmarkBundle>? results;

  const BookmarkBundlesResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory BookmarkBundlesResponse.fromJson(Map<String, dynamic> json) =>
      BookmarkBundlesResponse(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: json["results"] == null
            ? []
            : List<BookmarkBundle>.from(
                json["results"]!.map((item) => BookmarkBundle.fromJson(item)),
              ),
      );
}

class BookmarkBundle {
  final int? id;
  final String name;
  final String search;
  final String anyTags;
  final String allTags;
  final String excludedTags;
  final String? filterUnread;
  final String? filterShared;
  final int order;
  final DateTime? dateCreated;
  final DateTime? dateModified;

  const BookmarkBundle({
    this.id,
    required this.name,
    this.search = "",
    this.anyTags = "",
    this.allTags = "",
    this.excludedTags = "",
    this.filterUnread,
    this.filterShared,
    this.order = 0,
    this.dateCreated,
    this.dateModified,
  });

  factory BookmarkBundle.fromJson(Map<String, dynamic> json) => BookmarkBundle(
        id: json["id"],
        name: json["name"] ?? "",
        search: json["search"] ?? "",
        anyTags: json["any_tags"] ?? "",
        allTags: json["all_tags"] ?? "",
        excludedTags: json["excluded_tags"] ?? "",
        filterUnread: json["filter_unread"],
        filterShared: json["filter_shared"],
        order: json["order"] ?? 0,
        dateCreated: json["date_created"] == null
            ? null
            : DateTime.parse(json["date_created"]),
        dateModified: json["date_modified"] == null
            ? null
            : DateTime.parse(json["date_modified"]),
      );

  BookmarkBundle copyWith({
    int? id,
    String? name,
    String? search,
    String? anyTags,
    String? allTags,
    String? excludedTags,
    String? filterUnread,
    String? filterShared,
    int? order,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) =>
      BookmarkBundle(
        id: id ?? this.id,
        name: name ?? this.name,
        search: search ?? this.search,
        anyTags: anyTags ?? this.anyTags,
        allTags: allTags ?? this.allTags,
        excludedTags: excludedTags ?? this.excludedTags,
        filterUnread: filterUnread ?? this.filterUnread,
        filterShared: filterShared ?? this.filterShared,
        order: order ?? this.order,
        dateCreated: dateCreated ?? this.dateCreated,
        dateModified: dateModified ?? this.dateModified,
      );
}

class SetBookmarkBundleData {
  final String name;
  final String search;
  final String anyTags;
  final String allTags;
  final String excludedTags;
  final int? order;

  const SetBookmarkBundleData({
    required this.name,
    this.search = "",
    this.anyTags = "",
    this.allTags = "",
    this.excludedTags = "",
    this.order,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "search": search,
        "any_tags": anyTags,
        "all_tags": allTags,
        "excluded_tags": excludedTags,
        if (order != null) "order": order,
      };
}
