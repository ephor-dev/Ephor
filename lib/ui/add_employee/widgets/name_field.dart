import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NameField extends StatelessWidget {
  const NameField({
    super.key, 
    required this.label, required this.controller, required this.decoration,
    required this.placeholder, this.isRequired = false, this.isOptional = false,
    this.isEmail = false
  });

  final String label;
  final TextEditingController controller;
  final InputDecoration decoration;
  final String placeholder;
  final bool isRequired;
  final bool isOptional;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label, 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600, 
                color: Theme.of(context).colorScheme.onSurface.withAlpha(222), 
                letterSpacing: 0.5
              )
            ),
            if (isRequired)
              Padding(
                padding: EdgeInsets.only(left: 4), 
                child: Text(
                  '*', 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, 
                    fontWeight: FontWeight.w600, 
                    fontSize: 16
                  )
                )
              ),
            if (isOptional)
              Padding(
                padding: const EdgeInsets.only(left: 4), 
                child: Text('(OPTIONAL)', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400, 
                  color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade600
                    : Colors.grey.shade400, 
                  letterSpacing: 0.3, fontSize: 14
                )
              )
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontWeight: FontWeight.w300, 
            color: Theme.of(context).colorScheme.onSurface
          ),
          decoration: decoration.copyWith(hintText: placeholder),
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          inputFormatters: <TextInputFormatter>[
            isEmail
              ? FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9ñÑ@.\-_]"))
              : FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZñÑ.\- ]")),
          ],
        ),
      ],
    );
  }
}