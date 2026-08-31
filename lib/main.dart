import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/hive_storage_service.dart';
import 'core/services/preferences_service.dart';

Future<void> main() async {
  // Per architecture.md §13 ("Lifecycle and Reliability"), all storage
  // must be initialized before the widget tree is built.
  WidgetsFlutterBinding.ensureInitialized();

  await HiveStorageService.instance.init();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        preferencesServiceProvider.overrideWithValue(
          PreferencesService(sharedPreferences),
        ),
      ],
      child: const CareCircleApp(),
    ),
  );
}
