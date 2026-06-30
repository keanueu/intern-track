import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const kBg         = Color(0xFF0A0A0F);
const kSurface    = Color(0xFF111118);
const kSurface2   = Color(0xFF1A1A24);
const kBorder     = Color(0xFF1E1E2A);
const kGreen      = Color(0xFF00C853);
const kGreenLight = Color(0xFF00E676);
const kGreenDark  = Color(0xFF007A33);
const kWhite      = Color(0xFFFFFFFF);
const kGrey       = Color(0xFF6B7280);
const kGreyDark   = Color(0xFF374151);
const kRed        = Color(0xFFFF4757);
const kAmber      = Color(0xFFFFB800);

class AppIcons {
  const AppIcons._();

  static const home = CupertinoIcons.house_fill;
  static const homeOutline = CupertinoIcons.house;
  static const manual = CupertinoIcons.pencil_ellipsis_rectangle;
  static const manualOutline = CupertinoIcons.pencil;
  static const qr = CupertinoIcons.qrcode;
  static const qrScanner = CupertinoIcons.qrcode_viewfinder;
  static const records = CupertinoIcons.chart_bar_fill;
  static const recordsOutline = CupertinoIcons.chart_bar;
  static const profile = CupertinoIcons.person_fill;
  static const profileOutline = CupertinoIcons.person;
  static const phone = CupertinoIcons.device_phone_portrait;
  static const rotate = CupertinoIcons.rotate_right;
  static const cellular = CupertinoIcons.antenna_radiowaves_left_right;
  static const wifi = CupertinoIcons.wifi;
  static const wifiOff = CupertinoIcons.wifi_slash;
  static const battery = CupertinoIcons.battery_full;
  static const checkCircle = CupertinoIcons.check_mark_circled_solid;
  static const checkCircleOutline = CupertinoIcons.check_mark_circled;
  static const calendar = CupertinoIcons.calendar;
  static const delete = CupertinoIcons.delete_solid;
  static const deleteOutline = CupertinoIcons.delete;
  static const addPerson = CupertinoIcons.person_badge_plus;
  static const logout = CupertinoIcons.square_arrow_right;
  static const login = CupertinoIcons.square_arrow_left;
  static const people = CupertinoIcons.person_2_fill;
  static const peopleOutline = CupertinoIcons.person_2;
  static const bolt = CupertinoIcons.bolt_fill;
  static const pieChart = CupertinoIcons.chart_pie_fill;
  static const chevronLeft = CupertinoIcons.chevron_left;
  static const chevronRight = CupertinoIcons.chevron_right;
  static const chevronDown = CupertinoIcons.chevron_down;
  static const pdf = CupertinoIcons.doc_richtext;
  static const pdfOutline = CupertinoIcons.doc_text;
  static const notifications = CupertinoIcons.bell;
  static const email = CupertinoIcons.mail;
  static const lock = CupertinoIcons.lock;
  static const timer = CupertinoIcons.timer;
  static const eventNote = CupertinoIcons.doc_text;
  static const hub = CupertinoIcons.circle_grid_hex_fill;
  static const dateRange = CupertinoIcons.calendar_today;
  static const breakfast = CupertinoIcons.pause_circle_fill;
  static const today = CupertinoIcons.today;
  static const close = CupertinoIcons.xmark;
  static const workHistory = CupertinoIcons.briefcase_fill;
  static const download = CupertinoIcons.arrow_down_doc_fill;
  static const school = CupertinoIcons.book_fill;
  static const business = CupertinoIcons.building_2_fill;
  static const manageAccounts = CupertinoIcons.person_crop_circle_badge_checkmark;
  static const copy = CupertinoIcons.doc_on_doc_fill;
  static const camera = CupertinoIcons.camera_fill;
  static const photoLibrary = CupertinoIcons.photo_fill_on_rectangle_fill;
  static const badge = CupertinoIcons.rosette;
  static const edit = CupertinoIcons.pencil_circle_fill;
  static const timerOff = CupertinoIcons.timer;
  static const warning = CupertinoIcons.exclamationmark_triangle_fill;
  static const dashboard = CupertinoIcons.rectangle_grid_2x2_fill;
  static const dashboardOutline = CupertinoIcons.rectangle_grid_2x2;
  static const approvals = CupertinoIcons.checkmark_rectangle_fill;
  static const approvalsOutline = CupertinoIcons.checkmark_rectangle;
  static const table = CupertinoIcons.table_fill;
  static const tableOutline = CupertinoIcons.table;
}

