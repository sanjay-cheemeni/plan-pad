import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plan_pad/core/values/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({super.key, required this.nextPage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => widget.nextPage,
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg_splash,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacer(),
            Image.asset('assets/plan_pad_logo.png', width: 120, height: 120),

            const SizedBox(height: 24),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
                children: [
                  TextSpan(
                    text: 'Plan',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'Pad',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),

            const Text(
              'Plan less. Do more.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 32),
            Spacer(),

            const SizedBox(
              width: 50,
              height: 22,
              child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
