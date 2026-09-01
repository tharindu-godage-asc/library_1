// BooksnU — animated splash screen.
//
// Native Flutter reimplementation of design-concept/og/Splash.dc.html.
// Chosen over an exported video/GIF/Lottie: this stays vector-sharp at any
// device density, adds ~0 asset weight, and reuses the exact same color/font
// tokens as the rest of the app instead of baking them into a rendered file.
//
// Dependencies to add to pubspec.yaml:
//   google_fonts: ^6.0.0
//   path_drawing: ^1.0.1
//
// Usage:
//   Navigator.of(context).pushReplacement(
//     MaterialPageRoute(builder: (_) => const SplashScreen()),
//   );
// or wire `onFinished` below to your router once the hold duration elapses.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_drawing/path_drawing.dart';

/// BooksnU cozy palette — same hex values as booksnu-color-tokens.json.
class _C {
  static const ink = Color(0xFF4A3F47);
  static const cream = Color(0xFFFDF6EA);
  static const creamDeep = Color(0xFFEFE1C8);
  static const spine = Color(0xFF6B5A73);
  static const gold = Color(0xFFE8B84E);
  static const plum = Color(0xFFBB93B6);
  static const bgStart = Color(0xFFF7E7D9);
  static const bgMid = Color(0xFFF1DCE6);
  static const bgEnd = Color(0xFFE3D8EF);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.holdDuration = const Duration(milliseconds: 2400), this.onFinished});

  /// How long the splash stays up before [onFinished] fires. Set to null-safe
  /// no-op if you're driving navigation from session-restore logic instead.
  final Duration holdDuration;
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Drives every *looping* animation (glow pulse, book breathe, ribbon sway,
  // star twinkle, floating decorations, loading-dot bounce). We never read
  // `.value` — only `lastElapsedDuration` — so the nominal duration below is
  // arbitrary; it just needs to be long enough to never "complete".
  late final AnimationController _loop;

  // Drives the one-shot entrance: wordmark, tagline, then loading dots
  // fade+slide up in sequence, matching the CSS `fadeSlideUp` delays.
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(days: 1))..forward();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();

    if (widget.onFinished != null) {
      Future.delayed(widget.holdDuration, widget.onFinished!);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _entrance.dispose();
    super.dispose();
  }

  double get _t => _loop.lastElapsedDuration!.inMicroseconds / 1e6; // elapsed seconds

  /// Smooth 0..1 oscillation with period [seconds] and phase [delay] (both in
  /// seconds) — mirrors the ease-in-out feel of the original CSS keyframes.
  double _osc(double seconds, {double delay = 0}) => 0.5 - 0.5 * math.cos(2 * math.pi * (_t - delay) / seconds);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.35, -1), // approximates the CSS 160deg angle
            end: Alignment(0.35, 1),
            colors: [_C.bgStart, _C.bgMid, _C.bgEnd],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_loop, _entrance]),
          builder: (context, _) => Stack(
            alignment: Alignment.center,
            children: [
              _buildGlow(),
              _buildDeco(top: 92, left: 46, size: 26, period: 4.5, delay: 0, child: _bookIcon()),
              _buildDeco(top: 682, right: 44, size: 22, period: 5.2, delay: 0.6, child: _starIcon()),
              _buildDeco(top: 150, right: 60, size: 20, height: 24, period: 3.8, delay: 1.1, child: _bookmarkIcon()),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Glow ----------------------------------------------------------

  Widget _buildGlow() {
    final o = _osc(3.6);
    return Align(
      alignment: const Alignment(0, -0.42),
      child: Transform.scale(
        scale: 1.0 + 0.14 * o,
        child: Opacity(
          opacity: 0.55 + 0.35 * o,
          child: Container(
            width: 420,
            height: 420,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x47E8B84E), Color(0x00E8B84E)], // gold, alpha 0.28 -> 0
                stops: [0.0, 0.7],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---- Floating decorations -------------------------------------------

  Widget _buildDeco({
    double? top,
    double? left,
    double? right,
    required double size,
    double? height,
    required double period,
    required double delay,
    required Widget child,
  }) {
    final o = _osc(period, delay: delay);
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Opacity(
        opacity: 0.5,
        child: Transform.translate(
          offset: Offset(0, -10 * o),
          child: Transform.rotate(
            angle: (6 * o) * math.pi / 180,
            child: SizedBox(width: size, height: height ?? size, child: child),
          ),
        ),
      ),
    );
  }

  Widget _bookIcon() => CustomPaint(painter: _BookOutlinePainter(_C.ink));
  Widget _starIcon() => CustomPaint(painter: _PathPainter.fill(_starIconPath, _C.gold));
  Widget _bookmarkIcon() =>
      CustomPaint(painter: _PathPainter.fill(_bookmarkIconPath, _C.ink, viewBoxSize: const Size(16, 20)));

  // ---- Logo + wordmark + tagline + dots --------------------------------

  Widget _buildContent() {
    final wordmark = CurvedAnimation(parent: _entrance, curve: const Interval(0.1875, 0.6875, curve: Curves.easeOut));
    final tagline = CurvedAnimation(parent: _entrance, curve: const Interval(0.34375, 0.84375, curve: Curves.easeOut));
    final dotsIn = CurvedAnimation(parent: _entrance, curve: const Interval(0.5, 1.0, curve: Curves.easeOut));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 168,
          height: 184,
          child: CustomPaint(painter: _LogoPainter(t: _t, osc: _osc)),
        ),
        const SizedBox(height: 22),
        _fadeSlide(
          wordmark,
          Text(
            'BooksNu',
            style: GoogleFonts.bricolageGrotesque(
              fontWeight: FontWeight.w800,
              fontSize: 42,
              letterSpacing: -0.5,
              color: _C.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _fadeSlide(
          tagline,
          Text(
            'Read more. Discover more.',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              letterSpacing: 0.2,
              color: _C.ink.withValues(alpha: 0.62),
            ),
          ),
        ),
        const SizedBox(height: 56),
        _fadeSlide(dotsIn, _buildLoadingDots()),
      ],
    );
  }

  Widget _fadeSlide(Animation<double> anim, Widget child) {
    return Opacity(
      opacity: anim.value.clamp(0.0, 1.0),
      child: Transform.translate(offset: Offset(0, 16 * (1 - anim.value)), child: child),
    );
  }

  Widget _buildLoadingDots() {
    Widget dot(double delay) {
      final o = _osc(1.4, delay: delay);
      return Transform.translate(
        offset: Offset(0, -8 * o),
        child: Opacity(
          opacity: 0.5 + 0.5 * o,
          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: _C.gold, shape: BoxShape.circle)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [dot(0), const SizedBox(width: 8), dot(0.16), const SizedBox(width: 8), dot(0.32)],
    );
  }
}

// ---- Logo painter: book pages + spine, ribbon, stars ---------------------
//
// Each shape keeps the exact path data from the source SVG (viewBox 0 0 200
// 220) and is transformed independently per frame, matching the original
// CSS animations one-for-one:
//   pages  — breathing scale, 3.2s, origin (100,170)
//   ribbon — sway rotate -4..5deg, 2.4s, origin (103,90)
//   stars  — twinkle opacity+scale, 1.8s, staggered 0/.4/.8s

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.t, required this.osc});

  final double t;
  final double Function(double period, {double delay}) osc;

  static const _viewBoxSize = Size(200, 220);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _viewBoxSize.width, size.height / _viewBoxSize.height);

    _paintPages(canvas);
    _paintRibbon(canvas);
    _paintStars(canvas);

    canvas.restore();
  }

  void _paintPages(Canvas canvas) {
    final scale = 1.0 + 0.035 * osc(3.2);
    canvas.save();
    canvas.translate(100, 170);
    canvas.scale(scale);
    canvas.translate(-100, -170);
    canvas.drawPath(parseSvgPathData(_pagesLeftPath), Paint()..color = _C.cream);
    canvas.drawPath(parseSvgPathData(_pagesRightPath), Paint()..color = _C.creamDeep);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(97, 76, 6, 96), const Radius.circular(3)),
      Paint()..color = _C.spine,
    );
    canvas.restore();
  }

  void _paintRibbon(Canvas canvas) {
    final angleDeg = -4 + 9 * osc(2.4);
    canvas.save();
    canvas.translate(103, 90);
    canvas.rotate(angleDeg * math.pi / 180);
    canvas.translate(-103, -90);
    canvas.drawPath(parseSvgPathData(_ribbonPath), Paint()..color = _C.gold);
    canvas.restore();
  }

  void _paintStars(Canvas canvas) {
    void star(String d, Offset center, Color color, {double delay = 0, double baseOpacity = 1}) {
      final o = osc(1.8, delay: delay);
      final opacity = (0.35 + 0.65 * o) * baseOpacity;
      final scale = 0.8 + 0.4 * o;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawPath(parseSvgPathData(d), Paint()..color = color.withValues(alpha: opacity.clamp(0.0, 1.0)));
      canvas.restore();
    }

    star(_star1Path, const Offset(44, 46), _C.gold);
    star(_star2Path, const Offset(170, 107), _C.plum, delay: 0.4);
    star(_star3Path, const Offset(55, 135), _C.gold, delay: 0.8, baseOpacity: 0.8);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) => true;
}

