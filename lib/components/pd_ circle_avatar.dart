import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../palette.dart';

class PDCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const PDCircleAvatar({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
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
