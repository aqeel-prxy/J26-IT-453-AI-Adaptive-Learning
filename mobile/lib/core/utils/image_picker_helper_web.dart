// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
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
  return pickImageFromGallery();
}

Future<PickedImageData?> pickImageFromGallery() async {
  return _pickFile(useCamera: false);
}

Future<PickedImageData?> takePhotoFromCamera(BuildContext context) async {
  return _openDomCameraModal();
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

/// Fully functional, reliable in-browser Camera Modal Dialog
/// Renders directly to the browser DOM to completely avoid Flutter Web CanvasKit
/// PlatformViewRenderBox layout and MouseTracker assertion crashes.
Future<PickedImageData?> _openDomCameraModal() async {
  final completer = Completer<PickedImageData?>();

  final backdrop = html.DivElement()
    ..id = 'dom-camera-modal-backdrop'
    ..style.position = 'fixed'
    ..style.top = '0'
    ..style.left = '0'
    ..style.right = '0'
    ..style.bottom = '0'
    ..style.backgroundColor = 'rgba(15, 23, 42, 0.82)'
    ..style.setProperty('backdrop-filter', 'blur(8px)')
    ..style.setProperty('-webkit-backdrop-filter', 'blur(8px)')
    ..style.zIndex = '999999'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.padding = '16px'
    ..style.boxSizing = 'border-box'
    ..style.fontFamily = 'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';

  final modal = html.DivElement()
    ..id = 'dom-camera-modal'
    ..style.width = '100%'
    ..style.maxWidth = '520px'
    ..style.maxHeight = '92vh'
    ..style.backgroundColor = '#0F172A'
    ..style.borderRadius = '16px'
    ..style.boxShadow = '0 25px 50px -12px rgba(0, 0, 0, 0.7)'
    ..style.border = '1.5px solid #334155'
    ..style.overflow = 'hidden'
    ..style.display = 'flex'
    ..style.flexDirection = 'column';

  // 1. Header
  final header = html.DivElement()
    ..style.padding = '12px 18px'
    ..style.backgroundColor = '#1E293B'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'space-between'
    ..style.borderBottom = '1px solid #334155';

  final headerTitle = html.DivElement()
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.gap = '10px'
    ..setInnerHtml(
      '<span style="background: rgba(220, 38, 38, 0.2); border: 1px solid #EF4444; color: #FCA5A5; font-size: 11px; font-weight: 800; padding: 3px 8px; border-radius: 6px; letter-spacing: 0.5px; display: inline-flex; align-items: center; gap: 5px;">'
      '<span style="width: 7px; height: 7px; background: #EF4444; border-radius: 50%; display: inline-block;"></span> LIVE CAMERA'
      '</span>'
      '<span style="color: #F1F5F9; font-weight: 700; font-size: 14px;">Mathematics Equation Capture</span>',
      treeSanitizer: html.NodeTreeSanitizer.trusted,
    );

  final closeBtn = html.ButtonElement()
    ..id = 'dom-cam-close-btn'
    ..text = '✕'
    ..style.background = 'transparent'
    ..style.border = 'none'
    ..style.color = '#94A3B8'
    ..style.fontSize = '18px'
    ..style.fontWeight = 'bold'
    ..style.cursor = 'pointer'
    ..style.padding = '4px 8px'
    ..style.borderRadius = '6px';

  closeBtn.onMouseEnter.listen((_) => closeBtn.style.color = '#FFFFFF');
  closeBtn.onMouseLeave.listen((_) => closeBtn.style.color = '#94A3B8');

  header.append(headerTitle);
  header.append(closeBtn);

  // 2. Viewport
  final viewport = html.DivElement()
    ..style.position = 'relative'
    ..style.width = '100%'
    ..style.height = '300px'
    ..style.maxHeight = '48vh'
    ..style.backgroundColor = '#0B0F19'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.overflow = 'hidden';

  final video = html.VideoElement()
    ..id = 'dom-camera-video'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.objectFit = 'cover'
    ..style.display = 'none'
    ..autoplay = true
    ..muted = true
    ..setAttribute('playsinline', 'true');

  viewport.append(video);

  // Loading indicator div
  final loadingDiv = html.DivElement()
    ..id = 'dom-camera-loading'
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.padding = '20px'
    ..style.textAlign = 'center'
    ..setInnerHtml(
      '<div style="width: 36px; height: 36px; border: 3px solid rgba(129, 140, 248, 0.2); border-top-color: #818CF8; border-radius: 50%; animation: spin 0.8s linear infinite;"></div>'
      '<style>@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }</style>'
      '<p style="color: #FFFFFF; font-weight: 600; font-size: 13.5px; margin: 14px 0 4px 0;">Starting webcam preview...</p>'
      '<p style="color: #94A3B8; font-size: 11.5px; margin: 0;">Please grant camera permission in your browser prompt</p>',
      treeSanitizer: html.NodeTreeSanitizer.trusted,
    );
  viewport.append(loadingDiv);

  // Error container div (hidden initially)
  final errorDiv = html.DivElement()
    ..id = 'dom-camera-error'
    ..style.display = 'none'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.padding = '24px'
    ..style.textAlign = 'center'
    ..style.backgroundColor = '#0F172A'
    ..style.position = 'absolute'
    ..style.top = '0'
    ..style.left = '0'
    ..style.right = '0'
    ..style.bottom = '0'
    ..style.zIndex = '10';
  viewport.append(errorDiv);

  // Framing guide overlay (shown when video is active)
  final overlay = html.DivElement()
    ..id = 'dom-camera-framing-guide'
    ..style.position = 'absolute'
    ..style.top = '16px'
    ..style.left = '16px'
    ..style.right = '16px'
    ..style.bottom = '16px'
    ..style.border = '1.5px dashed rgba(255, 255, 255, 0.4)'
    ..style.borderRadius = '10px'
    ..style.pointerEvents = 'none'
    ..style.display = 'none'
    ..style.alignItems = 'flex-end'
    ..style.justifyContent = 'center'
    ..style.paddingBottom = '10px'
    ..setInnerHtml(
      '<div style="background: rgba(0,0,0,0.72); color: #FFFFFF; font-size: 11.5px; font-weight: 600; padding: 4px 12px; border-radius: 6px; letter-spacing: 0.2px;">'
      'Align mathematical equation inside frame'
      '</div>',
      treeSanitizer: html.NodeTreeSanitizer.trusted,
    );
  viewport.append(overlay);

  // 3. Toolbar
  final toolbar = html.DivElement()
    ..style.padding = '12px 18px'
    ..style.backgroundColor = '#1E293B'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.gap = '12px'
    ..style.borderTop = '1px solid #334155';

  final cancelBtn = html.ButtonElement()
    ..id = 'dom-cam-cancel-btn'
    ..innerText = 'Cancel'
    ..style.background = 'transparent'
    ..style.border = '1px solid #475569'
    ..style.color = '#CBD5E1'
    ..style.padding = '10px 16px'
    ..style.borderRadius = '10px'
    ..style.cursor = 'pointer'
    ..style.fontWeight = '600'
    ..style.fontSize = '13px';

  final snapBtn = html.ButtonElement()
    ..id = 'dom-cam-snap-btn'
    ..innerText = '📸  Snap Question Photo'
    ..style.flex = '1'
    ..style.background = 'linear-gradient(135deg, #2563EB, #4338CA)'
    ..style.border = 'none'
    ..style.color = '#FFFFFF'
    ..style.padding = '11px 18px'
    ..style.borderRadius = '10px'
    ..style.cursor = 'pointer'
    ..style.fontWeight = '700'
    ..style.fontSize = '13.5px'
    ..style.boxShadow = '0 4px 12px rgba(37, 99, 235, 0.35)'
    ..disabled = true;

  toolbar.append(cancelBtn);
  toolbar.append(snapBtn);

  modal.append(header);
  modal.append(viewport);
  modal.append(toolbar);
  backdrop.append(modal);
  html.document.body!.append(backdrop);

  html.MediaStream? stream;

  void cleanup() {
    if (stream != null) {
      for (final track in stream!.getTracks()) {
        try {
          track.stop();
        } catch (_) {}
      }
      stream = null;
    }
    video.pause();
    video.srcObject = null;
    backdrop.remove();
  }

  // Backdrop click dismisses modal safely
  backdrop.onClick.listen((e) {
    if (e.target == backdrop) {
      cleanup();
      if (!completer.isCompleted) completer.complete(null);
    }
  });

  closeBtn.onClick.listen((_) {
    cleanup();
    if (!completer.isCompleted) completer.complete(null);
  });

  cancelBtn.onClick.listen((_) {
    cleanup();
    if (!completer.isCompleted) completer.complete(null);
  });

  snapBtn.onClick.listen((_) {
    try {
      if (video.videoWidth == 0 || video.videoHeight == 0) {
        snapBtn.innerText = '⚠️ Video frame not ready - Retry';
        Future.delayed(const Duration(seconds: 2), () {
          if (!completer.isCompleted) {
            snapBtn.innerText = '📸  Snap Question Photo';
            snapBtn.disabled = false;
          }
        });
        return;
      }

      snapBtn.innerText = 'Capturing frame...';
      snapBtn.disabled = true;

      final w = video.videoWidth > 0 ? video.videoWidth : 1280;
      final h = video.videoHeight > 0 ? video.videoHeight : 720;
      final canvas = html.CanvasElement(width: w, height: h);
      canvas.context2D.drawImage(video, 0, 0);
      final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
      final comma = dataUrl.indexOf(',');
      final b64 = comma != -1 ? dataUrl.substring(comma + 1) : dataUrl;
      final bytes = base64Decode(b64);

      cleanup();

      if (!completer.isCompleted) {
        completer.complete(PickedImageData(
          fileName: 'question_camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
          bytes: bytes,
          dataUrl: dataUrl,
        ));
      }
    } catch (e) {
      // Keep modal open and report error so student can retry
      snapBtn.innerText = '📸  Snap Question Photo';
      snapBtn.disabled = false;
      overlay.style.display = 'flex';
      overlay.setInnerHtml(
        '<div style="background: rgba(220, 38, 38, 0.9); color: #FFFFFF; font-size: 12px; font-weight: 600; padding: 6px 14px; border-radius: 6px;">'
        'Could not capture photo frame ($e). Please try again.'
        '</div>',
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
    }
  });

  Future<void> initCamera() async {
    loadingDiv.style.display = 'flex';
    errorDiv.style.display = 'none';
    video.style.display = 'none';
    overlay.style.display = 'none';
    snapBtn.disabled = true;

    // Release any previous tracks before reinitializing
    if (stream != null) {
      for (final track in stream!.getTracks()) {
        try {
          track.stop();
        } catch (_) {}
      }
      stream = null;
    }

    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        throw Exception('Camera API is not supported in this browser.');
      }

      try {
        stream = await mediaDevices.getUserMedia({
          'video': {
            'facingMode': {'ideal': 'environment'},
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': false,
        });
      } catch (_) {
        stream = await mediaDevices.getUserMedia({'video': true, 'audio': false});
      }

      video.srcObject = stream;
      await video.play();

      loadingDiv.style.display = 'none';
      video.style.display = 'block';
      overlay.style.display = 'flex';
      snapBtn.disabled = false;
    } catch (e) {
      loadingDiv.style.display = 'none';
      errorDiv.style.display = 'flex';

      String title = 'Camera Feed Unavailable';
      String desc = 'Could not start camera feed ($e).';
      final errStr = e.toString().toLowerCase();

      if (errStr.contains('notallowederror') || errStr.contains('permission')) {
        title = 'Camera Permission Required';
        desc = 'Please click the camera/lock icon in your browser address bar to allow camera access, then click "Retry Camera".';
      } else if (errStr.contains('notfounderror') || errStr.contains('devicesnotfound')) {
        title = 'No Camera Device Detected';
        desc = 'No working webcam was found on your device. You can connect a camera or upload a question image file instead.';
      } else if (errStr.contains('notreadableerror') || errStr.contains('trackstart')) {
        title = 'Camera Locked by Another App';
        desc = 'Your camera is currently in use by another application. Please close other camera apps and click "Retry Camera".';
      }

      errorDiv.setInnerHtml(
        '<div style="font-size: 36px; margin-bottom: 8px;">📷🚫</div>'
        '<h3 style="color: #F8FAFC; font-size: 16px; font-weight: 700; margin: 0 0 6px 0;">$title</h3>'
        '<p style="color: #CBD5E1; font-size: 12px; line-height: 1.45; margin: 0 0 16px 0; max-width: 420px;">$desc</p>'
        '<div style="display: flex; gap: 10px; justify-content: center;">'
        '<button id="dom-cam-retry-btn" style="background: #4338CA; color: #FFFFFF; border: none; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer;">Retry Camera</button>'
        '<button id="dom-cam-upload-btn" style="background: transparent; color: #CBD5E1; border: 1px solid #475569; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer;">Upload Photo Instead</button>'
        '</div>',
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );

      final retryBtn = errorDiv.querySelector('#dom-cam-retry-btn');
      retryBtn?.onClick.listen((_) => initCamera());

      final uploadBtn = errorDiv.querySelector('#dom-cam-upload-btn');
      uploadBtn?.onClick.listen((_) async {
        cleanup();
        final picked = await pickImageFromGallery();
        if (!completer.isCompleted) completer.complete(picked);
      });
    }
  }

  await initCamera();
  return completer.future;
}

/// Fallback modal widget definition for test and component compatibility
class CameraCaptureModal extends StatelessWidget {
  const CameraCaptureModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const SizedBox(
        width: 400,
        height: 250,
        child: Center(
          child: Text(
            'Camera Viewfinder',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class CameraViewfinder extends StatefulWidget {
  final ValueChanged<PickedImageData> onImageCaptured;
  final VoidCallback onCancel;
  final double height;
  final double dialogWidth;
  final bool isInline;

  const CameraViewfinder({
    super.key,
    required this.onImageCaptured,
    required this.onCancel,
    this.height = 320,
    this.dialogWidth = 520,
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
      width: widget.dialogWidth,
      height: widget.height,
      color: const Color(0xFF0F172A),
      child: const Center(
        child: Text('Camera Viewfinder', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
