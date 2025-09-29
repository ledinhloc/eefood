import 'package:flutter/material.dart';

/// Custom reusable TextField with:
/// - Password toggle
/// - Clear button
/// - Suffix icon
/// - onFocusLost callback
/// - Focus-aware error handling (error text disappears on focus)
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFocusLost;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final double borderRadius;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final bool filled;
  final int? maxLines;
  final bool enableClear;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onFocusLost,
    this.focusNode,
    this.textInputAction,
    this.borderRadius = 8.0,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.filled = false,
    this.maxLines = 1,
    this.enableClear = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _obscure;
  bool _showClear = false;
  bool _controllerFromOutside = false;
  bool _focusFromOutside = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;

    _controllerFromOutside = widget.controller != null;
    _controller = widget.controller ?? TextEditingController();
    _showClear = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);

    _focusFromOutside = widget.focusNode != null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_showClear != hasText) setState(() => _showClear = hasText);
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
    if (!_focusNode.hasFocus) {
      widget.onFocusLost?.call(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (!_controllerFromOutside) _controller.dispose();

    _focusNode.removeListener(_onFocusChanged);
    if (!_focusFromOutside) _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabledColor = widget.enabledBorderColor ?? Colors.grey.shade300;
    final focusedColor = widget.focusedBorderColor ?? Colors.green.shade400;

    Widget? suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    } else if (widget.enableClear && _showClear) {
      suffix = IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _controller.clear();
          setState(() => _showClear = false);
        },
      );
    } else if (widget.suffixIcon != null) {
      suffix = widget.onSuffixTap != null
          ? GestureDetector(onTap: widget.onSuffixTap, child: widget.suffixIcon)
          : widget.suffixIcon;
    }

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: widget.textInputAction,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      validator: _hasFocus ? (_) => null : widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: enabledColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: focusedColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: focusedColor, width: 2.0),
        ),
        filled: widget.filled,
        fillColor: widget.fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}
