import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:linkdy/constants/enums.dart';
import 'package:linkdy/constants/global_keys.dart';
import 'package:linkdy/i18n/strings.g.dart';
import 'package:linkdy/models/data/bookmark_bundles.dart';
import 'package:linkdy/providers/router.provider.dart';
import 'package:linkdy/router/names.dart';
import 'package:linkdy/screens/bundles/provider/bundles.provider.dart';
import 'package:linkdy/screens/bundles/ui/bookmark_bundle_form_modal.dart';
import 'package:linkdy/widgets/error_screen.dart';
import 'package:linkdy/widgets/no_data_screen.dart';

enum _BundleAction { edit, delete }

class BundlesScreen extends ConsumerWidget {
  const BundlesScreen({super.key});

  String _description(BookmarkBundle bundle) {
    final parts = <String>[];
    if (bundle.search.isNotEmpty) {
      parts.add("${t.bookmarkBundles.search}: ${bundle.search}");
    }
    if (bundle.anyTags.isNotEmpty) {
      parts.add("${t.bookmarkBundles.anyTags}: ${bundle.anyTags}");
    }
    if (bundle.allTags.isNotEmpty) {
      parts.add("${t.bookmarkBundles.allTags}: ${bundle.allTags}");
    }
    if (bundle.excludedTags.isNotEmpty) {
      parts.add("${t.bookmarkBundles.excludedTags}: ${bundle.excludedTags}");
    }
    return parts.isEmpty ? t.bookmarkBundles.allBookmarks : parts.join(" · ");
  }

  Future<void> _deleteBundle(
    BuildContext context,
    WidgetRef ref,
    BookmarkBundle bundle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.bookmarkBundles.deleteBundle),
        content: Text(t.bookmarkBundles.deleteConfirmation(name: bundle.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.generic.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.bookmarkBundles.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final successful =
        await ref.read(bundlesProvider.notifier).deleteBundle(bundle);
    final messenger = ScaffoldMessengerKeys.bundles.currentState;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          successful
              ? t.bookmarkBundles.deletedSuccessfully
              : t.bookmarkBundles.deleteError,
        ),
        backgroundColor: successful ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(bundlesProvider);

    return ScaffoldMessenger(
      key: ScaffoldMessengerKeys.bundles,
      child: Scaffold(
        body: RefreshIndicator(
          edgeOffset: 100,
          onRefresh: ref.read(bundlesProvider.notifier).refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar.large(
                pinned: true,
                floating: true,
                centerTitle: false,
                title: Text(t.bookmarkBundles.bundles),
              ),
              if (model.reordering)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(),
                ),
              if (model.loadStatus == LoadStatus.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (model.loadStatus == LoadStatus.error)
                SliverFillRemaining(
                  child: ErrorScreen(
                    error: model.unsupportedServer
                        ? t.bookmarkBundles.requiresNewerServer
                        : t.bookmarkBundles.cannotLoadBundles,
                  ),
                ),
              if (model.loadStatus == LoadStatus.loaded &&
                  model.bundles.isEmpty)
                SliverFillRemaining(
                  child: NoDataScreen(message: t.bookmarkBundles.noBundles),
                ),
              if (model.loadStatus == LoadStatus.loaded &&
                  model.bundles.isNotEmpty)
                SliverReorderableList(
                  itemCount: model.bundles.length,
                  onReorderItem: (oldIndex, newIndex) async {
                    final successful = await ref
                        .read(bundlesProvider.notifier)
                        .reorder(oldIndex, newIndex);
                    if (!successful) {
                      ScaffoldMessengerKeys.bundles.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(t.bookmarkBundles.reorderError),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  itemBuilder: (context, index) {
                    final bundle = model.bundles[index];
                    return ListTile(
                      key: ValueKey(bundle.id),
                      leading: const Icon(Icons.folder_rounded),
                      title: Text(
                        bundle.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _description(bundle),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => ref.read(routerProvider).pushNamed(
                            RoutesNames.bundleBookmarks,
                            pathParameters: {"id": bundle.id.toString()},
                            extra: bundle,
                          ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<_BundleAction>(
                            onSelected: (action) {
                              switch (action) {
                                case _BundleAction.edit:
                                  openBookmarkBundleFormModal(
                                    context: context,
                                    bundle: bundle,
                                  );
                                case _BundleAction.delete:
                                  _deleteBundle(context, ref, bundle);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: _BundleAction.edit,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.edit_rounded),
                                  title: Text(t.bookmarkBundles.editBundle),
                                ),
                              ),
                              PopupMenuItem(
                                value: _BundleAction.delete,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.delete_rounded),
                                  title: Text(t.bookmarkBundles.deleteBundle),
                                ),
                              ),
                            ],
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.drag_handle_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (model.loadStatus == LoadStatus.loaded)
                const SliverToBoxAdapter(
                  child: SizedBox(height: 88),
                ),
            ],
          ),
        ),
        floatingActionButton: model.unsupportedServer
            ? null
            : FloatingActionButton(
                onPressed: () => openBookmarkBundleFormModal(context: context),
                tooltip: t.bookmarkBundles.createBundle,
                child: const Icon(Icons.create_new_folder_rounded),
              ),
      ),
    );
  }
}
