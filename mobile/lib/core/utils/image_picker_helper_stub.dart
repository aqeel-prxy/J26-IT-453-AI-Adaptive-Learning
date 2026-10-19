import 'dart:typed_data';

class PickedImageData {
  final String fileName;
  final Uint8List bytes;
  final String? dataUrl;

  PickedImageData({
    required this.fileName,
    required this.bytes,
    this.dataUrl,
  });
}

Future<PickedImageData?> pickImageFromDevice() async {
  return null;
}
