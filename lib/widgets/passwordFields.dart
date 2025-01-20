import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PasswordFieldWithEyeToggle extends StatefulWidget {
  final TextEditingController controller; 
  final String labelText; 

 
  const PasswordFieldWithEyeToggle({
    Key? key,
    required this.controller,
    required this.labelText,
  }) : super(key: key);

  @override
  _PasswordFieldWithEyeToggleState createState() =>
      _PasswordFieldWithEyeToggleState();
}

class _PasswordFieldWithEyeToggleState extends State<PasswordFieldWithEyeToggle> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      height: 37,
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText, 
        decoration: InputDecoration(
          labelText: widget.labelText, 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility, 
              size: 13,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText; 
              });
            },
          ),
        ),
      ),
    );
  }
}
