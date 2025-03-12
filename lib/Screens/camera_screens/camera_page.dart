import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../results/denimjean_result.dart';
import '../results/sweatshirt_result.dart';
import 'detector_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage(
      {super.key,
      required this.type,
      required this.actualSize,
      required this.selectedSize});
  final String type;
  final Map<String, double?> actualSize;
  final String selectedSize;
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Detector? _detector;
  StreamSubscription? _subscription;
  List<List<Map<String, double>>> _contours = [];
  List<Map<String, double>> _measurments = [];
  final ScreenshotController _screenshotController = ScreenshotController();
  String path = '';

  _cameraStream() async {
    Detector.start().then((instance) {
      _detector = instance;
      _subscription = instance.resultsStream.stream.listen((values) {
        if (values['contours'] != null) {
          setState(() {
            _contours = values['contours'];
            _measurments = values['measurments'];
          });
        }
      });
    });
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller!.initialize();
    _controller!.startImageStream(onLatestImageAvailable);

    setState(() {});
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame({'image': cameraImage, 'type': widget.type});
  }

  Future<void> _getSavePath() async {
    final directory = await getApplicationDocumentsDirectory();
    path = directory.path;
  }

  @override
  void initState() {
    super.initState();
    _cameraStream();
    _getSavePath();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
    _detector!.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contour Detection")),
      body: Center(
        child: _controller == null
            ? Text("Loading")
            : Column(
                children: [
                  Expanded(
                    child: Screenshot(
                      controller: _screenshotController,
                      child: Stack(
                        children: [
                          CameraPreview(_controller!),
                          if (_controller != null &&
                              _controller!.value.isInitialized)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return CustomPaint(
                                  size: _controller!.value.previewSize!,
                                  painter: ContourPainter(
                                    _contours,
                                    Size(
                                        MediaQuery.of(context).size.width,
                                        MediaQuery.of(context).size.width *
                                            _controller!.value.aspectRatio),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  _measurments.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_measurments.first.toString()),
                        )
                      : const SizedBox(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _screenshotController
              .captureAndSave(path, fileName: 'image.png')
              .then((savePath) {
            if (savePath != null && path.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.type == 'sweat'
                      ? SweatshirtMeasurementResult(
                          actualSize: _measurments.first,
                          selectedSize: widget.selectedSize,
                          capturedImagePath: savePath,
                        )
                      : DenimJeanMeasurementResult(
                          actualSizes: _measurments.first,
                          selectedSize: widget.selectedSize,
                          capturedImagePath: savePath,
                        ),
                ),
              );
            }
          });
        },
        child: const Icon(
          Icons.camera,
        ),
      ),
    );
  }
}

class ContourPainter extends CustomPainter {
  final List<List<Map<String, double>>> contours;

  final Size canvasSize;

  ContourPainter(this.contours, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (contours.isNotEmpty) {
      for (int j = 0; j < contours.length; j++) {
        var contour = contours[j];
        Path path = Path();
        if (contour.isNotEmpty) {
          // Scale and move the first point

          path.moveTo(
            contour[0]['x']! * canvasSize.height,
            contour[0]['y']! * canvasSize.width,
          );

          // Scale and move remaining points
          for (int i = 1; i < contour.length; i++) {
            path.lineTo(
              contour[i]['x']! * canvasSize.height,
              contour[i]['y']! * canvasSize.width,
            );
          }

          path.close();
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
