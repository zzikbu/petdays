import 'package:flutter/material.dart';

import '../palette.dart';

class PDRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PDRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Palette.subGreen,
      backgroundColor: Palette.white,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
