// --- Replace your current CustomDropdownSearch with this updated implementation ---
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum DropdownType { menu, modal, bottomSheet }

class CustomDropdownSearch<T> extends StatefulWidget {
  final String label;
  final List<T> Function(String? filter, LoadProps? props)? items;
  final Future<List<T>> Function(String? filter, int page, int limit)? onFind;

  // single-select API (existing)
  final T? selectedItem;
  final void Function(T?)? onChanged;

  // multi-select API (new)
  final bool multiSelection;
  final List<T>? selectedItems;
  final void Function(List<T>)? onChangedMulti;

  final String Function(T)? itemAsString;
  final bool showSearchBox;
  final String searchHint;
  final bool Function(T?, T?)? compareFn;
  final DropdownType type;

  const CustomDropdownSearch({
    Key? key,
    required this.label,
    this.items,
    this.onFind,
    this.selectedItem,
    this.selectedItems,
    this.itemAsString,
    this.onChanged,
    this.onChangedMulti,
    this.showSearchBox = true,
    this.searchHint = 'Tìm kiếm...',
    this.compareFn,
    this.type = DropdownType.menu,
    this.multiSelection = false,
  }) : super(key: key);

  /// Factory để tương thích với cách gọi `.multiSelection(...)`
  factory CustomDropdownSearch.multiSelection({
    Key? key,
    required String label,
    List<T> Function(String? filter, LoadProps? props)? items,
    Future<List<T>> Function(String? filter, int page, int limit)? onFind,
    List<T>? selectedItems,
    String Function(T)? itemAsString,
    void Function(List<T>)? onChangedMulti,
    bool showSearchBox = true,
    String searchHint = 'Tìm kiếm...',
    bool Function(T?, T?)? compareFn,
    DropdownType type = DropdownType.menu,
  }) {
    return CustomDropdownSearch<T>(
      key: key,
      label: label,
      items: items,
      onFind: onFind,
      selectedItems: selectedItems,
      itemAsString: itemAsString,
      onChangedMulti: onChangedMulti,
      showSearchBox: showSearchBox,
      searchHint: searchHint,
      compareFn: compareFn,
      type: type,
      multiSelection: true,
    );
  }

  @override
  State<CustomDropdownSearch<T>> createState() =>
      _CustomDropdownSearchState<T>();
}

class _CustomDropdownSearchState<T> extends State<CustomDropdownSearch<T>> {
  final TextEditingController _searchController = TextEditingController();

  List<T> _allItems = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  // for multi-select
  List<T> _selectedItems = [];

  String _itemToSingleLineString(T? item) {
    if (item == null) return '';
    final raw = widget.itemAsString != null
        ? widget.itemAsString!(item)
        : item.toString();
    return raw.replaceAll('\n', ' ');
  }

  bool _equals(T? a, T? b) {
    if (widget.compareFn != null) return widget.compareFn!(a, b);
    return a == b;
  }

