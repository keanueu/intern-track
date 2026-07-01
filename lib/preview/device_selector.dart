import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'device_specs.dart';

class DeviceSelector extends StatelessWidget {
  final DeviceSpec selected;
  final bool landscape;
  final ValueChanged<DeviceSpec> onDeviceChanged;
  final VoidCallback onOrientationToggle;

  const DeviceSelector({
    super.key,
    required this.selected,
    required this.landscape,
    required this.onDeviceChanged,
    required this.onOrientationToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Scrollable device chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: iPhoneDevices.map((device) {
                  final bool isSelected = device.name == selected.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onDeviceChanged(device),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6C63FF)
                                : Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.phone,
                              size: 13,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              device.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Orientation toggle
          GestureDetector(
            onTap: onOrientationToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: landscape
                    ? const Color(0xFF6C63FF)
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: landscape
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: AnimatedRotation(
                turns: landscape ? 0.25 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  AppIcons.rotate,
                  size: 18,
                  color: landscape ? Colors.white : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
