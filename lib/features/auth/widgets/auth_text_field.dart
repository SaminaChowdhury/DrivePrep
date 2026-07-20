import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_glass_background.dart';

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
      setState(() => _isFocused = _focusNode.hasFocus);
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AuthColors.alabaster.withAlpha(230),
              letterSpacing: 0.3,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AuthColors.inputFill,
            border: Border.all(
              color: _isFocused
                  ? AuthColors.roseGoldSolid.withAlpha(140)
                  : AuthColors.roseGold,
              width: _isFocused ? 1.4 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AuthColors.roseGoldSolid.withAlpha(35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
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
              color: AuthColors.alabaster,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: AuthColors.roseGoldSolid,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.outfit(
                fontSize: 14,
                color: AuthColors.alabaster.withAlpha(90),
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _isFocused
                            ? AuthColors.roseGoldSolid
                            : AuthColors.alabaster.withAlpha(140),
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 20),
              suffixIcon: widget.obscureText
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color: AuthColors.alabaster.withAlpha(140),
                        ),
                        onPressed: () => setState(() => _isObscured = !_isObscured),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              errorStyle: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFFE8A0A0),
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
