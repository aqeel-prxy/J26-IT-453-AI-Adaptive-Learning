import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PickedImageData {
  final String fileName;
  final Uint8List bytes;
  final String? dataUrl;

  PickedImageData({
    required this.fileName,
    required this.bytes,
    this.dataUrl,
  });

  String get base64String => base64Encode(bytes);
}

Future<PickedImageData?> pickImageFromDevice() async {
  return null;
}

Future<PickedImageData?> pickImageFromGallery() async {
  return null;
}

Future<PickedImageData?> takePhotoFromCamera(BuildContext context) async {
  return null;
}
