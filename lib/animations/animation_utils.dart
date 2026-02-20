import 'package:flutter/material.dart';

/// 애니메이션 유틸리티
/// 자주 사용하는 Curves, Durations, Tween 헬퍼

// ====================
// Custom Curves
// ====================

class AppCurves {
  AppCurves._();

  /// Expo Ease Out - 빠르게 시작해서 부드럽게 멈춤
  static const Cubic easeOutExpo = Cubic(0.16, 1, 0.3, 1);

  /// Quart Ease In Out - 부드러운 가속/감속
  static const Cubic easeInOutQuart = Cubic(0.76, 0, 0.24, 1);

  /// Spring - 탄성 효과
  static const Cubic spring = Cubic(0.34, 1.56, 0.64, 1);

  /// Decelerate - 감속 효과
  static const Cubic decelerate = Cubic(0.0, 0.0, 0.2, 1);

  /// Accelerate - 가속 효과
  static const Cubic accelerate = Cubic(0.4, 0.0, 1, 1);

  /// Bounce Out - 튕기는 효과
  static const Cubic bounceOut = Cubic(0.34, 1.56, 0.64, 1);

  /// Smooth - 매우 부드러운 전환
  static const Cubic smooth = Cubic(0.45, 0, 0.55, 1);
}

// ====================
// Duration Constants
// ====================

class AppDurations {
  AppDurations._();

  /// Ultra fast - 50ms (micro-interactions)
  static const Duration ultraFast = Duration(milliseconds: 50);

  /// Fast - 150ms (button presses, small transitions)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal - 300ms (standard transitions)
  static const Duration normal = Duration(milliseconds: 300);

  /// Medium - 500ms (page transitions)
  static const Duration medium = Duration(milliseconds: 500);

  /// Slow - 800ms (complex animations)
  static const Duration slow = Duration(milliseconds: 800);

  /// Very slow - 1200ms (emphasis animations)
  static const Duration verySlow = Duration(milliseconds: 1200);
}

// ====================
// Tween Utilities
// ====================

class TweenUtils {
  TweenUtils._();

  /// Scale Tween (0.0 to 1.0)
  static Animation<double> scale(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<double>(begin: begin, end: end)
        .chain(CurveTween(curve: curve))
        .animate(controller);
  }

  /// Fade Tween (0.0 to 1.0)
  static Animation<double> fade(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: begin, end: end)
        .chain(CurveTween(curve: curve))
        .animate(controller);
  }

  /// Slide Tween (from offset to zero)
  static Animation<Offset> slide(
    AnimationController controller, {
    Offset begin = const Offset(0, 1),
    Curve curve = Curves.easeOutCubic,
  }) {
    return Tween<Offset>(begin: begin, end: Offset.zero)
        .chain(CurveTween(curve: curve))
        .animate(controller);
  }

  /// Slide from left
  static Animation<Offset> slideFromLeft(AnimationController controller) {
    return slide(controller, begin: const Offset(-1, 0));
  }

  /// Slide from right
  static Animation<Offset> slideFromRight(AnimationController controller) {
    return slide(controller, begin: const Offset(1, 0));
  }

  /// Slide from top
  static Animation<Offset> slideFromTop(AnimationController controller) {
    return slide(controller, begin: const Offset(0, -1));
  }

  /// Slide from bottom
  static Animation<Offset> slideFromBottom(AnimationController controller) {
    return slide(controller, begin: const Offset(0, 1));
  }

  /// Rotate Tween
  static Animation<double> rotate(
    AnimationController controller, {
    double turns = 1.0,
    Curve curve = Curves.linear,
  }) {
    return Tween<double>(begin: 0.0, end: turns)
        .chain(CurveTween(curve: curve))
        .animate(controller);
  }

  /// Color Tween
  static Animation<Color?> color(
    AnimationController controller, {
    required Color begin,
    required Color end,
    Curve curve = Curves.easeInOut,
  }) {
    return ColorTween(begin: begin, end: end)
        .chain(CurveTween(curve: curve))
        .animate(controller);
  }

  /// Border Radius Tween
  static Animation<BorderRadius?> borderRadius(
    AnimationController controller, {
    required BorderRadius begin,
    required BorderRadius end,
    Curve curve = Curves.easeInOut,
  }) {
    return BorderRadiusTween(begin: begin, end: end)
        .chain(CurveTween(curve: curve))
        .animate(controller);
  }

  /// Staggered Tween - 지연 후 시작
  static Animation<double> staggered(
    AnimationController controller, {
    required double startInterval,
    required double endInterval,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: begin, end: end)
        .chain(CurveTween(curve: curve))
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(startInterval, endInterval),
          ),
        );
  }
}

