import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
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

  String get base64String => base64Encode(bytes);
}

Future<PickedImageData?> pickImageFromDevice() async {
  return pickImageFromGallery();
}

Future<PickedImageData?> pickImageFromGallery() async {
  return _pickFile(useCamera: false);
}

Future<PickedImageData?> takePhotoFromCamera() async {
  return _pickFile(useCamera: true);
}

Future<PickedImageData?> _pickFile({required bool useCamera}) async {
  final completer = Completer<PickedImageData?>();
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  
  if (useCamera) {
    uploadInput.setAttribute('capture', 'environment');
  }

  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete(PickedImageData(fileName: file.name, bytes: result));
        } else if (result is List<int>) {
          completer.complete(PickedImageData(
            fileName: file.name,
            bytes: Uint8List.fromList(result),
          ));
        } else {
          completer.complete(null);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
