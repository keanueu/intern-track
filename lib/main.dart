import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'
    show kReleaseMode, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/manual_punch_screen.dart';
import 'screens/records_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/lock_screen.dart';
import 'services/app_state.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await SettingsService.instance.load();
  await NotificationService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SettingsService.instance),
        ChangeNotifierProvider(create: (_) => AppState()..load()),
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
    final themeMode = context.watch<SettingsService>().flutterThemeMode;

    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        return DevicePreview.appBuilder(context, LockScreen(child: child!));
      },
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(),
      themeMode: themeMode,
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
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 62,
            width: 328,
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: kRadiusNav,
              border: Border.all(color: kBorder),
              boxShadow: kCardShadow,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const pillSize = 50.0;
                final itemWidth = constraints.maxWidth / 5;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                            icon: AppIcons.home,
                            outlinedIcon: AppIcons.homeOutline,
                            index: 0,
                            current: currentIndex,
                            onTap: onTap),
                        _NavItem(
                            icon: AppIcons.manual,
                            outlinedIcon: AppIcons.manualOutline,
                            index: 1,
                            current: currentIndex,
                            onTap: onTap),
                        _NavItem(
                            icon: AppIcons.qr,
                            outlinedIcon: AppIcons.qrOutline,
                            index: 2,
                            current: currentIndex,
                            onTap: onTap),
                        _NavItem(
                            icon: AppIcons.records,
                            outlinedIcon: AppIcons.recordsOutline,
                            index: 3,
                            current: currentIndex,
                            onTap: onTap),
                        _NavItem(
                            icon: AppIcons.profile,
                            outlinedIcon: AppIcons.profileOutline,
                            index: 4,
                            current: currentIndex,
                            onTap: onTap),
                      ],
                    ),
                    AnimatedPositioned(
                      duration: kDurNormal,
                      curve: kCurve,
                      left:
                          currentIndex * itemWidth + (itemWidth - pillSize) / 2,
                      top: (59 - pillSize) / 2,
                      child: Container(
                        width: pillSize,
                        height: pillSize,
                        decoration: BoxDecoration(
                          color: kGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
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
        child: Center(
          child: Icon(
            selected ? icon : outlinedIcon,
            color: selected ? kGreen : kGrey,
            size: 22,
          ),
        ),
      ),
    );
  }
}
