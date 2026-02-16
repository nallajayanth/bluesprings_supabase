import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'visitor_request_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  late MobileScannerController controller;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the camera when the app is resumed
        // controller.start();
        break;
      case AppLifecycleState.inactive:
        // Stop the camera when the app is paused
        // controller.stop(); 
        // Note: MobileScanner handles lifecycle automatically in newer versions usually but manual handling can be safer
        break;
    }
    super.didChangeAppLifecycleState(state);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isPermissionGranted)
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    controller.stop(); // Stop scanning once detected
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisitorRequestScreen(qrData: barcode.rawValue!),
                      ),
                    );
                    break; 
                  }
                }
              },
            )
          else
            const Center(
              child: Text(
                'Camera permission is required to scan QR codes.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          
          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: const Color(0xFF2962FF),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Title
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child:  Center(
              child: Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Hint Text
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }
}

// Custom Painter for Overlay (Simplified or use package if available, implementing simple one here for speed if package doesn't have it exposed exactly as needed, 
// actually MobileScanner doesn't provide ShapeDecoration overlay directly, so updated code uses a custom ShapeBorder or Container)

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize;
    final _cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderWidth,
      _cutOutSize - borderWidth,
    );


    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;


    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;


    final cutOutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(_cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
    
    
    // Draw Background with cutout
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        cutOutPath,
      ),
      backgroundPaint,
    );
    
    // Draw Corners
    final double halfBorderWidth = borderWidth / 2;
    
    // Top Left
    canvas.drawLine(
        Offset(_cutOutRect.left - halfBorderWidth, _cutOutRect.top),
        Offset(_cutOutRect.left + borderLength, _cutOutRect.top),
        boxPaint
    );
     canvas.drawLine(
        Offset(_cutOutRect.left, _cutOutRect.top - halfBorderWidth),
        Offset(_cutOutRect.left, _cutOutRect.top + borderLength),
        boxPaint
    );

    // Top Right
    canvas.drawLine(
        Offset(_cutOutRect.right + halfBorderWidth, _cutOutRect.top),
        Offset(_cutOutRect.right - borderLength, _cutOutRect.top),
        boxPaint
    );
     canvas.drawLine(
        Offset(_cutOutRect.right, _cutOutRect.top - halfBorderWidth),
        Offset(_cutOutRect.right, _cutOutRect.top + borderLength),
        boxPaint
    );
    
     // Bottom Left
    canvas.drawLine(
        Offset(_cutOutRect.left - halfBorderWidth, _cutOutRect.bottom),
        Offset(_cutOutRect.left + borderLength, _cutOutRect.bottom),
        boxPaint
    );
     canvas.drawLine(
        Offset(_cutOutRect.left, _cutOutRect.bottom + halfBorderWidth),
        Offset(_cutOutRect.left, _cutOutRect.bottom - borderLength),
        boxPaint
    );

    // Bottom Right
    canvas.drawLine(
        Offset(_cutOutRect.right + halfBorderWidth, _cutOutRect.bottom),
        Offset(_cutOutRect.right - borderLength, _cutOutRect.bottom),
        boxPaint
    );
     canvas.drawLine(
        Offset(_cutOutRect.right, _cutOutRect.bottom + halfBorderWidth),
        Offset(_cutOutRect.right, _cutOutRect.bottom - borderLength),
        boxPaint
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
    );
  }
}
