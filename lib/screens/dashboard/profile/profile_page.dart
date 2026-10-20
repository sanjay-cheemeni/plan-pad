import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/providers/auth_provider.dart';
import 'package:plan_pad/providers/profile_stats_provider.dart';
import 'package:plan_pad/providers/task_provider.dart';
import 'package:plan_pad/providers/user_provider.dart';
import 'package:plan_pad/shared/popup/logout_popup.dart';
import 'package:plan_pad/shared/widgets/sliding_widget.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final stats = ref.watch(profileStatsProvider).value;
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 214, 207, 145),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
      ),
      body: userState.when(
        data: (user) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Container(
                  width: double.maxFinite,

                  // height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),

                  child: Column(
                    children: [
                      CircleAvatar(
                        child: Text(
                          '${user?.name[0]}',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        radius: 45,
                      ),

                      SizedBox(height: 5),

                      Text(
                        '${user?.name}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '${user?.email}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w100,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                Container(
                  width: double.maxFinite,
                  height: 200,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),

                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Column(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      ProfileListItem(
                        title: 'Role',
                        desc: user?.roleLabel ?? '-',
                      ),
                      ProfileListItem(
                        title: 'Projects',
                        desc: (stats?.projects ?? 0).toString(),
                      ),
                      ProfileListItem(
                        title: 'Open Tasks',
                        desc: (stats?.openTasks ?? 0).toString(),
                      ),
                      ProfileListItem(
                        title: 'Member Since',
                        desc: DateFormat(
                          'MMMM yyyy',
                        ).format(user?.createdAt ?? DateTime.now()),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceHigh,
                      foregroundColor: AppColors.textSoft,
                      elevation: 0,
                    ),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _logout(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.surface,
                      elevation: 0,
                      side: const BorderSide(
                        color: AppColors.danger,
                        width: 1.5,
                      ),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(12),
                      // ),
                    ),
                    child: Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        error: ((error, stackTrace) => Text('$error')),
        loading: () => Center(
          child: const SizedBox(
            width: 50,
            height: 22,
            child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) async {
    try {
      final pending =
          ref
              .read(allTasksProvider)
              .value
              ?.where((t) => t.hasPendingWrites)
              .length ??
          0;

      final confirmed = await showLogoutDialog(
        context,
        pendingChanges: pending,
      );
      if (!confirmed) return;

      ref.read(showLoginSuccessProvider.notifier).state =
          false; // reset the login flag
      await ref.read(authServiceProvider).logout();
      // authStateProvider emits null, and your AuthGate sends the user to the login page
    } catch (er) {
      print('Error on logout: $er');
    }
  }
}

class ProfileListItem extends StatelessWidget {
  final String desc;

  final String title;

  const ProfileListItem({
    super.key,
    required String this.title,
    required String this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(
          '$title',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w100,
          ),
        ),
        Text(
          '$desc',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
