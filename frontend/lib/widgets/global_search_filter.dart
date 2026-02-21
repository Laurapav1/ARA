import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/ara_theme.dart';

typedef ItemStringResolver<T> = String Function(T item);
typedef ItemTagsResolver<T> = List<String> Function(T item);
typedef ItemSelectedCallback<T> = FutureOr<void> Function(T item);
typedef SearchResultBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  VoidCallback onTap,
);

class GlobalFilterOption<T> {
  final String id;
  final String label;
  final bool Function(T item) predicate;

  const GlobalFilterOption({
    required this.id,
    required this.label,
    required this.predicate,
  });
}

class _PersistedSearchState {
  String query = '';
  Set<String> selectedFilterIds = <String>{};
}

class GlobalSearchFilterController<T> extends ChangeNotifier {
  static final Map<String, _PersistedSearchState> _store =
      <String, _PersistedSearchState>{};

  final String resourceType;
  final ItemStringResolver<T> titleOf;
  final ItemStringResolver<T> subtitleOf;
  final ItemTagsResolver<T> tagsOf;
  List<GlobalFilterOption<T>> _filterOptions;

  late final _PersistedSearchState _state;

  GlobalSearchFilterController({
    required this.resourceType,
    required this.titleOf,
    required this.subtitleOf,
    required this.tagsOf,
    List<GlobalFilterOption<T>> filterOptions = const [],
  }) : _filterOptions = filterOptions {
    _state = _store.putIfAbsent(resourceType, _PersistedSearchState.new);
  }

  String get query => _state.query;
  List<GlobalFilterOption<T>> get filterOptions => _filterOptions;
  Set<String> get selectedFilterIds => _state.selectedFilterIds;

  void setFilterOptions(List<GlobalFilterOption<T>> options) {
    _filterOptions = options;
    final valid = options.map((o) => o.id).toSet();
    final before = _state.selectedFilterIds.length;
    _state.selectedFilterIds.removeWhere((id) => !valid.contains(id));
    if (before != _state.selectedFilterIds.length) {
      notifyListeners();
    }
  }

  void updateQuery(String value) {
    if (_state.query == value) return;
    _state.query = value;
    notifyListeners();
  }

  void clearQuery() {
    updateQuery('');
  }

  void toggleFilter(String id) {
    if (_state.selectedFilterIds.contains(id)) {
      _state.selectedFilterIds.remove(id);
    } else {
      _state.selectedFilterIds.add(id);
    }
    notifyListeners();
  }

  bool isFilterSelected(String id) => _state.selectedFilterIds.contains(id);

  List<T> apply(List<T> items) {
    final q = query.trim().toLowerCase();
    final activeFilters = filterOptions
        .where((option) => selectedFilterIds.contains(option.id))
        .toList();

    return items.where((item) {
      if (q.isNotEmpty) {
        final fields = <String>[
          titleOf(item),
          subtitleOf(item),
          ...tagsOf(item),
        ];
        final matchesSearch =
            fields.any((field) => field.toLowerCase().contains(q));
        if (!matchesSearch) return false;
      }

      if (activeFilters.isEmpty) return true;
      return activeFilters.any((option) => option.predicate(item));
    }).toList();
  }
}

List<Widget> buildGlobalSearchFilterActions<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required GlobalSearchFilterController<T> controller,
  required ItemSelectedCallback<T> onItemSelected,
  SearchResultBuilder<T>? searchResultBuilder,
  bool showFilter = true,
}) {
  final actions = <Widget>[
    IconButton(
      tooltip: 'Search',
      icon: const Icon(Icons.search),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => _GlobalSearchView<T>(
              title: title,
              items: items,
              controller: controller,
              onItemSelected: onItemSelected,
              searchResultBuilder: searchResultBuilder,
            ),
          ),
        );
      },
    ),
  ];

  if (showFilter) {
    actions.add(
      IconButton(
        tooltip: 'Filter',
        icon: const Icon(Icons.filter_list),
        onPressed: () => _showFilterBottomSheet(context, controller),
      ),
    );
  }

  return actions;
}

void _showFilterBottomSheet<T>(
  BuildContext context,
  GlobalSearchFilterController<T> controller,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      if (controller.filterOptions.isEmpty) {
        return const SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'No filters available.',
              style: TextStyle(color: ARAColors.subInk),
            ),
          ),
        );
      }

      return AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.filterOptions.map((option) {
                  final isSelected = controller.isFilterSelected(option.id);
                  return FilterChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleFilter(option.id),
                    showCheckmark: true,
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    },
  );
}

class _GlobalSearchView<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final GlobalSearchFilterController<T> controller;
  final ItemSelectedCallback<T> onItemSelected;
  final SearchResultBuilder<T>? searchResultBuilder;

  const _GlobalSearchView({
    required this.title,
    required this.items,
    required this.controller,
    required this.onItemSelected,
    this.searchResultBuilder,
  });

  @override
  State<_GlobalSearchView<T>> createState() => _GlobalSearchViewState<T>();
}

class _GlobalSearchViewState<T> extends State<_GlobalSearchView<T>> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.query);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _textController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    if (_textController.text != widget.controller.query) {
      _textController.text = widget.controller.query;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.controller.apply(widget.items);

    return Scaffold(
      appBar: AppBar(title: Text('Search ${widget.title}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              autofocus: true,
              controller: _textController,
              onChanged: widget.controller.updateQuery,
              decoration: InputDecoration(
                hintText: 'Search ${widget.title}',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: widget.controller.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.controller.clearQuery();
                        },
                      ),
                filled: true,
                fillColor: ARAColors.cardBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ARAColors.surfaceWarmTint),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ARAColors.brand, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: visibleItems.isEmpty
                ? const Center(
                    child: Text(
                      'No matches found',
                      style: TextStyle(color: ARAColors.subInk),
                    ),
                  )
                : ListView.builder(
                    itemCount: visibleItems.length,
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      final onTap = () {
                        Navigator.of(context).pop();
                        widget.onItemSelected(item);
                      };
                      if (widget.searchResultBuilder != null) {
                        return widget.searchResultBuilder!(context, item, onTap);
                      }
                      final subtitle = widget.controller.subtitleOf(item);
                      final tags = widget.controller.tagsOf(item);
                      final details = <String>[
                        subtitle,
                        ...tags,
                      ].where((value) => value.trim().isNotEmpty).toList();
                      return ListTile(
                        title: Text(widget.controller.titleOf(item)),
                        subtitle: Text(
                          details.join(' - '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: onTap,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
