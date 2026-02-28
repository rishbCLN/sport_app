import 'package:flutter/material.dart';

/// PRISM Animation System — timing references & custom curves.
class PrismAnims {
  PrismAnims._();

  // ── Durations ─────────────────────────────────────────────────────────────
  static const Duration anticipate = Duration(milliseconds: 80);
  static const Duration action = Duration(milliseconds: 200);
  static const Duration settle = Duration(milliseconds: 150);
  static const Duration buttonTap = Duration(milliseconds: 160);
  static const Duration cardEntrance = Duration(milliseconds: 300);
  static const Duration staggerStep = Duration(milliseconds: 60);
  static const Duration scanLineSweep = Duration(seconds: 2);
  static const Duration orbGlow = Duration(milliseconds: 2000);
  static const Duration numberCountUp = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration modalScaleIn = Duration(milliseconds: 280);
  static const Duration particleEmit = Duration(milliseconds: 400);
  static const Duration confettiFall = Duration(seconds: 4);
  static const Duration profileOrbRotate = Duration(seconds: 5);
  static const Duration groundHologramRotate = Duration(seconds: 8);
  static const Duration autoScrollBanner = Duration(seconds: 5);

  // ── Curves ────────────────────────────────────────────────────────────────
  static const Curve explosiveIn = Curves.easeOutBack;
  static const Curve elasticSettle = Curves.elasticOut;
  static const Curve smoothOut = Curves.easeOutCubic;
  static const Curve momentum = Curves.easeInOutCubic;
  static const Curve gravity = Curves.easeIn;

  // ── PageRoute builders ────────────────────────────────────────────────────

  /// Forward navigation: subtle slide + fade from right
  static PageRouteBuilder<T> forward<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: smoothOut)),
            child: child,
          ),
        );
      },
      transitionDuration: pageTransition,
    );
  }

  /// Modal presentation: scale + fade, semi-transparent barrier
  static PageRouteBuilder<T> modal<T>(Widget page) {
    return PageRouteBuilder<T>(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.85),
      barrierDismissible: true,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: explosiveIn),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: modalScaleIn,
    );
  }

  /// Slide from bottom (for drawers / sheets animated as routes)
  static PageRouteBuilder<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.75),
      barrierDismissible: true,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: smoothOut)),
          child: child,
        );
      },
      transitionDuration: pageTransition,
    );
  }
}
