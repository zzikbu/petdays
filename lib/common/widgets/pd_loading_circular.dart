import 'package:flutter/material.dart';

import '../../palette.dart';

class PDLoadingCircular extends StatelessWidget {
  const PDLoadingCircular({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Palette.subGreen),
    );
  }
}
