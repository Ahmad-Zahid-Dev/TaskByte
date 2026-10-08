import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_strings.dart';

abstract final class SnackBarHelper {
  static void showTaskDeleted(
    BuildContext context, {
    required VoidCallback onUndo,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    // Dismiss any existing snackbars immediately so it never stacks or gets stuck
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 20),
            SizedBox(width: 10),
            Text(
              AppStrings.taskDeleted,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        // Crucial: Float well above the docked FloatingActionButton and BottomAppBar
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 82),
        duration: const Duration(seconds: 4),
        elevation: 8,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dismissDirection: DismissDirection.horizontal,
        action: SnackBarAction(
          label: AppStrings.undo,
          textColor: AppColors.primaryLight,
          onPressed: () {
            messenger.hideCurrentSnackBar();
            onUndo();
          },
        ),
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 82),
        duration: const Duration(seconds: 3),
        elevation: 8,
        backgroundColor: AppColors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
