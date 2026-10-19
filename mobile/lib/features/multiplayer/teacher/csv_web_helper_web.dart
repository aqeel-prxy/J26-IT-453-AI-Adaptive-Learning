// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

typedef FilePickedCallback = void Function(String content, String fileName, int size);
typedef DragStateCallback = void Function(bool isDragging);

StreamSubscription? _dragOverSub;
StreamSubscription? _dragLeaveSub;
StreamSubscription? _dropSub;

void initWebDropZone(DragStateCallback onDragState, FilePickedCallback onFile) {
  _dragOverSub?.cancel();
  _dragLeaveSub?.cancel();
  _dropSub?.cancel();

  _dragOverSub = html.window.onDragOver.listen((e) {
    e.preventDefault();
    onDragState(true);
  });

  _dragLeaveSub = html.window.onDragLeave.listen((e) {
    e.preventDefault();
    onDragState(false);
  });

  _dropSub = html.window.onDrop.listen((e) {
    e.preventDefault();
    onDragState(false);
    final dt = e.dataTransfer;
    if (dt.files != null && dt.files!.isNotEmpty) {
      final file = dt.files![0];
      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final content = reader.result as String? ?? '';
        onFile(content, file.name, file.size);
      });
      reader.readAsText(file);
    }
  });
}

void disposeWebDropZone() {
  _dragOverSub?.cancel();
  _dragLeaveSub?.cancel();
  _dropSub?.cancel();
}

Future<void> pickFileCrossPlatform(FilePickedCallback onFile) async {
  final uploadInput = html.FileUploadInputElement()
    ..accept = '.csv,.txt'
    ..multiple = false;
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.onLoadEnd.listen((_) {
        final content = reader.result as String? ?? '';
        onFile(content, file.name, file.size);
      });
      reader.readAsText(file);
    }
  });
}
