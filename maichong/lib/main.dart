import 'package:flutter/material.dart';
import 'app.dart';
import 'data/services/storage_service.dart';
import 'data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await StorageService().init();

  // Try to initialize Supabase (will fail gracefully if not configured)
  try {
    await SupabaseService().init();
  } catch (e) {
    // Continue in local-only mode if Supabase is not configured
    debugPrint('Supabase not configured: $e');
    debugPrint('Running in local-only mode');
  }

  runApp(const App());
}
