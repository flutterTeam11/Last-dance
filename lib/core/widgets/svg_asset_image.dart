import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SvgAssetImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SvgAssetImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _loadEmbeddedImageBytes(path),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return const SizedBox.shrink();

        return Image.memory(bytes, width: width, height: height, fit: fit);
      },
    );
  }
}

Future<Uint8List?> _loadEmbeddedImageBytes(String path) async {
  final svgString = await rootBundle.loadString(path);
  final regExp = RegExp(r'data:image/(?:jpeg|png);base64,([A-Za-z0-9+/=]+)');
  final match = regExp.firstMatch(svgString);
  if (match == null) return null;

  return base64Decode(match.group(1)!);
}
