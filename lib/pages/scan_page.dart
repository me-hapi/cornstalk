import 'dart:io'; // For file handling
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'process_image.dart'; // Import the new process_image.dart
import 'package:flutter/scheduler.dart'; // To track route pops
import 'dart:async'; // For animation timing

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with TickerProviderStateMixin, RouteAware {
  CameraController? _cameraController;
  XFile? _imageFile;
  bool _isCameraInitialized = false;
  bool _isProcessing = false; // Track if the image is being processed
  double _progress = 0; // Track progress for animation
  bool _isButtonDisabled = false; // Track button states

  late AnimationController _animationController; // For progress animation
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _initializeCamera();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required.')),
      );
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
      );
      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_isButtonDisabled &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      setState(() {
        _isButtonDisabled = true;
      });

      _imageFile = await _cameraController!.takePicture();
      if (_imageFile != null) {
        _startProcessing(_imageFile!.path);
      }

      setState(() {});
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (!_isButtonDisabled) {
      setState(() {
        _isButtonDisabled = true;
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = pickedFile;
        });
        _startProcessing(pickedFile.path);
      }
    }
  }

  void _startProcessing(String imagePath) {
    setState(() {
      _isProcessing = true;
      _progress = 0;
    });

    _animationController.reset();
    _animationController.forward();

    // Simulate progress
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.02;
      });

      if (_progress >= 1.0) {
        timer.cancel();
        setState(() {
          _isButtonDisabled =
              false; // Enable buttons after processing completes
        });
      }
    });

    // Process the image (this sends it to the API)
    ProcessImage.processImageFile(context, imagePath).then((_) {
      setState(() {
        _isProcessing = false;
        _progress = 1.0;
        _imageFile = null;
        _isButtonDisabled = false; // Enable buttons after processing completes
      });
    });
  }

  @override
  void didPopNext() {
    // This is called when coming back from DisplayResult
    setState(() {
      _imageFile = null; // Clear the image
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Display the camera preview if no image is captured or picked
          if (_imageFile == null &&
              _isCameraInitialized &&
              _cameraController != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),

          // Display the captured or picked image when available
          if (_imageFile != null)
            Image.file(
              File(_imageFile!.path),
              fit: BoxFit
                  .cover, // Ensure the image fits properly in the available space
              height: double.infinity,
              width: double.infinity,
            ),

          // Corn loading animation (overlays the image while processing)
          if (_isProcessing)
            Positioned(
              child: CornLoadingAnimation(progress: _progress),
            ),

          // Buttons to take a picture or upload an image
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Spacer to push the capture button to the center
                SizedBox(width: 50), // Leave space on the left if needed

                GestureDetector(
                  onTap: _isButtonDisabled
                      ? null
                      : _takePicture, // Disable tap if button is disabled
                  child: Image.asset(
                    'assets/capture.png',
                    height: 60,
                    width: 60,
                  ),
                ),

                GestureDetector(
                  onTap: _isButtonDisabled
                      ? null
                      : _pickImageFromGallery, // Disable tap if button is disabled
                  child: Image.asset(
                    'assets/pick_image.png',
                    height: 60,
                    width: 60,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CornLoadingAnimation extends StatelessWidget {
  final double progress;

  const CornLoadingAnimation({required this.progress});

  @override
  Widget build(BuildContext context) {
    // Clamp the progress between 0.0 and 1.0 to avoid invalid values
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1, // Preserve the aspect ratio of the corn image
          child: Stack(
            alignment: Alignment.bottomCenter, // Align images to the bottom
            children: [
              // Corn empty image (background)
              Image.asset(
                'assets/corn_prefilled.png',
                fit: BoxFit.contain, // Contain keeps the aspect ratio
                width: double.infinity,
                height: double.infinity,
              ),

              // Corn filled image (filling from bottom to top based on progress)
              ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor:
                      clampedProgress, // This controls how much of the image is shown
                  child: Image.asset(
                    'assets/corn_filled.png',
                    fit: BoxFit.contain, // Contain keeps the aspect ratio
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text('${(clampedProgress * 100).toInt()}% completed'),
      ],
    );
  }
}
