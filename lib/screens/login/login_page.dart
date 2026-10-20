import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plan_pad/core/errors.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/providers/auth_provider.dart';
import 'package:plan_pad/shared/popup/password_reset_popup.dart';
import 'package:plan_pad/shared/widgets/snackbar.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final state = ref.watch(loginControllerProvider);

    // One-time side effects (e.g. snackbar) on error
    ref.listen<AsyncValue<void>>(loginControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        AppSnackbar.error(context, errorMessage(next.error));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // mainAxisAlignment: .center,
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Text(
                  'PlanPad',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  'Offline ready',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Text(
                  'Take',
                  style: TextStyle(
                    fontSize: 35,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Center(
                    child: Text(
                      'control',
                      style: TextStyle(
                        fontSize: 35,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                'of your tasks',
                style: TextStyle(
                  height: 1,
                  fontSize: 35,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                'Plan work by priority, assign it to your team and keep every update on record.',

                style: TextStyle(
                  height: 1.2,
                  fontSize: 13,
                  fontWeight: FontWeight.w100,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Spacer(),

            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    height: 2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextField(
                  enabled: !state.isLoading,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    // fillColor: Colors.grey.shade100,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 12,
                    height: 2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextField(
                  enabled: !state.isLoading,
                  controller: _password,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    suffixIcon: GestureDetector(
                      onTap: toggleShowPassword,
                      child: Icon(
                        !_showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    // fillColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),

            //! # =================================================================
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: !state.isLoading ? onLoginPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  elevation: 0,
                ),
                child: state.isLoading
                    ? const SpinKitThreeBounce(
                        color: AppColors.primary,
                        size: 25,
                      )
                    : Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            if (!isKeyboardVisible) ...[
              SizedBox(height: 15),

              GestureDetector(
                onTap: () => showForgotPasswordPopup(),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSoft,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // fns...
  void onLoginPressed() {
    final email = _email.text.trim();
    final password = _password.text.trim();
    ref.read(loginControllerProvider.notifier).login(email, password);
  }

  void showForgotPasswordPopup() async {
    final mailId = await showPasswordResetDialog(context);

    if (mailId != null) {
      ref.watch(authServiceProvider).sentResetLink(mailId);
      AppSnackbar.success(context, 'Password reset mail sent to $mailId.');
    }
  }
}
