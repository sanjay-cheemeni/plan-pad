import 'dart:math';

import 'package:plan_pad/models/app_user.dart';

class Validators {
  Validators._();

  static String? ValidateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  static checkEmailAndPassword(email, password) {
    final emailValidation = ValidateEmail(email);
    if (emailValidation != null) throw emailValidation;

    final passwordValidation = validatePassword(password);
    if (passwordValidation != null) throw passwordValidation;
  }

  static String? validateUser(AppUser? user) {
    if (user == null) throw 'Please log in again';
    return null;
  }

  static String? validateProjectName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Project name is required';
    if (name.length < 2) return 'Project name must be at least 2 characters';
    if (name.length > 50) return 'Project name must be 50 characters or less';
    return null;
  }

  static String? validateProjectDescription(String? value) {
    if ((value?.trim().length ?? 0) > 200) {
      return 'Description must be 200 characters or less';
    }
    return null;
  }

  static void checkProject(
    AppUser? user,
    String name,
    String description, {
    required Iterable<String> existingNames,
  }) {
    final userError = validateUser(user);
    if (userError != null) throw userError;

    final nameError = validateProjectName(name);
    if (nameError != null) throw nameError;

    final descError = validateProjectDescription(description);
    if (descError != null) throw descError;

    final n = name.trim().toLowerCase();
    if (existingNames.any((e) => e.trim().toLowerCase() == n)) {
      throw 'A project named "${name.trim()}" already exists';
    }
  }

  static String? validateTaskTitle(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Task title is required';
    if (t.length < 3) return 'Task title must be at least 3 characters';
    if (t.length > 100) return 'Task title must be 100 characters or less';
    return null;
  }

  static String? validateTaskDescription(String? v) {
    if ((v?.trim().length ?? 0) > 500)
      return 'Description must be 500 characters or less';
    return null;
  }

  static void checkTask({
    required String projectId,
    required String title,
    required String description,
    required String type,
    required String priority,
    required String assigneeId,
    required DateTime? dueDate,
  }) {
    if (projectId.isEmpty) throw 'Select a project';
    final titleError = validateTaskTitle(title);
    if (titleError != null) throw titleError;
    final descError = validateTaskDescription(description);
    if (descError != null) throw descError;
    if (!['task', 'bug'].contains(type)) throw 'Select Task or Bug';
    if (!['urgent', 'high', 'medium', 'low'].contains(priority))
      throw 'Select a priority';
    if (assigneeId.isEmpty) throw 'Select who to assign this task to';
    if (dueDate == null)
      throw 'Select a due date'; // the task list query needs dueDate
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (DateTime(dueDate.year, dueDate.month, dueDate.day).isBefore(today)) {
      throw 'Due date cannot be in the past';
    }
  }

  static void checkStatusChange({
    required String from,
    required String to,
    required bool canReopen,
  }) {
    const statuses = [
      'todo',
      'in_progress',
      'in_review',
      'blocked',
      'done',
      'cancelled',
    ];
    if (!statuses.contains(to)) throw 'Select a valid status';
    if (from == to) throw 'Task is already in this status';
    final closed = from == 'done' || from == 'cancelled';
    if (closed && !canReopen) throw 'Only managers can reopen a closed task';
  }

  static void checkProjectMembers(Map<String, String> members) {
  const roles = ['manager', 'dev', 'test'];
  for (final role in members.values) {
    if (!roles.contains(role)) throw 'Select a role for every member';
  }
}
}
