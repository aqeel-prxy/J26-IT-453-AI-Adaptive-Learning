import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.65),
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

/// In-browser Live Camera Viewfinder
/// Can be embedded inline directly inside a page/card or within a modal dialog.
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
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  String? _viewType;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCapturing = false;
  bool _isDisposed = false;
  static int _instanceCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _startCamera();
      }
    });
  }

  Future<void> _startCamera() async {
    if (!mounted || _isDisposed) return;
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        if (mounted && !_isDisposed) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Camera hardware access is not supported in this browser.';
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
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
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

      // Check if disposed while waiting for user to click "Allow"
      if (_isDisposed) {
        for (final track in stream.getTracks()) {
          try {
            track.stop();
          } catch (_) {}
        }
        return;
      }

      _mediaStream = stream;

      final viewId = 'math-camera-view-${DateTime.now().millisecondsSinceEpoch}-${_instanceCounter++}-${math.Random().nextInt(9999)}';
      _viewType = viewId;

      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..setAttribute('autoplay', 'true')
        ..setAttribute('muted', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.backgroundColor = '#000000'
        ..style.border = 'none'
        ..style.pointerEvents = 'none';

      _videoElement!.srcObject = stream;

      // Play video reliably on metadata
      _videoElement!.onLoadedMetadata.listen((_) {
        _videoElement?.play().catchError((_) {});
      });
      _videoElement!.play().catchError((_) {});

      // Register platform view for web rendering
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
        (int id) {
          final div = html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.backgroundColor = '#000000'
            ..style.overflow = 'hidden'
            ..style.pointerEvents = 'none';
          div.append(_videoElement!);
          return div;
        },
      );

      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Could not access camera preview. Please check camera connection and allow camera access in browser permissions.';
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
      try {
        _videoElement!.pause();
        _videoElement!.srcObject = null;
      } catch (_) {}
      _videoElement = null;
    }
  }

  /// Public method callable via GlobalKey<CameraViewfinderState>
  Future<void> captureFrame() => _captureFrame();

  Future<void> _captureFrame() async {
    if (_videoElement == null || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final vWidth = _videoElement!.videoWidth > 0 ? _videoElement!.videoWidth : 1280;
      final vHeight = _videoElement!.videoHeight > 0 ? _videoElement!.videoHeight : 720;

      final canvas = html.CanvasElement(width: vWidth, height: vHeight);
      canvas.context2D.drawImage(_videoElement!, 0, 0);

      final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
      final commaIdx = dataUrl.indexOf(',');
      final base64Data = commaIdx != -1 ? dataUrl.substring(commaIdx + 1) : dataUrl;
      final bytes = base64Decode(base64Data);

      _stopCamera();

      final pickedImage = PickedImageData(
        fileName: 'question_camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
        bytes: bytes,
        dataUrl: dataUrl,
      );

      widget.onImageCaptured(pickedImage);
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
    if (picked != null) {
      widget.onImageCaptured(picked);
    } else {
      widget.onCancel();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return _buildViewfinder(context);
    } catch (e) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 28),
            const SizedBox(height: 6),
            Text(
              'Camera Preview Error',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF991B1B),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$e',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: const Color(0xFFB91C1C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _startCamera,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildViewfinder(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFEF4444), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'LIVE CAMERA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFCA5A5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Position equation in viewfinder',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                if (!_isLoading && _errorMessage == null) ...[
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF60A5FA), size: 20),
                    onPressed: _isCapturing ? null : _captureFrame,
                    tooltip: 'Snap Photo Now',
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 6),
                ],
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                  onPressed: () {
                    _stopCamera();
                    widget.onCancel();
                  },
                  tooltip: 'Close Camera',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Viewfinder Viewport
          SizedBox(
            width: double.infinity,
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                // Base background container to guarantee non-positioned size anchor
                Container(
                  width: double.infinity,
                  height: widget.height,
                  color: const Color(0xFF0F172A),
                ),

                // 1. Live Video Stream View
                if (!_isLoading && _errorMessage == null && _viewType != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: SizedBox.expand(
                        child: HtmlElementView(
                          key: ValueKey(_viewType),
                          viewType: _viewType!,
                        ),
                      ),
                    ),
                  ),

                // 2. Loading State
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF0F172A),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF818CF8), strokeWidth: 2.8),
                            const SizedBox(height: 14),
                            Text(
                              'Opening camera preview...',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFF1F5F9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please ensure browser camera permission is allowed',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 3. Error State
                if (_errorMessage != null)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF0F172A),
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videocam_off_rounded, color: Color(0xFFF59E0B), size: 42),
                            const SizedBox(height: 10),
                            Text(
                              'Camera Preview Unavailable',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFCBD5E1),
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _startCamera,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4338CA),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: _chooseFileInstead,
                                  icon: const Icon(Icons.upload_file, size: 16),
                                  label: const Text('Upload File Instead'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFCBD5E1),
                                    side: const BorderSide(color: Color(0xFF475569)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 4. Mathematical Framing Reticle Overlay
                if (!_isLoading && _errorMessage == null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Top-Left corner
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF60A5FA), width: 3.5),
                                    left: BorderSide(color: Color(0xFF60A5FA), width: 3.5),
                                  ),
                                ),
                              ),
                            ),
                            // Top-Right corner
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF60A5FA), width: 3.5),
                                    right: BorderSide(color: Color(0xFF60A5FA), width: 3.5),
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-Left corner
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF60A5FA), width: 3.5),
                                    left: BorderSide(color: Color(0xFF60A5FA), width: 3.5),
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-Right corner
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF60A5FA), width: 3.5),
                                    right: BorderSide(color: Color(0xFF60A5FA), width: 3.5),
                                  ),
                                ),
                              ),
                            ),
                            // Center Guidance Pill
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  'Focus mathematical question inside frame',
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

                // 5. Floating Shutter Button directly inside viewport for high visibility
                if (!_isLoading && _errorMessage == null && !_isCapturing)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _captureFrame,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              const SizedBox(width: 7),
                              Text(
                                'Capture Question',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // 6. Capturing Overlay
                if (_isCapturing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            const SizedBox(height: 12),
                            Text(
                              'Snapping high-res photo frame...',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Control Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _chooseFileInstead,
                  icon: const Icon(Icons.file_upload_outlined, size: 16),
                  label: const Text('Upload File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCBD5E1),
                    side: const BorderSide(color: Color(0xFF475569)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),
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
                        : const Icon(Icons.camera_alt_rounded, size: 18),
                    label: Text(
                      _isCapturing ? 'Reading Image...' : 'Snap Question Photo',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF94A3B8), size: 20),
                  onPressed: _startCamera,
                  tooltip: 'Restart camera stream',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal Dialog wrapper around CameraViewfinder
class CameraCaptureModal extends StatelessWidget {
  const CameraCaptureModal({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 620 ? 560.0 : screenSize.width * 0.94;
    final viewfinderHeight = screenSize.height < 650 ? 250.0 : 310.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxWidth: 580),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: CameraViewfinder(
          isInline: false,
          height: viewfinderHeight,
          onImageCaptured: (image) {
            Navigator.of(context).pop(image);
          },
          onCancel: () {
            Navigator.of(context).pop(null);
          },
        ),
      ),
    );
  }
}
