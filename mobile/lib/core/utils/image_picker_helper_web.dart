import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

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
  return showDialog<PickedImageData?>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const CameraCaptureModal(),
  );
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

/// In-browser Live Camera Viewfinder & Frame Capture Modal
class CameraCaptureModal extends StatefulWidget {
  const CameraCaptureModal({super.key});

  @override
  State<CameraCaptureModal> createState() => _CameraCaptureModalState();
}

class _CameraCaptureModalState extends State<CameraCaptureModal> {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  late final String _viewType;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'camera-view-${DateTime.now().microsecondsSinceEpoch}';
    _startCamera();
  }

  Future<void> _startCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Camera access is not supported in this browser.';
          });
        }
        return;
      }

      html.MediaStream? stream;

      // 1. Try mobile-friendly rear camera first
      try {
        stream = await mediaDevices.getUserMedia({
          'video': {
            'facingMode': {'ideal': 'environment'},
            'width': {'ideal': 1280},
            'height': {'ideal': 720},
          },
          'audio': false,
        });
      } catch (_) {
        // 2. Fall back to standard webcam or any active video device
        stream = await mediaDevices.getUserMedia({
          'video': true,
          'audio': false,
        });
      }

      _mediaStream = stream;

      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      _videoElement!.srcObject = stream;
      try {
        await _videoElement!.play();
      } catch (_) {}

      // Register platform view for web rendering
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => _videoElement!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Could not open device camera. Please make sure your camera is connected and browser permission is allowed.';
        });
      }
    }
  }

  void _stopCamera() {
    if (_mediaStream != null) {
      for (final track in _mediaStream!.getTracks()) {
        try {
          track.stop();
        } catch (_) {}
      }
      _mediaStream = null;
    }
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
      _videoElement = null;
    }
  }

  Future<void> _captureFrame() async {
    if (_videoElement == null || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final vWidth = _videoElement!.videoWidth;
      final vHeight = _videoElement!.videoHeight;
      final width = vWidth > 0 ? vWidth : 1280;
      final height = vHeight > 0 ? vHeight : 720;

      final canvas = html.CanvasElement(width: width, height: height);
      canvas.context2D.drawImage(_videoElement!, 0, 0);

      final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
      final commaIdx = dataUrl.indexOf(',');
      final base64Data = commaIdx != -1 ? dataUrl.substring(commaIdx + 1) : dataUrl;
      final bytes = base64Decode(base64Data);

      _stopCamera();

      if (mounted) {
        Navigator.of(context).pop(
          PickedImageData(
            fileName: 'camera_question_${DateTime.now().millisecondsSinceEpoch}.jpg',
            bytes: bytes,
            dataUrl: dataUrl,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _errorMessage = 'Failed to capture photo frame ($e).';
        });
      }
    }
  }

  Future<void> _chooseFileInstead() async {
    _stopCamera();
    final picked = await pickImageFromGallery();
    if (mounted) {
      Navigator.of(context).pop(picked);
    }
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 600 ? 560.0 : screenSize.width * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4338CA), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture Question Camera',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Point your camera at the math problem and snap',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cancel',
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // Viewfinder Viewport
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 320,
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // Video Stream View
                      if (!_isLoading && _errorMessage == null)
                        Positioned.fill(
                          child: HtmlElementView(viewType: _viewType),
                        ),

                      // Loading State
                      if (_isLoading)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: 14),
                              Text(
                                'Starting device camera...',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Error State
                      if (_errorMessage != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.videocam_off_outlined, color: Color(0xFFF59E0B), size: 44),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _chooseFileInstead,
                                  icon: const Icon(Icons.upload_file, size: 18),
                                  label: const Text('Choose Photo from Files'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Viewfinder Overlay Reticle
                      if (!_isLoading && _errorMessage == null) ...[
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  // Top corner brackets
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF60A5FA), width: 3.5), left: BorderSide(color: Color(0xFF60A5FA), width: 3.5)))),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF60A5FA), width: 3.5), right: BorderSide(color: Color(0xFF60A5FA), width: 3.5)))),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF60A5FA), width: 3.5), left: BorderSide(color: Color(0xFF60A5FA), width: 3.5)))),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF60A5FA), width: 3.5), right: BorderSide(color: Color(0xFF60A5FA), width: 3.5)))),
                                  ),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Place question inside frame',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Controls Toolbar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _chooseFileInstead,
                    icon: const Icon(Icons.file_upload_outlined, size: 16),
                    label: const Text('Upload File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_isLoading || _errorMessage != null || _isCapturing)
                          ? null
                          : _captureFrame,
                      icon: _isCapturing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.camera, size: 20),
                      label: Text(
                        _isCapturing ? 'Capturing...' : 'Capture Question',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4338CA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
