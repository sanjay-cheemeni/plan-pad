import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plan_pad/core/validator.dart';
import 'package:plan_pad/services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final showLoginSuccessProvider = StateProvider<bool>((ref) => false);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authChanges,
);

class LoginController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    ref.read(showLoginSuccessProvider.notifier).state = true;

    state = await AsyncValue.guard(() async {
      // Validations
      Validators.checkEmailAndPassword(email, password);

      await ref
          .read(authServiceProvider)
          .login(email: email, password: password);
    });

    if (state.hasError) {
      ref.read(showLoginSuccessProvider.notifier).state = false;
    }
  }
}

final loginControllerProvider = AsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);
