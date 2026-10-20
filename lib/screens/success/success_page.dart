import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/providers/auth_provider.dart';

class SuccessPage extends ConsumerStatefulWidget {
  final String name;

  const SuccessPage({super.key,required String this.name});
  @override
  ConsumerState<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends ConsumerState<SuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward().whenComplete(() {
        if (mounted) {
          ref.read(showLoginSuccessProvider.notifier).state = false;
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
   return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Check circle pops in with an elastic overshoot
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.elasticOut,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.background, size: 64),
              ),
            ),
            const SizedBox(height: 28),
            // Text slides up after a short delay
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              builder: (context, v, child) => Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, 24 * (1 - v)),
                  child: child,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Hello, ${widget.name}!',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text('You are signed in.'),
                  const SizedBox(height: 24),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}