import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum DropdownType { menu, modal, bottomSheet }

class CustomDropdownSearch<T> extends StatelessWidget {
  final String label;
  final dynamic items;
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
    required this.items,
    this.selectedItem,
    this.itemAsString,
    this.onChanged,
    this.showSearchBox = true,
    this.searchHint = 'Tìm kiếm...',
    this.compareFn,
    this.type = DropdownType.menu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      items: items,
      selectedItem: selectedItem,
      itemAsString: itemAsString ?? (item) => item.toString(),
      compareFn: compareFn ?? (a, b) => a == b,
      onChanged: onChanged,
      popupProps: _buildPopupProps(),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.green,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
      suffixProps: const DropdownSuffixProps(
        dropdownButtonProps: DropdownButtonProps(
          iconClosed: Icon(Icons.keyboard_arrow_down, size: 20),
          iconOpened: Icon(Icons.keyboard_arrow_up, size: 20),
          iconSize: 20,
          padding: EdgeInsets.all(8),
          alignment: Alignment.center,
        ),
      ),
    );
  }

  PopupProps<T> _buildPopupProps() {
    final commonSearch = TextFieldProps(
      decoration: InputDecoration(
        hintText: searchHint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        prefixIcon: const Icon(Icons.search, size: 20),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
      ),
    );

    switch (type) {
      case DropdownType.menu:
        return PopupProps.menu(
          showSearchBox: showSearchBox,
          searchFieldProps: commonSearch,
          constraints: const BoxConstraints(maxHeight: 260),
          menuProps: const MenuProps(
            backgroundColor: Colors.white,
            elevation: 6,
            margin: EdgeInsets.only(top: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            barrierColor: Color(0x80000000),
            barrierDismissible: true,
          ),
          itemBuilder: (context, item, isDisabled, isSelected) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: Text(
                maxLines: 1,
                itemAsString != null ? itemAsString!(item) : item.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          },
          containerBuilder: (ctx, popupWidget) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const SizedBox(
                      height: 36,
                      width: 36,
                      child: Icon(Icons.close, size: 20),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: popupWidget,
                  ),
                ),
              ],
            );
          },
        );
      case DropdownType.modal:
        return PopupProps.modalBottomSheet(
          showSearchBox: showSearchBox,
          searchFieldProps: commonSearch,
        );
      case DropdownType.bottomSheet:
        return PopupProps.bottomSheet(
          showSearchBox: showSearchBox,
          searchFieldProps: commonSearch,
          loadingBuilder: (context, searchEntry) {
            return const Center(
              child: SpinKitCircle(color: Colors.orange, size: 40.0),
            );
          },
          containerBuilder: (ctx, popupWidget) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: popupWidget),
                ],
              ),
            );
          },
        );
    }
  }
}
