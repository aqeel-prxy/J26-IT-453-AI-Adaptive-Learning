typedef FilePickedCallback = void Function(String content, String fileName, int size);
typedef DragStateCallback = void Function(bool isDragging);

void initWebDropZone(DragStateCallback onDragState, FilePickedCallback onFile) {
  // No-op on mobile / desktop; desktop_drop is used instead
}

void disposeWebDropZone() {
  // No-op on mobile / desktop
}

Future<void> pickFileCrossPlatform(FilePickedCallback onFile) async {
  // No-op on mobile / desktop; FilePicker is used instead
}
