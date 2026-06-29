import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kReleaseMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/manual_punch_screen.dart';
import 'screens/records_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scanner_screen.dart';
import 'services/app_state.dart';
import 'services/admin_state.dart';
import 'theme/app_theme.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..load()),
        ChangeNotifierProvider(create: (_) => AdminState()),
      ],
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainContainer(),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    HomeScreen(),
    ManualPunchScreen(),
    ScannerScreen(),
    RecordsScreen(),
    ProfileScreen(),
  ];

  void _openScanner() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: AnimatedSwitcher(
        duration: kDurNormal,
        switchInCurve: kCurve,
        switchOutCurve: kCurve,
        transitionBuilder: (child, anim) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: kCurve));
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _views[_currentIndex],
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onScanTap: _openScanner,
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScanTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 8),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: kRadiusNav,
          border: Border.all(color: kBorder),
          boxShadow: kCardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_rounded, outlinedIcon: Icons.home_outlined, label: 'Home', index: 0, current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.edit_note_rounded, outlinedIcon: Icons.edit_note_outlined, label: 'Manual', index: 1, current: currentIndex, onTap: onTap),

            // Center QR button
            TapScale(
              onTap: onScanTap,
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: currentIndex == 2 ? kGreenGradient : const LinearGradient(colors: [kSurface2, kSurface2]),
                    shape: BoxShape.circle,
                    border: Border.all(color: currentIndex == 2 ? kGreen : kBorder, width: 1.5),
                    boxShadow: currentIndex == 2 ? kGreenGlow : kCardShadow,
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, color: kWhite, size: 24),
                ),
              ),
            ),

            _NavItem(icon: Icons.bar_chart_rounded, outlinedIcon: Icons.bar_chart_outlined, label: 'Records', index: 3, current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.person_rounded, outlinedIcon: Icons.person_outline_rounded, label: 'Profile', index: 4, current: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = current == index;

    return Expanded(
      child: TapScale(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: kDurNormal,
          curve: kCurve,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? kGreen.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? icon : outlinedIcon,
                  color: selected ? kGreen : kGrey, size: 22),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? kGreen : kGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
