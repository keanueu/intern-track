import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

enum _ScanResult { success, error, none }

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _canScan = true;
  _ScanResult _scanResult = _ScanResult.none;
  bool _cameraPermissionGranted = true;
  late final AnimationController _laserCtrl;
  late final Animation<double> _laserAnim;
  MobileScannerController? _cameraController;

  @override
  void initState() {
    super.initState();
    _laserCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _laserAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserCtrl, curve: Curves.easeInOut),
    );
    _laserCtrl.repeat();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _laserCtrl.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    if (kIsWeb) {
      setState(() => _cameraPermissionGranted = true);
      return;
    }
    final status = await Permission.camera.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final requested = await Permission.camera.request();
      setState(() => _cameraPermissionGranted = requested.isGranted);
    } else {
      setState(() => _cameraPermissionGranted = status.isGranted);
    }
  }

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('_getLocation error: $e');
      return null;
    }
  }

  void _handleQrDetection(BarcodeCapture capture) async {
    if (!_canScan) return;
    final c = ThemeColors.of(context);
    HapticFeedback.mediumImpact();
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    setState(() {
      _canScan = false;
      _scanResult = _ScanResult.none;
    });

    final state = context.read<AppState>();
    final pos = await _getLocation();

    if (pos == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(AppIcons.wifiOff, color: kAmber, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text('Location unavailable — entry saved without GPS',
              style: TextStyle(color: c.textPrimary))),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
            borderRadius: kRadiusBtn, side: BorderSide(color: c.border)),
        duration: const Duration(seconds: 3),
      ));
    }

    final String result = await state.scanPunch(
      barcodes.first.rawValue!,
      lat: pos?.latitude,
      lng: pos?.longitude,
    );

    final bool isSuccess = result.contains('Success') ||
        result.contains('Timed In') ||
        result.contains('Timed Out');

    if (mounted) {
      setState(() => _scanResult = isSuccess ? _ScanResult.success : _ScanResult.error);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(
            isSuccess ? AppIcons.checkCircle : AppIcons.warning,
            color: isSuccess ? kGreen : kRed,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(result, style: TextStyle(color: c.textPrimary))),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
            borderRadius: kRadiusBtn, side: BorderSide(color: c.border)),
        duration: const Duration(seconds: 3),
      ));

      // Reset scan result visual after a delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _scanResult = _ScanResult.none;
          _canScan = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final c = ThemeColors.of(context);
        final ts = Theme.of(context).textTheme;

        Color activeColor;
        switch (_scanResult) {
          case _ScanResult.success:
            activeColor = kGreen;
          case _ScanResult.error:
            activeColor = kRed;
          case _ScanResult.none:
            activeColor = _canScan
                ? (state.isPunchedIn ? kGreen : kGreenLight)
                : kAmber;
        }

        // Show camera permission denied UI
        if (!_cameraPermissionGranted) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(AppIcons.camera, color: Colors.white54, size: 36),
                      ),
                      const SizedBox(height: 24),
                      Text('Camera Access Required',
                          style: ts.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(
                        'Allow camera access to scan QR codes for attendance.',
                        textAlign: TextAlign.center,
                        style: ts.bodyMedium?.copyWith(color: Colors.white54),
                      ),
                      const SizedBox(height: 28),
                      TapScale(
                        onTap: () async {
                          await openAppSettings();
                          _checkCameraPermission();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: kGreenGradient,
                            borderRadius: kRadiusBtn,
                            boxShadow: kGreenGlow,
                          ),
                          child: Text('Open Settings',
                              style: TextStyle(
                                  color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TapScale(
                        onTap: _checkCameraPermission,
                        child: Text('Try Again',
                            style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(onDetect: _handleQrDetection),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.9,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                  ),
                ),
              ),

              // Header
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _FrostedGlassPill(
                      borderRadius: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(AppIcons.qr, color: activeColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('QR Scanner',
                                    style: ts.titleSmall?.copyWith(color: c.textPrimary)),
                                Text(
                                  state.isPunchedIn
                                      ? 'Scan to time out'
                                      : 'Scan to time in',
                                  style: TextStyle(color: c.textPrimary.withValues(alpha: 0.6), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: state.isPunchedIn
                                  ? kGreen.withValues(alpha: 0.2)
                                  : c.textPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              state.isPunchedIn ? 'IN' : 'OUT',
                              style: TextStyle(
                                color: state.isPunchedIn ? kGreen : c.textPrimary.withValues(alpha: 0.6),
                                fontSize: 11, fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Scan frame
              Center(
                child: SizedBox(
                  width: 224, height: 224,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Border
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _scanResult == _ScanResult.error
                                ? kRed.withValues(alpha: 0.5)
                                : activeColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      // Corners
                      ..._buildCorners(activeColor),
                      // Scanning laser line
                      if (_canScan && _scanResult == _ScanResult.none)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedBuilder(
                              animation: _laserAnim,
                              builder: (_, __) => Positioned(
                                top: _laserAnim.value * 200,
                                left: 0, right: 0,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        activeColor.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Success overlay
                      if (_scanResult == _ScanResult.success)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: kGreen.withValues(alpha: 0.2),
                            ),
                            child: const Center(
                              child: Icon(AppIcons.checkCircle, color: Colors.white, size: 56),
                            ),
                          ),
                        ),
                      // Error overlay
                      if (_scanResult == _ScanResult.error)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: kRed.withValues(alpha: 0.2),
                            ),
                            child: const Center(
                              child: Icon(AppIcons.warning, color: kRed, size: 56),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom status
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: _FrostedGlassPill(
                      borderRadius: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: activeColor,
                                  boxShadow: [BoxShadow(color: activeColor.withValues(alpha: 0.6), blurRadius: 8)],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  _getStatusLabel(state),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ts.titleSmall?.copyWith(color: c.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Point camera at your QR code',
                            style: TextStyle(color: c.textPrimary.withValues(alpha: 0.5), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusLabel(AppState state) {
    if (_scanResult == _ScanResult.success) return 'Scan successful';
    if (_scanResult == _ScanResult.error) return 'Invalid QR code';
    if (!_canScan) return 'Processing...';
    return state.isPunchedIn ? 'Ready to time out' : 'Ready to time in';
  }

  List<Widget> _buildCorners(Color color) {
    const s = 28.0, t = 3.5, r = 8.0;
    Widget corner(Alignment align, BorderRadius br) => Align(
          alignment: align,
          child: Container(
            width: s, height: s,
            decoration: BoxDecoration(
              borderRadius: br,
              border: Border(
                top: (align == Alignment.topLeft || align == Alignment.topRight) ? BorderSide(color: color, width: t) : BorderSide.none,
                bottom: (align == Alignment.bottomLeft || align == Alignment.bottomRight) ? BorderSide(color: color, width: t) : BorderSide.none,
                left: (align == Alignment.topLeft || align == Alignment.bottomLeft) ? BorderSide(color: color, width: t) : BorderSide.none,
                right: (align == Alignment.topRight || align == Alignment.bottomRight) ? BorderSide(color: color, width: t) : BorderSide.none,
              ),
            ),
          ),
        );
    return [
      corner(Alignment.topLeft, const BorderRadius.only(topLeft: Radius.circular(r))),
      corner(Alignment.topRight, const BorderRadius.only(topRight: Radius.circular(r))),
      corner(Alignment.bottomLeft, const BorderRadius.only(bottomLeft: Radius.circular(r))),
      corner(Alignment.bottomRight, const BorderRadius.only(bottomRight: Radius.circular(r))),
    ];
  }
}

class _FrostedGlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const _FrostedGlassPill({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: c.textPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: c.textPrimary.withValues(alpha: 0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}
