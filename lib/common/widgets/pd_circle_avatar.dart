import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../palette.dart';

class PDCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const PDCircleAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Palette.lightGray,
          width: 1,
        ),
        image: DecorationImage(
          image: imageUrl == null
              ? const ExtendedAssetImageProvider('assets/icons/profile.png')
              : ExtendedNetworkImageProvider(imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
