
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_pad/models/app_user.dart';

class UserService {
  UserService._();

  static Stream<AppUser?> currentUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          return doc.exists ? AppUser.fromDoc(doc) : null;
        });
  }
}