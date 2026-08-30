import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';

/// Overridden in main() once the real instances are available at startup.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider not overridden'),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => throw UnimplementedError('secureStorageProvider not overridden'),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => throw UnimplementedError('apiClientProvider not overridden'),
);
