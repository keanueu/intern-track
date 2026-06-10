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
const kRadiusCard   = BorderRadius.all(Radius.circular(24));
const kRadiusBtn    = BorderRadius.all(Radius.circular(16));
const kRadiusNav    = BorderRadius.all(Radius.circular(32));
const kRadiusAvatar = BorderRadius.all(Radius.circular(14));
const kRadiusTag    = BorderRadius.all(Radius.circular(8));
const kRadiusInput  = BorderRadius.all(Radius.circular(14));

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
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kGreen,
      surface: kSurface,
      onSurface: kWhite,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: kWhite, fontWeight: FontWeight.w800, fontSize: 32),
      titleLarge:   TextStyle(color: kWhite, fontWeight: FontWeight.w700, fontSize: 18),
      bodyMedium:   TextStyle(color: kGrey,  fontWeight: FontWeight.w500, fontSize: 13),
      labelSmall:   TextStyle(color: kGrey,  fontWeight: FontWeight.w400, fontSize: 11),
    ),
    dividerColor: kBorder,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface2,
      border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
      labelStyle: const TextStyle(color: kGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: kBg,
        shape: const RoundedRectangleBorder(borderRadius: kRadiusBtn),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
