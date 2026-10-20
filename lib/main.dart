import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/core/theme/app_theme.dart';
import 'package:plan_pad/providers/auth_provider.dart';
import 'package:plan_pad/screens/dashboard/base_page.dart/base_page.dart';
import 'package:plan_pad/screens/loader/loader_page.dart';
import 'package:plan_pad/screens/login/login_page.dart';
import 'package:plan_pad/screens/splash/splash_screen.dart';
import 'package:plan_pad/screens/success/success_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //
    ///  [auth]

    //

    return MaterialApp(
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(nextPage: Authgate())
    );
  }
}

class Authgate extends ConsumerWidget {
  const Authgate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
        data: (user) {
          final userName =
              user?.displayName ?? user?.email?.split('@').first ?? 'User';

          final showSuccess = ref.watch(showLoginSuccessProvider);
          if (user == null) return const LoginPage();
          if (showSuccess) return SuccessPage(name: userName); // your animation
          return const BasePage();
        },
        error: (e, s) => const LoginPage(),
        loading: () => const LoaderPage(),
      );
  }
}
