import 'package:flutter/material.dart';

/// Movere AI's standard form field.
///
/// When we write the auth screens next sprint (login/register)
/// all inputs will derive from this widget.
class MovereTextField extends StatefulWidget {
  const MovereTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;

  /// if true, it behaves like a password field: the text is hidden,
  /// an eye icon appears on the right, and you can toggle hide/show.
  final bool obscureText;
  final TextInputType? keyboardType;

  /// Form validation: returns null if valid, a String (error message) otherwise.
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;

  @override
  State<MovereTextField> createState() => _MovereTextFieldState();
}

class _MovereTextFieldState extends State<MovereTextField> {
  // Local state that changes each time the eye icon is pressed. No other
  // screen needs this info, so setState is enough — no Riverpod.
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon:
                widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
