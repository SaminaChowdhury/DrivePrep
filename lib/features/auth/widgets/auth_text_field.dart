import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isFocused = false;
  bool _isObscured = true;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(220),
              letterSpacing: 0.3,
            ),
          ),
        ),
        // Animated field container
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused
                  ? Colors.white.withAlpha(120)
                  : Colors.white.withAlpha(40),
              width: _isFocused ? 1.5 : 1.0,
            ),
            color: _isFocused
                ? Colors.white.withAlpha(25)
                : Colors.white.withAlpha(15),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: Colors.cyan.withAlpha(20),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText ? _isObscured : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: Colors.white.withAlpha(200),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withAlpha(80),
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _isFocused
                            ? Colors.white.withAlpha(220)
                            : Colors.white.withAlpha(120),
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 20,
              ),
              suffixIcon: widget.obscureText
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color: Colors.white.withAlpha(120),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.w400,
              ),
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
