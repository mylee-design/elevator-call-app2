import 'package:flutter/material.dart';

/// 페이지 전환 애니메이션
/// Material Motion Guidelines 기반

enum SlideDirection {
  left,
  right,
  up,
  down,
}

class PageTransitions {
  PageTransitions._();

  // ====================
  // Slide Transition
  // ====================

  static Route<T> slide<T>(
    Widget page, {
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final beginOffset = switch (direction) {
          SlideDirection.left => const Offset(-1.0, 0.0),
          SlideDirection.right => const Offset(1.0, 0.0),
          SlideDirection.up => const Offset(0.0, 1.0),
          SlideDirection.down => const Offset(0.0, -1.0),
        };

        final tween = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // ====================
  // Fade Transition
  // ====================

  static Route<T> fade<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        );
      },
    );
  }

  // ====================
  // Scale Transition
  // ====================

  static Route<T> scale<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  // ====================
  // Slide and Fade Transition
  // ====================

  static Route<T> slideAndFade<T>(
    Widget page, {
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final beginOffset = switch (direction) {
          SlideDirection.left => const Offset(-0.5, 0.0),
          SlideDirection.right => const Offset(0.5, 0.0),
          SlideDirection.up => const Offset(0.0, 0.5),
          SlideDirection.down => const Offset(0.0, -0.5),
        };

        final offsetTween = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(offsetTween),
          child: FadeTransition(
            opacity: animation.drive(CurveTween(curve: curve)),
            child: child,
          ),
        );
      },
    );
  }

  // ====================
  // Shared Axis Transition (Material Motion)
  // ====================

  static Route<T> sharedAxis<T>(
    Widget page, {
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final beginOffset = switch (direction) {
          SlideDirection.left => const Offset(-30.0, 0.0),
          SlideDirection.right => const Offset(30.0, 0.0),
          SlideDirection.up => const Offset(0.0, 30.0),
          SlideDirection.down => const Offset(0.0, -30.0),
        };

        final positionTween = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));

        final scaleTween = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: animation.drive(positionTween).value,
              child: Transform.scale(
                scale: animation.drive(scaleTween).value,
                child: FadeTransition(
                  opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
                  child: child,
                ),
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  // ====================
  // Hero Transition Helper
  // ====================

  static Widget hero({
    required String tag,
    required Widget child,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  // ====================
  // Fade Through Transition
  // ====================

  static Route<T> fadeThrough<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}

// ====================
// Custom Transitions
// ====================

class FadeThroughTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const FadeThroughTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
        ).value;

        final scale = Tween<double>(begin: 0.92, end: 1.0).transform(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
          ).value,
        );

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ====================
// Page Transition Theme
// ====================

class AppPageTransitionsTheme extends PageTransitionsTheme {
  static const PageTransitionsBuilder builder = _AppPageTransitionBuilder();

  const AppPageTransitionsTheme() : super(builders: const {
    TargetPlatform.android: builder,
    TargetPlatform.iOS: builder,
    TargetPlatform.macOS: builder,
    TargetPlatform.windows: builder,
    TargetPlatform.linux: builder,
    TargetPlatform.fuchsia: builder,
  });
}

class _AppPageTransitionBuilder extends PageTransitionsBuilder {
  const _AppPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
