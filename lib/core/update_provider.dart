/// Barrel for the app-update feature, kept so existing imports keep working
/// after the split into a service (`update/update_service.dart`), the
/// checking schedule (`update/update_checker.dart`) and the widgets
/// (`update/update_banner.dart`).
library;

export 'update/update_banner.dart';
export 'update/update_checker.dart';
export 'update/update_service.dart';
