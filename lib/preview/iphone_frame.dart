import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'device_specs.dart';
import 'notch_widget.dart';

class IPhoneFrame extends StatelessWidget {
  final DeviceSpec spec;
  final Widget child;
  final bool landscape;

  const IPhoneFrame({
    super.key,
    required this.spec,
    required this.child,
    this.landscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW = landscape ? spec.height : spec.width;
    final double screenH = landscape ? spec.width : spec.height;
    final double frameW = screenW + spec.bezelSide * 2;
    final double frameH = screenH + spec.bezelTop + spec.bezelBottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double scaleH = (constraints.maxHeight - 32) / frameH;
        final double scaleW = (constraints.maxWidth - 32) / frameW;
        final double scale = scaleH < scaleW ? scaleH : scaleW;
        final double clampedScale = scale.clamp(0.3, 1.0);

        return Center(
          child: Transform.scale(
            scale: clampedScale,
            child: SizedBox(
              width: frameW,
              height: frameH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Outer body ──────────────────────────────────────────
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1B20),
                        borderRadius: BorderRadius.circular(spec.cornerRadius),
                        border: Border.all(color: const Color(0xFF3A3940), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 48,
                            spreadRadius: 4,
                            offset: const Offset(0, 18),
                          ),
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                            blurRadius: 64,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Side buttons ────────────────────────────────────────
                  if (!landscape) ...[
                    // Silent toggle
                    Positioned(
                      left: -3,
                      top: screenH * 0.14,
                      child: const _SideButton(width: 3.5, height: 32),
                    ),
                    // Volume up
                    Positioned(
                      left: -3,
                      top: screenH * 0.20,
                      child: const _SideButton(width: 3.5, height: 62),
                    ),
                    // Volume down
                    Positioned(
                      left: -3,
                      top: screenH * 0.29,
                      child: const _SideButton(width: 3.5, height: 62),
                    ),
                    // Power
                    Positioned(
                      right: -3,
                      top: screenH * 0.21,
                      child: const _SideButton(width: 3.5, height: 80),
                    ),
                  ],

                  // ── Screen ──────────────────────────────────────────────
                  Positioned(
                    left: spec.bezelSide,
                    top: spec.bezelTop,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        landscape ? spec.screenCornerRadius * 0.5 : spec.screenCornerRadius,
                      ),
                      child: SizedBox(
                        width: screenW,
                        height: screenH,
                        child: Stack(
                          children: [
                            child,
                            const _StatusBar(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Notch / Dynamic Island / Home button ────────────────
                  if (!landscape)
                    NotchWidget(spec: spec),

                  // ── Home indicator ──────────────────────────────────────
                  if (spec.notchType != NotchType.homeButton)
                    Positioned(
                      left: spec.bezelSide,
                      top: spec.bezelTop + screenH - 28,
                      child: SizedBox(
                        width: screenW,
                        height: 28,
                        child: Center(
                          child: Container(
                            width: 130,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SideButton extends StatelessWidget {
  final double width, height;
  const _SideButton({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2D33),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Text(
                  '9:41',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  children: const [
                    Icon(AppIcons.cellular, size: 16, color: Color(0xFF1C1C1E)),
                    SizedBox(width: 5),
                    Icon(AppIcons.wifi, size: 16, color: Color(0xFF1C1C1E)),
                    SizedBox(width: 5),
                    Icon(AppIcons.battery, size: 18, color: Color(0xFF1C1C1E)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
