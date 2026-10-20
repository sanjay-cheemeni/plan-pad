import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/screens/dashboard/home/home_page.dart';
import 'package:plan_pad/screens/dashboard/profile/profile_page.dart';
import 'package:plan_pad/screens/dashboard/project/project_page.dart';
import 'package:plan_pad/screens/dashboard/task/task_page.dart';

class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  @override
  ConsumerState<BasePage> createState() => _BasePageState();
}

class _BasePageState extends ConsumerState<BasePage> {
  final _screens = const [HomePage(), TaskPage(), ProjectPage(), ProfilePage()];

  final PageController _pageController = PageController();

  int currentScreenIndex = 0;

  final List<String> _labels = const ['Home', 'Tasks', 'Projects', 'Profile'];

  void _onItemSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: _screens,
            onPageChanged: (index) {
              setState(() {
                currentScreenIndex = index;
              });
            },
          ),
          if (!isKeyboardVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Container(
                    height: 55,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth / 4;

                        return Stack(
                          children: [
                            // Sliding selection indicator
                            AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                final page = _pageController.hasClients
                                    ? (_pageController.page ?? 0.0)
                                    : 0.0;

                                return Positioned(
                                  left: page * itemWidth,
                                  top: 0,
                                  bottom: 0,
                                  width: itemWidth,
                                  child: child!,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),

                            // Navigation items
                            Row(
                              children: List.generate(4, (index) {
                                final isSelected = currentScreenIndex == index;

                                return Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(40),
                                    onTap: () => _onItemSelected(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: Center(
                                        child: Text(
                                          _labels[index],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: isSelected
                                                ? AppColors.background
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