// ---- Generic static-path painter (used for the 3 floating deco icons) ----

class _PathPainter extends CustomPainter {
  const _PathPainter(this.path, this.fillPaint, this.viewBoxSize);

  factory _PathPainter.fill(String d, Color color, {Size viewBoxSize = const Size(24, 24)}) =>
      _PathPainter(parseSvgPathData(d), Paint()..color = color, viewBoxSize);

  final Path path;
  final Paint fillPaint;
  final Size viewBoxSize;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / viewBoxSize.width, size.height / viewBoxSize.height);
    canvas.drawPath(path, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => false;
}

// Small book-outline deco icon — a rounded rect + one horizontal rule,
// matching the original <rect rx="2"> + <line> pair (not a single path).
class _BookOutlinePainter extends CustomPainter {
  const _BookOutlinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(3, 4, 18, 16), const Radius.circular(2)),
      paint,
    );
    canvas.drawLine(const Offset(3, 8), const Offset(21, 8), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BookOutlinePainter oldDelegate) => false;
}

// ---- Raw path data (unchanged from design-concept/og/Splash.dc.html) -----

const _pagesLeftPath =
    'M100 170 C 62 158, 28 150, 12 168 L12 78 C 28 60, 62 66, 100 80 Z';
const _pagesRightPath =
    'M100 170 C 138 158, 172 150, 188 168 L188 78 C 172 60, 138 66, 100 80 Z';
const _ribbonPath =
    'M103 90 C 118 60, 106 30, 128 8 C 131 24, 150 26, 152 8 C 149 34, 160 48, 173 40 C 150 56, 140 80, 122 92 Z';
const _star1Path = 'M40 42 l3.4 8.6 8.6 3.4 -8.6 3.4 -3.4 8.6 -3.4 -8.6 -8.6 -3.4 8.6 -3.4z';
const _star2Path = 'M167 104 l2.6 6.4 6.4 2.6 -6.4 2.6 -2.6 6.4 -2.6 -6.4 -6.4 -2.6 6.4 -2.6z';
const _star3Path = 'M52 132 l2.4 6 6 2.4 -6 2.4 -2.4 6 -2.4 -6 -6 -2.4 6 -2.4z';

// deco icons — star is a 24x24 viewBox, bookmark is 16x20 (passed explicitly
// as this painter's viewBoxSize at the call site above)
const _starIconPath = 'M12 2l1.9 5.9L20 10l-6.1 2.1L12 18l-1.9-5.9L4 10l6.1-2.1z';
const _bookmarkIconPath = 'M2 1h12a1 1 0 0 1 1 1v16l-7-4-7 4V2a1 1 0 0 1 1-1z';
