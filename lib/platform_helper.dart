import 'dart:io' show Platform;

/// Platform detection helper.
/// Création & Développement : Boukhoulkhal Nabil (2026)
bool get isDesktop =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

bool get isMobile => Platform.isAndroid || Platform.isIOS;
