import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:linkdy/i18n/strings.g.dart';
import 'package:linkdy/models/data/bookmark_bundles.dart';
import 'package:linkdy/providers/api_client.provider.dart';
import 'package:linkdy/screens/bundles/provider/bundles.provider.dart';
import 'package:linkdy/screens/tags/provider/tags.provider.dart';

Future<void> openBookmarkBundleFormModal({
  required BuildContext context,
  BookmarkBundle? bundle,
}) =>
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => BookmarkBundleFormModal(bundle: bundle),
    );

class BookmarkBundleFormModal extends ConsumerStatefulWidget {
  final BookmarkBundle? bundle;

  const BookmarkBundleFormModal({
    super.key,
    this.bundle,
  });

  @override
  ConsumerState<BookmarkBundleFormModal> createState() =>
      _BookmarkBundleFormModalState();
}

class _BookmarkBundleFormModalState
    extends ConsumerState<BookmarkBundleFormModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _searchController;
  final _anyTagsController = TextEditingController();
  final _allTagsController = TextEditingController();
  final _excludedTagsController = TextEditingController();

  late List<String> _anyTags;
  late List<String> _allTags;
  late List<String> _excludedTags;
  bool _saving = false;
  String? _nameError;
  String? _saveError;

  bool get _editing => widget.bundle != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bundle?.name ?? "");
    _searchController =
        TextEditingController(text: widget.bundle?.search ?? "");
    _anyTags = _parseTags(widget.bundle?.anyTags ?? "");
    _allTags = _parseTags(widget.bundle?.allTags ?? "");
    _excludedTags = _parseTags(widget.bundle?.excludedTags ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _anyTagsController.dispose();
    _allTagsController.dispose();
    _excludedTagsController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String value) => value
      .trim()
      .split(RegExp(r"\s+"))
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList();

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = t.bookmarkBundles.nameRequired);
      return;
    }

    setState(() {
      _saving = true;
      _nameError = null;
      _saveError = null;
    });

    final data = SetBookmarkBundleData(
      name: name,
      search: _searchController.text.trim(),
      anyTags: _anyTags.join(" "),
      allTags: _allTags.join(" "),
      excludedTags: _excludedTags.join(" "),
      order: widget.bundle?.order,
    );

    final apiClient = ref.read(apiClientProvider)!;
    final result = _editing
        ? await apiClient.patchBookmarkBundle(widget.bundle!.id!, data.toJson())
        : await apiClient.postBookmarkBundle(data);

    if (!mounted) return;
    if (result.successful == true) {
      await ref.read(bundlesProvider.notifier).refresh();
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _saveError = t.bookmarkBundles.saveError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagsResponse = ref.watch(tagsRequestProvider).value?.content?.results;
    final suggestions = tagsResponse
            ?.map((tag) => tag.name ?? "")
            .where((name) => name.isNotEmpty)
            .toList() ??
        [];
    suggestions.sort();

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Material(
          color: Theme.of(context).bottomSheetTheme.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        _editing
                            ? Icons.edit_rounded
                            : Icons.create_new_folder_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _editing
                              ? t.bookmarkBundles.editBundle
                              : t.bookmarkBundles.createBundle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        tooltip: t.generic.close,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          enabled: !_saving,
                          autofocus: !_editing,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.folder_rounded),
                            border: const OutlineInputBorder(),
                            labelText: t.bookmarkBundles.name,
                            errorText: _nameError,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _searchController,
                          enabled: !_saving,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: const OutlineInputBorder(),
                            labelText: t.bookmarkBundles.search,
                            helperText: t.bookmarkBundles.searchDescription,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _TagRuleEditor(
                          controller: _anyTagsController,
                          label: t.bookmarkBundles.anyTags,
                          description: t.bookmarkBundles.anyTagsDescription,
                          tags: _anyTags,
                          suggestions: suggestions,
                          enabled: !_saving,
                          onChanged: (tags) => setState(() => _anyTags = tags),
                        ),
                        const SizedBox(height: 24),
                        _TagRuleEditor(
                          controller: _allTagsController,
                          label: t.bookmarkBundles.allTags,
                          description: t.bookmarkBundles.allTagsDescription,
                          tags: _allTags,
                          suggestions: suggestions,
                          enabled: !_saving,
                          onChanged: (tags) => setState(() => _allTags = tags),
                        ),
                        const SizedBox(height: 24),
                        _TagRuleEditor(
                          controller: _excludedTagsController,
                          label: t.bookmarkBundles.excludedTags,
                          description:
                              t.bookmarkBundles.excludedTagsDescription,
                          tags: _excludedTags,
                          suggestions: suggestions,
                          enabled: !_saving,
                          onChanged: (tags) =>
                              setState(() => _excludedTags = tags),
                        ),
                        if (_saveError != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            _saveError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: Text(t.generic.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(t.generic.save),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagRuleEditor extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String description;
  final List<String> tags;
  final List<String> suggestions;
  final bool enabled;
  final ValueChanged<List<String>> onChanged;

  const _TagRuleEditor({
    required this.controller,
    required this.label,
    required this.description,
    required this.tags,
    required this.suggestions,
    required this.enabled,
    required this.onChanged,
  });

  void _addTags(String value) {
    final additions = value
        .trim()
        .split(RegExp(r"\s+"))
        .where((tag) => tag.isNotEmpty && !tags.contains(tag));
    onChanged([...tags, ...additions]);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          description,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: IgnorePointer(
                ignoring: !enabled,
                child: EasyAutocomplete(
                  controller: controller,
                  suggestions: suggestions,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: t.bookmarkBundles.addTag,
                  ),
                  onSubmitted: enabled ? _addTags : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: enabled
                  ? () {
                      if (controller.text.trim().isNotEmpty) {
                        _addTags(controller.text);
                      }
                    }
                  : null,
              tooltip: t.bookmarkBundles.addTag,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                InputChip(
                  label: Text(tag),
                  onDeleted: enabled
                      ? () =>
                          onChanged(tags.where((item) => item != tag).toList())
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
