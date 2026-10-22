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

class CameraViewfinder extends StatefulWidget {
  final ValueChanged<PickedImageData> onImageCaptured;
  final VoidCallback onCancel;
  final double height;
  final bool isInline;

  const CameraViewfinder({
    super.key,
    required this.onImageCaptured,
    required this.onCancel,
    this.height = 320,
    this.isInline = false,
  });

  @override
  State<CameraViewfinder> createState() => CameraViewfinderState();
}

class CameraViewfinderState extends State<CameraViewfinder> {
  void captureFrame() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Camera viewfinder is not supported on this platform.'),
    );
  }
}