const kGreenGradient = LinearGradient(
  colors: [kGreen, kGreenLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kGreenGradientDeep = LinearGradient(
  colors: [kGreen, kGreenDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ── Border Radii ──────────────────────────────────────────────────────────────
const kRadiusCard   = BorderRadius.all(Radius.circular(16));
const kRadiusBtn    = BorderRadius.all(Radius.circular(10));
const kRadiusNav    = BorderRadius.all(Radius.circular(100));
const kRadiusAvatar = BorderRadius.all(Radius.circular(10));
const kRadiusTag    = BorderRadius.all(Radius.circular(6));
const kRadiusInput  = BorderRadius.all(Radius.circular(10));

// ── Durations ─────────────────────────────────────────────────────────────────
const kDurFast   = Duration(milliseconds: 150);
const kDurNormal = Duration(milliseconds: 280);
const kDurSlow   = Duration(milliseconds: 500);
const kCurve     = Curves.easeOutCubic;

// ── Shadows ───────────────────────────────────────────────────────────────────
List<BoxShadow> kGreenGlow = [
  BoxShadow(color: kGreen.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8)),
];
List<BoxShadow> kCardShadow = [
  BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
];

// ── ThemeData ─────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  const exter = 'Exter';

  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: exter);

  TextTheme applyExter(TextTheme t) => t.copyWith(
    displayLarge:   t.displayLarge!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w800, fontSize: 32),
    displayMedium:  t.displayMedium!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w700),
    displaySmall:   t.displaySmall!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w700),
    headlineLarge:  t.headlineLarge!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w700),
    headlineMedium: t.headlineMedium!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w700),
    headlineSmall:  t.headlineSmall!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w600),
    titleLarge:     t.titleLarge!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w700, fontSize: 18),
    titleMedium:    t.titleMedium!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w600),
    titleSmall:     t.titleSmall!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w600),
    bodyLarge:      t.bodyLarge!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w500),
    bodyMedium:     t.bodyMedium!.copyWith(fontFamily: exter, color: kGrey,  fontWeight: FontWeight.w500, fontSize: 13),
    bodySmall:      t.bodySmall!.copyWith(fontFamily: exter, color: kGrey,  fontWeight: FontWeight.w400),
    labelLarge:     t.labelLarge!.copyWith(fontFamily: exter, color: kWhite, fontWeight: FontWeight.w600),
    labelMedium:    t.labelMedium!.copyWith(fontFamily: exter, color: kGrey,  fontWeight: FontWeight.w500),
    labelSmall:     t.labelSmall!.copyWith(fontFamily: exter, color: kGrey,  fontWeight: FontWeight.w400, fontSize: 11),
  );

  return base.copyWith(
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kGreen,
      surface: kSurface,
      onSurface: kWhite,
    ),
    textTheme: applyExter(base.textTheme),
    primaryTextTheme: applyExter(base.primaryTextTheme),
    typography: Typography.material2021().copyWith(
      black: applyExter(Typography.material2021().black),
      white: applyExter(Typography.material2021().white),
      englishLike: applyExter(Typography.material2021().englishLike),
      dense: applyExter(Typography.material2021().dense),
      tall: applyExter(Typography.material2021().tall),
    ),
    dividerColor: kBorder,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface2,
      border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
      labelStyle: const TextStyle(fontFamily: exter, color: kGrey),
      hintStyle: const TextStyle(fontFamily: exter, color: kGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: kBg,
        shape: const RoundedRectangleBorder(borderRadius: kRadiusBtn),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontFamily: exter, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
  );
}

// ── TapScale ──────────────────────────────────────────────────────────────────
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const TapScale({super.key, required this.child, this.onTap, this.scale = 0.95});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: kDurFast);
    _anim = Tween(begin: 1.0, end: widget.scale)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(scale: _anim, child: widget.child),
      );
}

// ── FadeSlideIn ───────────────────────────────────────────────────────────────
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final int delayMs;
  const FadeSlideIn({super.key, required this.child, required this.index, this.delayMs = 60});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: kDurNormal);
    _fade  = CurvedAnimation(parent: _ctrl, curve: kCurve);
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: kCurve));
    Future.delayed(Duration(milliseconds: widget.index * widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ── AnimatedGradientBar ───────────────────────────────────────────────────────
class AnimatedGradientBar extends StatefulWidget {
  final double value;
  final double height;
  const AnimatedGradientBar({super.key, required this.value, this.height = 8});

  @override
  State<AnimatedGradientBar> createState() => _AnimatedGradientBarState();
}

class _AnimatedGradientBarState extends State<AnimatedGradientBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: kDurSlow);
    _anim = Tween(begin: 0.0, end: widget.value.clamp(0.0, 1.0))
        .animate(CurvedAnimation(parent: _ctrl, curve: kCurve));
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          height: widget.height,
          decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(widget.height)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _anim.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: kGreenGradient,
                borderRadius: BorderRadius.circular(widget.height),
                boxShadow: [BoxShadow(color: kGreen.withValues(alpha: 0.4), blurRadius: 6)],
              ),
            ),
          ),
        ),
      );
}

// ── Dark surface card ─────────────────────────────────────────────────────────
class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const DarkCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) => TapScale(
        onTap: onTap,
        scale: onTap != null ? 0.97 : 1.0,
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: kRadiusCard,
            border: Border.all(color: kBorder, width: 1),
            boxShadow: kCardShadow,
          ),
          child: child,
        ),
      );
}
