import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../services/admin_state.dart';
import '../../database/db_helper.dart';
import '../../theme/app_theme.dart';

class AdminKioskScreen extends StatefulWidget {
  const AdminKioskScreen({super.key});

  @override
  State<AdminKioskScreen> createState() => _AdminKioskScreenState();
}

class _AdminKioskScreenState extends State<AdminKioskScreen> {
  bool _canScan = true;
  String _lastMessage = 'Ready to scan';
  bool _lastSuccess = true;

  void _handleQrDetection(BarcodeCapture capture) async {
    if (!_canScan) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() {
        _canScan = false;
        _lastMessage = 'Processing...';
        _lastSuccess = true;
      });
      
      final String token = barcodes.first.rawValue!;
      final String result = await DBHelper.instance.processTimeLog(token);
      
      if (mounted) {
        setState(() {
          _lastMessage = result;
          _lastSuccess = result.contains('Success') || result.contains('Timed');
        });
        
        // Refresh admin state to show latest active sessions in overview/timesheet
        context.read<AdminState>().load();
      }
      
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        setState(() {
          _canScan = true;
          _lastMessage = 'Ready to scan';
          _lastSuccess = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _canScan ? kGreen : (_lastSuccess ? kGreen : const Color(0xFFFF453A));

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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(AppIcons.qrScanner, color: kGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Kiosk Mode',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                          Text(
                            'Scan your Intern QR code',
                            style: TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
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
              width: 280, height: 280,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: activeColor.withValues(alpha: 0.2), width: 1),
                    ),
                  ),
                  ..._buildCorners(activeColor),
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
                  child: Row(
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
                      Text(
                        _lastMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
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
  }

  List<Widget> _buildCorners(Color color) {
    const s = 28.0, t = 4.0, r = 8.0;
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}
