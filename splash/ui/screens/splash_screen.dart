import 'dart:math';
import 'dart:ui';
import 'package:code_fit/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../gen/locale_keys.g.dart';
import '../../../../core/services/storage_service.dart';
import '../../../onboarding/ui/screens/onboarding_screen.dart';
import '../../../home/ui/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particleController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _backgroundAnimation;

  final List<Particle> _particles = [];
  double _loadingProgress = 0.0;
  String _currentLoadingText = '';

  final List<String> _loadingTexts = [
    'Initializing...',
    'Loading Resources...',
    'Setting up Environment...',
    'Almost Ready...',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initializeAnimations();
    _initializeParticles();
    _startAnimationSequence();
    _simulateLoading();
  }

  void _initializeAnimations() {
    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
      ),
    );

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Background color animation
    _backgroundAnimation =
        ColorTween(
          begin: AppColors.streakFlame,
          end: const Color(0xFF1a1a1a),
        ).animate(
          CurvedAnimation(
            parent: _primaryController,
            curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
          ),
        );
  }

  void _initializeParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle());
    }
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _progressController.forward();
    _particleController.repeat();
    _primaryController.forward();
  }

  void _simulateLoading() async {
    for (int i = 0; i < _loadingTexts.length; i++) {
      setState(() {
        _currentLoadingText = _loadingTexts[i];
      });

      // Simulate loading progress
      double startProgress = _loadingProgress;
      double endProgress = (i + 1) / _loadingTexts.length;

      for (int j = 0; j <= 20; j++) {
        await Future.delayed(const Duration(milliseconds: 150));
        setState(() {
          _loadingProgress =
              startProgress + (endProgress - startProgress) * (j / 20);
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    final storage = await StorageService.getInstance();
    final isOnboardingComplete = storage.isOnboardingComplete();

    final Widget nextScreen = isOnboardingComplete
        ? const HomeScreen()
        : const OnboardingScreen();

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => nextScreen,
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_primaryController, _particleController]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundAnimation.value ?? AppColors.streakFlame,
                  (_backgroundAnimation.value ?? AppColors.streakFlame)
                      .withOpacity(0.8),
                  const Color(0xFF0d1421),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Particle background
                _buildParticleBackground(),

                // Glassmorphism effect
                _buildGlassmorphismLayer(),

                // Main content
                _buildMainContent(),

                // Loading progress
                _buildLoadingProgress(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticleBackground() {
    return CustomPaint(
      painter: ParticlePainter(_particles, _particleController.value),
      size: Size.infinite,
    );
  }

  Widget _buildGlassmorphismLayer() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo section
          AnimatedBuilder(
            animation: Listenable.merge([_logoController, _logoFadeAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _logoScaleAnimation.value,
                child: Transform.rotate(
                  angle: _logoRotateAnimation.value,
                  child: Opacity(
                    opacity: _logoFadeAnimation.value,
                    child: _buildLogo(),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 59.h),
          // Text section
          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _textSlideAnimation.value),
                child: Opacity(
                  opacity: _textFadeAnimation.value,
                  child: _buildTitle(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        Container(
          width: 180.w,
          height: 180.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Main logo container
        Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(35.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(-5, -5),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(35.r),
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          AppColors.streakFlame,
                          AppColors.streakFlame.withOpacity(0.8),
                        ],
                      ).createShader(bounds);
                    },
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: 70.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Inner pulse effect
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Container(
              width: 120.w + (20 * sin(_particleController.value * 2 * pi)),
              height: 120.w + (20 * sin(_particleController.value * 2 * pi)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.8)],
            ).createShader(bounds);
          },
          child: Text(
            LocaleKeys.app_name.tr(),
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 12.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Text(
            LocaleKeys.app_tagline.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingProgress() {
    return Positioned(
      bottom: 100.h,
      left: 40.w,
      right: 40.w,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Opacity(
            opacity: _progressAnimation.value,
            child: Column(
              children: [
                // Loading text
                Text(
                  _currentLoadingText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(height: 20.h),

                // Progress bar container
                Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: _loadingProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Progress percentage
                Text(
                  '${(_loadingProgress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Particle class for animated background
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  Particle()
    : x = Random().nextDouble(),
      y = Random().nextDouble(),
      vx = (Random().nextDouble() - 0.5) * 0.002,
      vy = (Random().nextDouble() - 0.5) * 0.002,
      size = Random().nextDouble() * 3 + 1,
      opacity = Random().nextDouble() * 0.5 + 0.2;

  void update(Size size) {
    x += vx;
    y += vy;

    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;

    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);
  }
}

// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(size);

      final offset = Offset(particle.x * size.width, particle.y * size.height);

      canvas.drawCircle(
        offset,
        particle.size *
            (0.5 + 0.5 * sin(animationValue * 2 * pi + particle.x * 10)),
        paint..color = Colors.white.withOpacity(particle.opacity * 0.6),
      );
    }

    // Draw connecting lines between nearby particles
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final distance = sqrt(
          pow((p1.x - p2.x) * size.width, 2) +
              pow((p1.y - p2.y) * size.height, 2),
        );

        if (distance < 100) {
          final linePaint = Paint()
            ..color = Colors.white.withOpacity(0.1 * (1 - distance / 100))
            ..strokeWidth = 1;

          canvas.drawLine(
            Offset(p1.x * size.width, p1.y * size.height),
            Offset(p2.x * size.width, p2.y * size.height),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
