import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ── Static colours (theme-independent) ────────────────────────────────────────
const kGreen      = Color(0xFF00C853);
const kGreenLight = Color(0xFF00E676);
const kGreenDark  = Color(0xFF007A33);
const kRed        = Color(0xFFFF4757);
const kAmber      = Color(0xFFFFB800);

// ── Theme-aware colour set ─────────────────────────────────────────────────────
class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color onAccent;
  final Color shadowColor;

  const ThemeColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onAccent,
    required this.shadowColor,
  });

  static const _dark = ThemeColors(
    bg: Color(0xFF0A0A0F),
    surface: Color(0xFF111118),
    surface2: Color(0xFF1A1A24),
    border: Color(0xFF1E1E2A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF374151),
    onAccent: Color(0xFF0A0A0F),
    shadowColor: Color(0x66000000),
  );

  static const _light = ThemeColors(
    bg: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0F0F2),
    border: Color(0xFFE0E0E5),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF8E8E93),
    textMuted: Color(0xFFA0A0A5),
    onAccent: Color(0xFF0A0A0F),
    shadowColor: Color(0x14000000),
  );

  static ThemeColors of(BuildContext context) =>
      Theme.of(context).extension<ThemeColors>()!;

  @override
  ThemeExtension<ThemeColors> copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? onAccent,
    Color? shadowColor,
  }) =>
      ThemeColors(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surface2: surface2 ?? this.surface2,
        border: border ?? this.border,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        onAccent: onAccent ?? this.onAccent,
        shadowColor: shadowColor ?? this.shadowColor,
      );

  @override
  ThemeColors lerp(ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) return this;
    return ThemeColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

class AppIcons {
  const AppIcons._();

  static const home = CupertinoIcons.house_fill;
  static const homeOutline = CupertinoIcons.house;
  static const manual = CupertinoIcons.time_solid;
  static const manualOutline = CupertinoIcons.clock;
  static const qr = CupertinoIcons.qrcode;
  static const qrScanner = CupertinoIcons.qrcode_viewfinder;
  static const qrOutline = CupertinoIcons.qrcode_viewfinder;
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

const kAmberGradient = LinearGradient(
  colors: [kAmber, Color(0xFFFFD740)],
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
List<BoxShadow> kGreenGlow = [];

List<BoxShadow> kCardShadowFrom(ThemeColors c) => [
  BoxShadow(color: c.shadowColor, blurRadius: 20, offset: const Offset(0, 8)),
];

// ── ThemeData ─────────────────────────────────────────────────────────────────
ThemeData _buildTheme(ThemeColors colors, Brightness brightness) {
  const exter = 'Exter';

  final ColorScheme colorScheme = brightness == Brightness.dark
      ? const ColorScheme.dark(primary: kGreen, surface: Color(0xFF111118), onSurface: Color(0xFFFFFFFF))
      : ColorScheme.light(primary: kGreen, surface: colors.surface, onSurface: colors.textPrimary);

  final base = ThemeData(brightness: brightness, useMaterial3: true, fontFamily: exter);

  TextTheme applyExter(TextTheme t) => t.copyWith(
    displayLarge:   t.displayLarge!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w800, fontSize: 32),
    displayMedium:  t.displayMedium!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w700),
    displaySmall:   t.displaySmall!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w700),
    headlineLarge:  t.headlineLarge!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w700),
    headlineMedium: t.headlineMedium!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w700),
    headlineSmall:  t.headlineSmall!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w600),
    titleLarge:     t.titleLarge!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
    titleMedium:    t.titleMedium!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w600),
    titleSmall:     t.titleSmall!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w600),
    bodyLarge:      t.bodyLarge!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w500),
    bodyMedium:     t.bodyMedium!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
    bodySmall:      t.bodySmall!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textSecondary, fontWeight: FontWeight.w400),
    labelLarge:     t.labelLarge!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textPrimary, fontWeight: FontWeight.w600),
    labelMedium:    t.labelMedium!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textSecondary, fontWeight: FontWeight.w500),
    labelSmall:     t.labelSmall!.copyWith(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textSecondary, fontWeight: FontWeight.w400, fontSize: 11),
  );

  return base.copyWith(
    scaffoldBackgroundColor: colors.bg,
    colorScheme: colorScheme,
    textTheme: applyExter(base.textTheme),
    primaryTextTheme: applyExter(base.primaryTextTheme),
    typography: Typography.material2021().copyWith(
      black: applyExter(Typography.material2021().black),
      white: applyExter(Typography.material2021().white),
      englishLike: applyExter(Typography.material2021().englishLike),
      dense: applyExter(Typography.material2021().dense),
      tall: applyExter(Typography.material2021().tall),
    ),
    dividerColor: colors.border,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface2,
      border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
      labelStyle: TextStyle(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textSecondary),
      hintStyle: TextStyle(fontFamily: exter, fontFamilyFallback: ['sans-serif'], color: colors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: colors.onAccent,
        shape: const RoundedRectangleBorder(borderRadius: kRadiusBtn),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontFamily: exter, fontFamilyFallback: ['sans-serif'], fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    extensions: [colors],
  );
}

ThemeData buildDarkTheme() => _buildTheme(ThemeColors._dark, Brightness.dark);
ThemeData buildLightTheme() => _buildTheme(ThemeColors._light, Brightness.light);

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
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(scale: _anim, child: widget.child),
      );
}

// ── HitArea ───────────────────────────────────────────────────────────────────
class HitArea extends StatelessWidget {
  final Widget child;
  final double size;
  const HitArea({super.key, required this.child, this.size = 48});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: Center(child: child));
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
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          height: widget.height,
          decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(widget.height)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _anim.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: kGreenGradient,
                borderRadius: BorderRadius.circular(widget.height),
              ),
            ),
          ),
        ),
      );
  }
}

// ── Themed card ────────────────────────────────────────────────────────────────
class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const DarkCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    return TapScale(
      onTap: onTap,
      scale: onTap != null ? 0.97 : 1.0,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: kRadiusCard,
          border: Border.all(color: c.border, width: 1),
          boxShadow: kCardShadowFrom(c),
        ),
        child: child,
      ),
    );
  }
}

// ── Shared time utilities ─────────────────────────────────────────────────────
String fmtTime12(DateTime? dt) {
  if (dt == null) return '--:--';
  final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
  final m = dt.minute.toString().padLeft(2, '0');
  final ap = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ap';
}

String fmtElapsed(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  if (h > 0) return '${h}h ${m}m ${s}s';
  if (m > 0) return '${m}m ${s}s';
  return '${s}s';
}
