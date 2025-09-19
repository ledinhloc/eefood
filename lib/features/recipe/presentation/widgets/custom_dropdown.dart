import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum DropdownType { menu, modal, bottomSheet }

class CustomDropdownSearch<T> extends StatefulWidget {
  final String label;
  final List<T> Function(String? filter, LoadProps? props)? items;
  final Future<List<T>> Function(String? filter, int page, int limit)? onFind;
  final T? selectedItem;
  final String Function(T)? itemAsString;
  final void Function(T?)? onChanged;
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
    this.itemAsString,
    this.onChanged,
    this.showSearchBox = true,
    this.searchHint = 'Tìm kiếm...',
    this.compareFn,
    this.type = DropdownType.menu,
  }) : super(key: key);

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

  String _itemToSingleLineString(T? item) {
    if (item == null) return '';
    final raw = widget.itemAsString != null
        ? widget.itemAsString!(item)
        : item.toString();
    return raw.replaceAll('\n', ' ');
  }

  @override
  void initState() {
    super.initState();
    if (widget.items != null) {
      // Local: load full list at start (keep original behavior)
      _allItems = widget.items!(null, null);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      final newItems = await widget.onFind!(
        filter?.isEmpty ?? true ? null : filter,
        _page,
        10,
      );

      setState(() {
        _allItems.addAll(newItems);
        _isLoading = false;
        _hasMore = newItems.length == 10;
        _page++;
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      // use null items because we build popup ourselves, but still keep logic
      items: null,
      selectedItem: widget.selectedItem,
      // Ensure the displayed selected string is a single line (no newlines)
      itemAsString: (item) => _itemToSingleLineString(item),
      compareFn: widget.compareFn ?? (a, b) => a == b,
      onChanged: widget.onChanged,
      // custom builder for selected item so it never wraps
      dropdownBuilder: (context, selectedItem) {
        final s = _itemToSingleLineString(selectedItem);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Text(
            s,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(fontSize: 16),
          ),
        );
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

    switch (widget.type) {
      case DropdownType.menu:
        return PopupProps.menu(
          showSearchBox: false,
          constraints: const BoxConstraints(maxHeight: 420),
          containerBuilder: (ctx, popupWidget) {
            // ensure initial remote load
            if (widget.onFind != null && _allItems.isEmpty && !_isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadMoreItems(reset: true, filter: _searchController.text);
              });
            }

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
                      // Close button on its own line (not same row as search)
                      Row(
                        children: [
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
                      ),
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
            // ensure remote initial load
            if (widget.onFind != null && _allItems.isEmpty && !_isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadMoreItems(reset: true, filter: _searchController.text);
              });
            }

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
                          // close button on its own line (top-right)
                          Row(
                            children: [
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
                          ),
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
            if (widget.onFind != null && _allItems.isEmpty && !_isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadMoreItems(reset: true, filter: _searchController.text);
              });
            }

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
                  // drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
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
        return Container(
          color: Colors.white, // ensure white background per request
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            title: Text(
              // ensure single-line display and ellipsis
              (widget.itemAsString != null
                      ? widget.itemAsString!(item)
                      : item.toString())
                  .replaceAll('\n', ' '),
              style: const TextStyle(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            onTap: () {
              widget.onChanged?.call(item);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