// ====================
// Animation Controller Extensions
// ====================

extension AnimationControllerExtension on AnimationController {
  /// Forward and auto-reverse
  Future<void> forwardAndReverse() async {
    await forward();
    await reverse();
  }

  /// Forward with completion callback
  void forwardThen(VoidCallback onComplete) {
    forward().then((_) => onComplete());
  }

  /// Repeat with count limit
  void repeatCount(int count) {
    int currentCount = 0;
    addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        currentCount++;
        if (currentCount < count) {
          reverse();
        }
      } else if (status == AnimationStatus.dismissed && currentCount < count) {
        forward();
      }
    });
    forward();
  }
}

// ====================
// Animation Extensions
// ====================

extension AnimationExtension<T> on Animation<T> {
  /// Add listener with auto-remove option
  void addOneTimeListener(VoidCallback listener) {
    late VoidCallback wrappedListener;
    wrappedListener = () {
      listener();
      removeListener(wrappedListener);
    };
    addListener(wrappedListener);
  }

  /// Chain with another curve
  Animation<T> withCurve(Curve curve) {
    return drive(CurveTween(curve: curve));
  }
}

// ====================
// Staggered Animation Builder
// ====================

class StaggeredAnimationBuilder extends StatelessWidget {
  final AnimationController controller;
  final List<Widget> children;
  final double staggerInterval;
  final Duration delay;
  final Widget Function(BuildContext context, Widget child, Animation<double> animation) builder;

  const StaggeredAnimationBuilder({
    super.key,
    required this.controller,
    required this.children,
    this.staggerInterval = 0.1,
    this.delay = Duration.zero,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              (index * staggerInterval) + (delay.inMilliseconds / 1000),
              ((index + 1) * staggerInterval) + (delay.inMilliseconds / 1000),
              curve: Curves.easeOut,
            ),
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) => builder(context, child, animation),
        );
      }).toList(),
    );
  }
}

// ====================
// Fade In Animation Widget
// ====================

class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.offset = const Offset(0, 20),
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ====================
// Animated Value Builder
// ====================

class AnimatedValueBuilder<T> extends StatelessWidget {
  final AnimationController controller;
  final T begin;
  final T end;
  final Curve curve;
  final Widget Function(BuildContext context, T value) builder;

  const AnimatedValueBuilder({
    super.key,
    required this.controller,
    required this.begin,
    required this.end,
    this.curve = Curves.easeInOut,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final Animation<T> animation;

    if (T == double) {
      animation = Tween<double>(begin: begin as double, end: end as double)
          .chain(CurveTween(curve: curve))
          .animate(controller) as Animation<T>;
    } else if (T == int) {
      animation = IntTween(begin: begin as int, end: end as int)
          .chain(CurveTween(curve: curve))
          .animate(controller) as Animation<T>;
    } else if (T == Offset) {
      animation = Tween<Offset>(begin: begin as Offset, end: end as Offset)
          .chain(CurveTween(curve: curve))
          .animate(controller) as Animation<T>;
    } else if (T == Color) {
      animation = ColorTween(begin: begin as Color, end: end as Color)
          .chain(CurveTween(curve: curve))
          .animate(controller) as Animation<T>;
    } else {
      throw UnsupportedError('Type $T is not supported');
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => builder(context, animation.value),
    );
  }
}
