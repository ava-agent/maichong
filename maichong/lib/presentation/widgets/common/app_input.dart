import 'package:flutter/material.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool isRequired;
  final String? errorText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const AppInput({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.obscureText = false,
    this.isRequired = false,
    this.errorText,
    this.keyboardType,
    this.suffixIcon,
    this.controller,
    this.validator,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late TextEditingController _controller;
  bool _isExternalController = false;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    if (!_isExternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label! + (widget.isRequired ? ' *' : ''),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            errorText: widget.errorText,
            suffixIcon: widget.suffixIcon,
          ),
          onChanged: widget.onChanged,
          validator: widget.validator,
        ),
      ],
    );
  }
}
