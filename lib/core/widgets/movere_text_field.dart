import 'package:flutter/material.dart';

/// Movere AI'ın standart form alanı.
///
/// Sprint gelecek hafta auth ekranlarını yazarken (login/register)
/// tüm inputlar bu widget'tan türeyecek.
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

  /// true ise şifre alanı gibi davranır: yazı gizlenir,
  /// sağda göz ikonu çıkar ve gizle/göster yapılabilir.
  final bool obscureText;
  final TextInputType? keyboardType;

  /// Form doğrulaması: null dönerse geçerli, String dönerse hata mesajı.
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;

  @override
  State<MovereTextField> createState() => _MovereTextFieldState();
}

class _MovereTextFieldState extends State<MovereTextField> {
  // Göz ikonuna basıldıkça değişen yerel durum. Bu bilgiye başka hiçbir
  // ekranın ihtiyacı yok, o yüzden Riverpod değil setState yeterli.
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
