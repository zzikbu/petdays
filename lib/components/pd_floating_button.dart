import 'package:flutter/material.dart';

import '../palette.dart';

class PDFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const PDFloatingButton({
    super.key,
    this.icon = Icons.edit,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Palette.darkGray,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: Icon(icon, color: Palette.white),
    );
  }
}
