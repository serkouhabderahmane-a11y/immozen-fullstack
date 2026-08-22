import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart'; // ← NEW package
import 'package:immozen/utils/Extensions/extensions.dart';

class PanaromaImageScreen extends StatelessWidget {
  const PanaromaImageScreen({
    required this.imageUrl,
    super.key,
    this.isFileImage,
  });

  final String imageUrl;
  final bool? isFileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: context.color.tertiaryColor),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PanoramaViewer(
          animSpeed: 1.0,
          child: (isFileImage ?? false)
              ? Image.file(File(imageUrl))
              : Image.network(imageUrl),
        ),
      ),
    );
  }
}
