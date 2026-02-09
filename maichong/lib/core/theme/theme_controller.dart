import 'package:flutter/material.dart';
import '../../data/services/storage_service.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();

  factory ThemeController() => _instance;

  ThemeController._internal();

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    _mode = StorageService().getThemeMode();
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    await StorageService().setThemeMode(mode);
    notifyListeners();
  }
}