  bool _containsItem(List<T> list, T item) {
    for (final e in list) {
      if (_equals(e, item)) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    if (widget.items != null) {
      _allItems = widget.items!(null, null);
    }

  
    if (widget.multiSelection) {
      _selectedItems = widget.selectedItems != null
          ? List<T>.from(widget.selectedItems!)
          : <T>[];
    }

    
    if (widget.onFind != null && _allItems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[CustomDropdownSearch] initial load onFind page=1');
        _loadMoreItems(reset: true, filter: _searchController.text);
      });
    }

    
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      for (final s in widget.selectedItems!) {
        if (!_containsItem(_allItems, s)) _allItems.add(s);
      }
    }
  }

  @override
  void didUpdateWidget(covariant CustomDropdownSearch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.multiSelection) {
      if (!listEquals(
        widget.selectedItems ?? [],
        oldWidget.selectedItems ?? [],
      )) {
        _selectedItems = widget.selectedItems != null
            ? List<T>.from(widget.selectedItems!)
            : <T>[];
        
        if (widget.selectedItems != null) {
          for (final s in widget.selectedItems!) {
            if (!_containsItem(_allItems, s)) {
              setState(() => _allItems.add(s));
            }
          }
        }
      }
    } 
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  Future<void> _loadMoreItems({bool reset = false, String? filter}) async {
    if (_isLoading || widget.onFind == null) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _page = 1;
        _allItems = [];
        _hasMore = true;
      }
    });

    try {
      debugPrint(
        '[CustomDropdownSearch] calling onFind page=$_page filter=$filter',
      );
      final newItems = await widget.onFind!(
        (filter?.isEmpty ?? true) ? null : filter,
        _page,
        10,
      );

      setState(() {
        
        for (final ni in newItems) {
          if (!_containsItem(_allItems, ni)) _allItems.add(ni);
        }
        _isLoading = false;
        _hasMore = newItems.length == 10;
        _page++;
      });
    } catch (e) {
      debugPrint('[CustomDropdownSearch] onFind error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterLocal(String? filter) {
    if (widget.items != null) {
      final list = widget.items!(filter?.isEmpty ?? true ? null : filter, null);
      setState(() {
        _allItems = list;
      });
    }
  }

  
  void _toggleSelection(T item) {
    setState(() {
      final idx = _selectedItems.indexWhere((e) => _equals(e, item));
      if (idx == -1) {
        _selectedItems.add(item);
      } else {
        _selectedItems.removeAt(idx);
      }
    });
    widget.onChangedMulti?.call(List<T>.from(_selectedItems));
  }

  Widget? _buildLeadingIcon(T? item) {
    if (item == null) return null;
    try {
      final dynamic dyn = item;
      final String? imageUrl = dyn.image ?? dyn.imageUrl ?? dyn.iconUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            imageUrl,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
          ),
        );
      }
    } catch (_) {
      // ignore nếu object không có field image
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      // use null items because we build popup ourselves, but still keep logic
      items: null,
      // single-select uses selectedItem; multi-select uses dropdownBuilder to show chips
      selectedItem: widget.multiSelection ? null : widget.selectedItem,
      // Ensure the displayed selected string is a single line (no newlines)
      itemAsString: (item) {
        if (widget.itemAsString != null) {
          return widget.itemAsString!(item);
        }
        return _itemToSingleLineString(item);
      },
      compareFn: widget.compareFn ?? (a, b) => a == b,
      // single-select onChanged goes through as before; multi-select manages via onChangedMulti
      onChanged: widget.multiSelection ? null : widget.onChanged,
      // custom builder for selected item so it never wraps (and for multi-select show chips)
      dropdownBuilder: (context, selectedItem) {
        if (widget.multiSelection) {
          if (_selectedItems.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedItems.map((c) {
                      final img = _buildLeadingIcon(c);
                      return Chip(
                        label: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            widget.itemAsString != null
                                ? widget.itemAsString!(c)
                                : c.toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        avatar: img != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  (() {
                                    try {
                                      final dynamic dyn = c;
                                      return dyn.image ?? dyn.imageUrl ?? '';
                                    } catch (_) {
                                      return '';
                                    }
                                  })(),
                                ),
                              )
                            : null,
                        onDeleted: () {
                          _toggleSelection(c);
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        } else {
          final s = _itemToSingleLineString(selectedItem);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Text(
              s,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }
      },
      popupProps: _buildPopupProps(),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // Common wrapper with white background, radius 10 and subtle border
  Widget _wrapPopup(Widget child) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: child,
      ),
    );
  }

  PopupProps<T> _buildPopupProps() {
    // small search field height (single line)
    Widget _buildSmallSearchField() {
      return SizedBox(
        height: 44,
        child: TextField(
          controller: _searchController,
          maxLines: 1,
          onChanged: (value) {
            if (widget.onFind != null) {
              _loadMoreItems(reset: true, filter: value);
            } else {
              _filterLocal(value);
            }
          },
          decoration: InputDecoration(
            hintText: widget.searchHint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
      );
    }

    // compute height using number of items (fix height to items count)
    double computeHeightForItems(
      BuildContext ctx, {
      required int itemCount,
      required double maxHeight,
    }) {
      const double headerHeight =
          100.0; // includes close-button row + search + paddings
      const double itemHeight = 48.0; // tightened item height per your request
      double content =
          headerHeight + (itemCount * itemHeight) + (_hasMore ? 50.0 : 8.0);
      double minContent = headerHeight + (min(itemCount, 3) * itemHeight);
      return min(maxHeight, max(content, minContent));
    }

    // Build a header row with optional Done button (for multi-select)
    Widget _buildHeaderRow(BuildContext ctx) {
      return Row(
        children: [
          if (widget.multiSelection)
            TextButton(
              onPressed: () {
                // notify parent (already notified on each toggle too), then close
                widget.onChangedMulti?.call(List<T>.from(_selectedItems));
                Navigator.pop(ctx);
              },
              child: const Text('Done'),
            ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ],
      );
    }

    switch (widget.type) {
      case DropdownType.menu:
        return PopupProps.menu(
          showSearchBox: false,
          constraints: const BoxConstraints(maxHeight: 420),
          containerBuilder: (ctx, popupWidget) {
            final availableMaxHeight = 360.0;
            final visibleCount = _allItems.isEmpty ? 3 : _allItems.length;
            final height = computeHeightForItems(
              ctx,
              itemCount: visibleCount,
              maxHeight: availableMaxHeight,
            );

            return _wrapPopup(
              SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // header row (Done + Close)
                      _buildHeaderRow(ctx),
                      const SizedBox(height: 2),
                      // search - on its own line
                      _buildSmallSearchField(),
                      const SizedBox(height: 6),
                      // If loading initially and no items yet, show centered SpinKitCircle
                      if (_isLoading && _allItems.isEmpty)
                        const Expanded(
                          child: Center(
                            child: SpinKitCircle(
                              color: Colors.orange,
                              size: 36,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              if (scrollNotification is ScrollEndNotification &&
                                  scrollNotification.metrics.pixels ==
                                      scrollNotification
                                          .metrics
                                          .maxScrollExtent &&
                                  _hasMore &&
                                  !_isLoading &&
                                  widget.onFind != null) {
                                _loadMoreItems();
                              }
                              return false;
                            },
                            child: _buildMenuListView(ctx),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          loadingBuilder: (context, _) => const Center(
            child: SpinKitCircle(color: Colors.orange, size: 36),
          ),
        );

      case DropdownType.modal:
        return PopupProps.modalBottomSheet(
          showSearchBox: false,
          containerBuilder: (ctx, popupWidget) {
            final screenW = MediaQuery.of(ctx).size.width;
            final screenH = MediaQuery.of(ctx).size.height;
            final maxW = min(600.0, screenW * 0.95);
            final maxH = screenH * 0.75;

            final visibleCount = _allItems.isEmpty ? 3 : _allItems.length;
            final height = computeHeightForItems(
              ctx,
              itemCount: visibleCount,
              maxHeight: maxH,
            );

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: _wrapPopup(
                  SizedBox(
                    height: height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          // header row (Done + Close)
                          _buildHeaderRow(ctx),
                          const SizedBox(height: 2),
                          // search area
                          _buildSmallSearchField(),
                          const SizedBox(height: 8),
                          // If loading initially and no items yet, show centered SpinKitCircle
                          if (_isLoading && _allItems.isEmpty)
                            const Expanded(
                              child: Center(
                                child: SpinKitCircle(
                                  color: Colors.orange,
                                  size: 36,
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (scrollNotification) {
                                  if (scrollNotification
                                          is ScrollEndNotification &&
                                      scrollNotification.metrics.pixels ==
                                          scrollNotification
                                              .metrics
                                              .maxScrollExtent &&
                                      _hasMore &&
                                      !_isLoading &&
                                      widget.onFind != null) {
                                    _loadMoreItems();
                                  }
                                  return false;
                                },
                                child: _buildMenuListView(ctx),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          loadingBuilder: (context, _) => const Center(
            child: SpinKitCircle(color: Colors.orange, size: 36),
          ),
        );

      case DropdownType.bottomSheet:
        return PopupProps.bottomSheet(
          showSearchBox: false,
          containerBuilder: (ctx, popupWidget) {
            final height = MediaQuery.of(ctx).size.height * 0.6;

            return Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // drag handle + header row (we keep top area compact)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    child: _buildHeaderRow(ctx),
                  ),
                  // search
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _searchController,
                        maxLines: 1,
                        onChanged: (value) {
                          if (widget.onFind != null) {
                            _loadMoreItems(reset: true, filter: value);
                          } else {
                            _filterLocal(value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: widget.searchHint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // If loading initially and no items yet, show centered SpinKitCircle
                  if (_isLoading && _allItems.isEmpty)
                    const Expanded(
                      child: Center(
                        child: SpinKitCircle(color: Colors.orange, size: 36),
                      ),
                    )
                  else
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollEndNotification &&
                              scrollNotification.metrics.pixels ==
                                  scrollNotification.metrics.maxScrollExtent &&
                              _hasMore &&
                              !_isLoading &&
                              widget.onFind != null) {
                            _loadMoreItems();
                          }
                          return false;
                        },
                        child: _buildMenuListView(ctx),
                      ),
                    ),
                ],
              ),
            );
          },
          loadingBuilder: (context, _) => const Center(
            child: SpinKitCircle(color: Colors.orange, size: 36),
          ),
        );
    }
  }

  Widget _buildMenuListView(BuildContext ctx) {
    // ensure local initial population if needed
    if (widget.items != null && _allItems.isEmpty) {
      _allItems = widget.items!(null, null);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: _allItems.length + (_hasMore && widget.onFind != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allItems.length) {
          // final item: loading placeholder for "load more"
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: _isLoading
                  ? const SpinKitCircle(color: Colors.orange, size: 28)
                  : const SizedBox(height: 8),
            ),
          );
        }

        final item = _allItems[index];
        final dynamic dyn = item;
        final String titleText = widget.itemAsString != null
            ? widget.itemAsString!(item)
            : (dyn?.name ?? item.toString() ?? dyn?.description);

        final leading = _buildLeadingIcon(item);

        if (widget.multiSelection) {
          final isSelected = _containsItem(_selectedItems, item);
          return Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: leading,
              title: Text(
                titleText,
                style: const TextStyle(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (v) {
                  _toggleSelection(item);
                },
              ),
              onTap: () {
                _toggleSelection(item);
              },
            ),
          );
        }

        // single-select behavior (unchanged)
        return Container(
          color: Colors.white, // ensure white background per request
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: leading,
            title: Text(
              titleText,
              style: const TextStyle(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            onTap: () {
              if (widget.multiSelection) {
                _toggleSelection(item);
              } else {
                widget.onChanged?.call(item);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}
