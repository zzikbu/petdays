import 'package:flutter/material.dart';

import '../palette.dart';

class PDAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final Widget? leading;
  final Widget? titleWidget;
  final String? titleText;
  final List<Widget>? actions;

  const PDAppBar({
    super.key,
    this.backgroundColor = Palette.background,
    this.leading,
    this.titleWidget,
    this.titleText,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor,
      leading: leading,
      title: titleWidget ??
          (titleText != null
              ? Text(
                  titleText!,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
