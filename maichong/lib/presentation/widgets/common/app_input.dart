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
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
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
        TextField(
          controller: _controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            errorText: widget.errorText,
            suffixIcon: widget.suffixIcon,
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
