import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplayWidget extends StatelessWidget {
  final File? mediaFile;

  const ImageDisplayWidget({super.key, this.mediaFile});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          image: mediaFile != null
              ? DecorationImage(
                  image: FileImage(mediaFile!), fit: BoxFit.cover)
              : null,
        ),
        child: mediaFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text("No image selected",
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              )
            : null,
      ),
    );
  }
}
