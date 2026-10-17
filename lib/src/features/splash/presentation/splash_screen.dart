import 'dart:math' as math;

import 'package:animation_lesson/src/core/consts/app_colors.dart';
import 'package:animation_lesson/src/core/gen/assets.gen.dart';
import 'package:animation_lesson/src/core/utils/play_sound.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const double _minSheetFraction = 0.14;
  static const double _maxSheetFraction = 0.8;
  static const double _scalePhaseEnd = 0.23;
  static const double _rotatePhaseEnd = 0.82;
  static const double _liftPhaseStart = 0.82;

  // After the intro finishes, dragging the sheet only drives the lift phase,
  // so the logo slides back to center without rotating again.
  bool _introDone = false;

  late final AnimationController _sheetController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late AnimationController _rotateController;

  late AnimationController _translationController;
  late Animation<AlignmentGeometry> _transformAnimation;

  late AnimationController _logoScaleController;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
      value: 0,
    )
      ..addListener(_syncAnimationsToSheet)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _introDone = true;
      });

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 360.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.ease));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.ease));

    _translationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _transformAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.center,
      end: Alignment.topCenter,
    ).animate(
      CurvedAnimation(parent: _translationController, curve: Curves.ease),
    );

    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoScaleAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _logoScaleController, curve: Curves.decelerate),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sheetController.animateTo(1, curve: Curves.easeInOutCubic);
    });

    _rotateController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        PlaySound.playClickSound('audio/wind.mp3');
      } 
      if (status == AnimationStatus.completed) {
        PlaySound.playClickSound('audio/logo.mp3');
      }
    });
  }

  void _syncAnimationsToSheet() {
    final progress = _sheetController.value;
    _scaleController.value = _phaseValue(progress, 0.0, _scalePhaseEnd);
    _rotateController.value = _phaseValue(
      progress,
      _scalePhaseEnd,
      _rotatePhaseEnd,
    );
    _translationController.value = _phaseValue(progress, _liftPhaseStart, 1.0);
    _logoScaleController.value = _phaseValue(progress, _liftPhaseStart, 1.0);
    if (mounted) {
      setState(() {});
    }
  }

  double _phaseValue(double progress, double start, double end) {
    if (progress <= start) return 0;
    if (progress >= end) return 1;
    return (progress - start) / (end - start);
  }

  void _handleSheetDragUpdate(DragUpdateDetails details, double dragRange) {
    _sheetController.stop();
    final delta = details.primaryDelta ?? 0;
    final minValue = _introDone ? _liftPhaseStart : 0.0;
    final range = 1.0 - minValue;
    _sheetController.value =
        (_sheetController.value - (delta / dragRange) * range).clamp(
      minValue,
      1.0,
    );
  }

  void _handleSheetDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final minValue = _introDone ? _liftPhaseStart : 0.0;
    final midpoint = (minValue + 1.0) / 2;
    final target = velocity.abs() > 300
        ? (velocity < 0 ? 1.0 : minValue)
        : (_sheetController.value >= midpoint ? 1.0 : minValue);

    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _rotateController.dispose();
    _scaleController.dispose();
    _translationController.dispose();
    _logoScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final liftProgress = _phaseValue(
      _sheetController.value,
      _liftPhaseStart,
      1.0,
    );
    final sheetHeight = size.height *
        (_minSheetFraction +
            ((_maxSheetFraction - _minSheetFraction) * liftProgress));
    final dragRange = size.height * (_maxSheetFraction - _minSheetFraction);
    final backgroundColor = Color.lerp(
      AppColors.background,
      AppColors.primary,
      liftProgress,
    );

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            AlignTransition(
              alignment: _transformAnimation,
              child: AnimatedBuilder(
                animation: _logoScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _rotateAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateAnimation.value * math.pi / 180,
                            child: child,
                          );
                        },
                        child: Assets.icons.arc.svg(),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) =>
                    _handleSheetDragUpdate(details, dragRange),
                onVerticalDragEnd: _handleSheetDragEnd,
                child: Container(
                  height: sheetHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      _introDone
                          ? AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              width: 56,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
