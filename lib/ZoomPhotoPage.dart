// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ZoomPhotoPage extends StatelessWidget {
  final String imageUrl;

  // ignore: use_super_parameters
  const ZoomPhotoPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'photoZoomHero', // Même tag que dans la photo ronde
              child: InteractiveViewer(
                // permet zoom/pinch
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
