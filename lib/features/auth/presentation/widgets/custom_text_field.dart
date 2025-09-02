import 'package:flutter/material.dart';

/// Reusable text field widget (general purpose).
/// - If [isPassword] is true, show password visibility toggle.
/// - If [suffixIcon] provided and not a password field, show it (with optional onTap).
/// - If [enableClear] is true, show a clear (X) button when text is not empty.
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool isPassword;
  final Widget? prefixIcon;

  /// Custom suffix icon (used when isPassword == false).
  final Widget? suffixIcon;

  /// Callback when custom suffix icon tapped.
  final VoidCallback? onSuffixTap;

  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final double borderRadius;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final bool filled;
  final int? maxLines;

  /// If true, show a small clear button (X) when there's text.
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
  late final TextEditingController _controller;
  late bool _obscure;
  bool _showClear = false;
  bool _controllerFromOutside = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
    _controllerFromOutside = widget.controller != null;
    _controller = widget.controller ?? TextEditingController();
    _showClear = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If user passes a new controller from outside, switch listener
    if (oldWidget.controller != widget.controller) {
      if (!_controllerFromOutside) {
        // dispose our internal controller if we created it previously
        _controller.removeListener(_onTextChanged);
        if (oldWidget.controller == null) {
          // safe to dispose previous internal controller
          _controller.dispose();
        }
      }
      _controllerFromOutside = widget.controller != null;
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onTextChanged);
      _showClear = _controller.text.isNotEmpty;
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_showClear != hasText) {
      setState(() => _showClear = hasText);
    }
    // bubble up change
    if (widget.onChanged != null) widget.onChanged!(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (!_controllerFromOutside) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color enabledColor = widget.enabledBorderColor ?? Colors.grey.shade300;
    final Color focusedColor = widget.focusedBorderColor ?? Colors.grey.shade400;

    // Build suffix: priority
    // 1) if isPassword -> password toggle
    // 2) else if enableClear && has text -> clear button
    // 3) else if suffixIcon provided -> custom suffix (wrapped with GestureDetector if onSuffixTap provided)
    // 4) else -> null
    Widget? suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscure = !_obscure),
        tooltip: _obscure ? 'Show password' : 'Hide password',
      );
    } else if (widget.enableClear && _showClear) {
      suffix = IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _controller.clear();
          // ensure onChanged called (listener will do that)
          // but sometimes we might want to explicitly call setState to update UI
          setState(() => _showClear = false);
        },
        tooltip: 'Clear',
      );
    } else if (widget.suffixIcon != null) {
      if (widget.onSuffixTap != null) {
        suffix = GestureDetector(
          onTap: widget.onSuffixTap,
          child: widget.suffixIcon,
        );
      } else {
        suffix = widget.suffixIcon;
      }
    } else {
      suffix = null;
    }

    return TextFormField(
      controller: _controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      validator: widget.validator,
      // onChanged handled via controller listener -> but still allow direct onChanged too
      // so we don't set onChanged here to avoid double-calls; listener calls widget.onChanged.
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
        filled: widget.filled,
        fillColor: widget.fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
