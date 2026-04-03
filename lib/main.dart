import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/app_state.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);
  final appState = AppState(storage);

  runApp(
    AppStateScope(
      state: appState,
      child: const CalmCompanionApp(),
    ),
  );
}
