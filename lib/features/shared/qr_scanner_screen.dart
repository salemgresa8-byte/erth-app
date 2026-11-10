import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';

/// Full-screen QR scanner. Pops with the scanned string (see `context.push<String>`).
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        _handled = true;
        context.pop(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final side = size.shortestSide * 0.7;
    final window = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 30),
      width: side,
      height: side,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Scan Artifact')),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Camera unavailable (${error.errorCode.name}).\n'
                  'Please allow camera access and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.marble),
                ),
              ),
            ),
          ),
          CustomPaint(painter: _ScannerOverlayPainter(window)),
          Positioned(
            left: 0,
            right: 0,
            top: window.bottom + 24,
            child: Text(
              'Align the QR code within the frame',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.marble),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter(this.window);

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(window, const Radius.circular(20));

    // Dim everything except the scan window.
    final dim = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(rrect),
    );
    canvas.drawPath(
      dim,
      Paint()..color = AppColors.burgundy.withValues(alpha: 0.7),
    );

    // Warm Marble corner brackets.
    final paint = Paint()
      ..color = AppColors.marble
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const len = 36.0;
    final r = window;

    for (final c in [
      [r.topLeft, const Offset(1, 0), const Offset(0, 1)],
      [r.topRight, const Offset(-1, 0), const Offset(0, 1)],
      [r.bottomLeft, const Offset(1, 0), const Offset(0, -1)],
      [r.bottomRight, const Offset(-1, 0), const Offset(0, -1)],
    ]) {
      final p = c[0];
      final h = c[1];
      final v = c[2];
      canvas.drawLine(p, p + h * len, paint);
      canvas.drawLine(p, p + v * len, paint);
    }
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) => old.window != window;
}
