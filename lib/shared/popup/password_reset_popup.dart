import 'package:flutter/material.dart';
import 'package:plan_pad/core/validator.dart';
import 'package:plan_pad/core/values/app_colors.dart';

/// Returns the entered email, or null if the user cancels.
Future<String?> showPasswordResetDialog(
  BuildContext context, {
  String initialEmail = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _PasswordResetDialog(initialEmail: initialEmail),
  );
}

class _PasswordResetDialog extends StatefulWidget {
  const _PasswordResetDialog({required this.initialEmail});
  final String initialEmail;

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final error = Validators.ValidateEmail(_email.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, _email.text.trim());
  }

  _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide.none,
  );

  // OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(15),
  //       borderSide: color == null
  //           ? BorderSide.none
  //           : BorderSide(color: color, width: 1.5),
  //     );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: AppColors.background,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reset password',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your email and we will send you a link to set a new password.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Mail Id',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),

                filled: true,
                fillColor: AppColors
                    .background, // darker than the dialog, so the field stands out
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 15,
                ),
                border: _border(),
                enabledBorder: _border(),
                focusedBorder: _border(AppColors.primary),
                errorBorder: _border(AppColors.error),
                focusedErrorBorder: _border(AppColors.error),
                errorText: _error,
                errorStyle: const TextStyle(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surfaceHigh,
                        foregroundColor: AppColors.textSoft,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'Send link',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
