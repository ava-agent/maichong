import 'package:flutter/material.dart';
import 'app.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await StorageService().init();

  runApp(const App());
}
