enum NotchType { none, notch, dynamicIsland, homeButton }

class DeviceSpec {
  final String name;
  final double width;
  final double height;
  final double cornerRadius;
  final double screenCornerRadius;
  final double bezelSide;
  final double bezelTop;
  final double bezelBottom;
  final NotchType notchType;
  final double notchWidth;
  final double notchHeight;

  const DeviceSpec({
    required this.name,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.screenCornerRadius,
    required this.bezelSide,
    required this.bezelTop,
    required this.bezelBottom,
    required this.notchType,
    required this.notchWidth,
    required this.notchHeight,
  });

  double get frameWidth => width + bezelSide * 2;
  double get frameHeight => height + bezelTop + bezelBottom;
}

const List<DeviceSpec> iPhoneDevices = [
  DeviceSpec(
    name: 'iPhone SE',
    width: 375,
    height: 667,
    cornerRadius: 38,
    screenCornerRadius: 4,
    bezelSide: 14,
    bezelTop: 60,
    bezelBottom: 80,
    notchType: NotchType.homeButton,
    notchWidth: 120,
    notchHeight: 16,
  ),
  DeviceSpec(
    name: 'iPhone 13',
    width: 390,
    height: 844,
    cornerRadius: 47,
    screenCornerRadius: 38,
    bezelSide: 11,
    bezelTop: 26,
    bezelBottom: 26,
    notchType: NotchType.notch,
    notchWidth: 150,
    notchHeight: 34,
  ),
  DeviceSpec(
    name: 'iPhone 13 Pro Max',
    width: 428,
    height: 926,
    cornerRadius: 50,
    screenCornerRadius: 40,
    bezelSide: 11,
    bezelTop: 26,
    bezelBottom: 26,
    notchType: NotchType.notch,
    notchWidth: 162,
    notchHeight: 34,
  ),
  DeviceSpec(
    name: 'iPhone 14 Pro',
    width: 393,
    height: 852,
    cornerRadius: 48,
    screenCornerRadius: 38,
    bezelSide: 11,
    bezelTop: 26,
    bezelBottom: 26,
    notchType: NotchType.dynamicIsland,
    notchWidth: 120,
    notchHeight: 36,
  ),
  DeviceSpec(
    name: 'iPhone 15 Pro',
    width: 393,
    height: 852,
    cornerRadius: 48,
    screenCornerRadius: 38,
    bezelSide: 11,
    bezelTop: 26,
    bezelBottom: 26,
    notchType: NotchType.dynamicIsland,
    notchWidth: 110,
    notchHeight: 34,
  ),
];
