import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:measuremate/Screens/results/denimjean_result.dart';

class DenimJeanCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Map<String, double> actualSize;
  final String selectedSize;

  const DenimJeanCameraScreen({
    super.key,
    required this.cameras,
    required this.actualSize,
    required this.selectedSize,
  });

  @override
  _DenimJeanCameraScreenState createState() => _DenimJeanCameraScreenState();
}

class _DenimJeanCameraScreenState extends State<DenimJeanCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Capture Denim Jean Measurement"),
          backgroundColor: Colors.teal,
        ),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DenimJeanMeasurementResult(
                    actualSizes: widget.actualSize,
                    selectedSize: widget.selectedSize,
                    capturedImagePath: image.path,
                  ),
                ),
              );
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
