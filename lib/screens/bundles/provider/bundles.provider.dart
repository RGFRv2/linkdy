import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:linkdy/constants/enums.dart';
import 'package:linkdy/models/data/bookmark_bundles.dart';
import 'package:linkdy/providers/api_client.provider.dart';
import 'package:linkdy/screens/bundles/model/bundles.model.dart';

final bundlesProvider =
    NotifierProvider.autoDispose<Bundles, BundlesModel>(Bundles.new);

class Bundles extends AutoDisposeNotifier<BundlesModel> {
  @override
  BundlesModel build() {
    final model = BundlesModel();
    Future.microtask(load);
    return model;
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      state.loadStatus = LoadStatus.loading;
      ref.notifyListeners();
    }

    final result =
        await ref.read(apiClientProvider)!.fetchBookmarkBundles(limit: 100);
    if (result.successful == true && result.content?.results != null) {
      state.bundles = [...result.content!.results!]
        ..sort((a, b) => a.order.compareTo(b.order));
      state.unsupportedServer = false;
      state.loadStatus = LoadStatus.loaded;
    } else {
      state.unsupportedServer = result.statusCode == 404;
      state.loadStatus = LoadStatus.error;
    }
    ref.notifyListeners();
  }

  Future<void> refresh() => load(showLoading: false);

  Future<bool> deleteBundle(BookmarkBundle bundle) async {
    if (bundle.id == null) return false;
    final result =
        await ref.read(apiClientProvider)!.deleteBookmarkBundle(bundle.id!);
    if (result.successful == true) {
      state.bundles =
          state.bundles.where((item) => item.id != bundle.id).toList();
      ref.notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> reorder(int oldIndex, int newIndex) async {
    if (state.reordering || oldIndex == newIndex) return false;

    final previous = [...state.bundles];
    final reordered = [...state.bundles];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    final normalized = [
      for (var index = 0; index < reordered.length; index++)
        reordered[index].copyWith(order: index),
    ];

    state.bundles = normalized;
    state.reordering = true;
    ref.notifyListeners();

    var successful = true;
    for (var index = 0; index < normalized.length; index++) {
      final bundle = normalized[index];
      final previousOrder =
          previous.firstWhere((item) => item.id == bundle.id).order;
      if (bundle.id == null || previousOrder == bundle.order) continue;
      final result = await ref.read(apiClientProvider)!.patchBookmarkBundle(
        bundle.id!,
        {"order": bundle.order},
      );
      if (result.successful != true) {
        successful = false;
        break;
      }
    }

    state.reordering = false;
    if (successful) {
      await load(showLoading: false);
    } else {
      state.bundles = previous;
      ref.notifyListeners();
    }
    return successful;
  }
}
