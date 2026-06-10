import 'package:flutter/material.dart';
import 'device_specs.dart';

class NotchWidget extends StatelessWidget {
  final DeviceSpec spec;

  const NotchWidget({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return switch (spec.notchType) {
      NotchType.notch => _Notch(spec: spec),
      NotchType.dynamicIsland => _DynamicIsland(spec: spec),
      NotchType.homeButton => _HomeButton(spec: spec),
      NotchType.none => const SizedBox.shrink(),
    };
  }
}

// ── Classic notch (iPhone 13 / 13 Pro Max) ──────────────────────────────────
class _Notch extends StatelessWidget {
  final DeviceSpec spec;
  const _Notch({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: spec.bezelSide + (spec.width / 2) - (spec.notchWidth / 2),
      top: spec.bezelTop,
      child: Container(
        width: spec.notchWidth,
        height: spec.notchHeight,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1B20),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Earpiece
            Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            // Camera
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2535),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A3545), width: 1),
              ),
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1520),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dynamic Island (iPhone 14 Pro / 15 Pro) ──────────────────────────────────
class _DynamicIsland extends StatelessWidget {
  final DeviceSpec spec;
  const _DynamicIsland({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: spec.bezelSide + (spec.width / 2) - (spec.notchWidth / 2),
      top: spec.bezelTop + 10,
      child: Container(
        width: spec.notchWidth,
        height: spec.notchHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(spec.notchHeight / 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Camera dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2535),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A3545), width: 1),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1520),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home button era (iPhone SE) ───────────────────────────────────────────────
class _HomeButton extends StatelessWidget {
  final DeviceSpec spec;
  const _HomeButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    final double centerX = spec.bezelSide + spec.width / 2;
    final double frameH = spec.frameHeight;

    return Stack(
      children: [
        // Top earpiece
        Positioned(
          left: centerX - spec.notchWidth / 2,
          top: spec.bezelTop / 2 - 5,
          child: Container(
            width: spec.notchWidth,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        // Home button circle
        Positioned(
          left: centerX - 22,
          top: frameH - spec.bezelBottom / 2 - 22,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2930),
              border: Border.all(color: const Color(0xFF3A3840), width: 1.5),
            ),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4A4850), width: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
