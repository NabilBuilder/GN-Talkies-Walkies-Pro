import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Reusable error dialog for displaying user-friendly error messages.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
  });

  /// Shows the error dialog with localized default title.
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    String? details,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title ?? AppLocalizations.of(context)!.error,
        message: message,
        details: details,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      icon: const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 48,
      ),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (details != null) ...[
            const SizedBox(height: 8),
            Text(
              details!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Retry callback could be added here
          },
          child: Text(l10n.tryAgain),
        ),
      ],
    );
  }
}

/// Reusable empty state widget for lists with no data.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable loading indicator widget.
/// Création & Développement : Boukhoulkhal Nabil (2026)
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF1B5E20),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
