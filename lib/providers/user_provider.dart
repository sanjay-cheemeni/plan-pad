import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/providers/auth_provider.dart';
import 'package:plan_pad/services/user_service.dart';

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(authStateProvider.select((a) => a.value?.uid));
  if (uid == null) return Stream.value(null);

  return  UserService.currentUser(uid);
});
