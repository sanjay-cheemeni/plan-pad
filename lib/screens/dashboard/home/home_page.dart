import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/providers/dashboard_provider.dart';
import 'package:plan_pad/providers/user_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      body: statsAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 50,
            height: 22,
            child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
          ),
        ),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load dashboard: $error')),
        data: (stats) {
          return Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      'Hello, ${user?.name}',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      child: Text(
                        '${user?.roleLabel}',
                        style: TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Text(
                  'Task\nPlanner',
                  style: TextStyle(
                    fontSize: 35,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'You have ${stats.urgent} urgent tasks today.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 20),

                SizedBox(
                  height: 220,
                  child: GridView(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.7,
                        ),
                    children: [
                      TaskStatItem(
                        backgroudColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        title: 'To Do',
                        value: stats.todo.toString(),
                      ),
                      TaskStatItem(
                        backgroudColor: AppColors.surface,
                        foregroundColor: AppColors.textSoft,
                        title: 'In Progress',
                        value: stats.inProgress.toString(),
                      ),
                      TaskStatItem(
                        backgroudColor: AppColors.surface,
                        foregroundColor: AppColors.textSoft,
                        title: 'In Review',
                        value: stats.inReview.toString(),
                      ),
                      TaskStatItem(
                        backgroudColor: AppColors.surface,
                        foregroundColor: AppColors.textSoft,
                        title: 'Overdue',
                        value: stats.overdue.toString(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2),

                Container(
                  // height: 130,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: .end,
                        children: [
                          Text(
                            'Done this week',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${stats.doneThisWeek}',
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.1,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '/${stats.weeklyTarget}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      LinearProgressIndicator(
                        value: stats.doneThisWeek / stats.weeklyTarget,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(20),
                        backgroundColor: const Color(0xFF373943),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFC4F638),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          PrioritStatItem(
                            title: 'Urgent',
                            value: '${stats.urgent}',
                            bcakgroundColor: AppColors.urgentBg,
                            foregroundColor: AppColors.urgentFg,
                          ),
                          PrioritStatItem(
                            title: 'High',
                            value: '${stats.high}',
                            bcakgroundColor: AppColors.highBg,
                            foregroundColor: AppColors.highFg,
                          ),
                          PrioritStatItem(
                            title: 'Medium',
                            value: '${stats.medium}',
                            bcakgroundColor: AppColors.mediumBg,
                            foregroundColor: AppColors.mediumFg,
                          ),
                          PrioritStatItem(
                            title: 'Low',
                            value: '${stats.low}',
                            bcakgroundColor: AppColors.lowBg,
                            foregroundColor: AppColors.lowFg,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Text('${stats.todo}'), // To Do
                // Text('${stats.inProgress}'), // In Progress
                // Text('${stats.inReview}'), // In Review
                // Text('${stats.overdue}'), // Overdue
                // Text('${stats.doneThisWeek}/${stats.weeklyTarget}'),
                // Text('Urgent ${stats.urgent}'),
                // Text('High ${stats.high}'),
                // Text('Medium ${stats.medium}'),
                // Text('Low ${stats.low}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PrioritStatItem extends StatelessWidget {
  const PrioritStatItem({
    super.key,
    required this.title,
    required this.value,
    required this.bcakgroundColor,
    required this.foregroundColor,
  });

  final String title;
  final String value;
  final Color bcakgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: bcakgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text(
        '${title} $value',
        style: TextStyle(
          color: foregroundColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TaskStatItem extends StatelessWidget {
  const TaskStatItem({
    super.key,
    required this.backgroudColor,
    required this.foregroundColor,
    required this.title,
    required this.value,
  });
  final backgroudColor;
  final foregroundColor;
  final title;
  final value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: backgroudColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
          ),
          Text(
            '$title',
            style: TextStyle(
              fontSize: 12,
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
