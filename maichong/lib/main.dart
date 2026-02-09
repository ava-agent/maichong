import 'package:flutter/material.dart';
import 'app.dart';
import 'data/services/storage_service.dart';
import 'data/services/supabase_service.dart';
import 'data/services/ai_service.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await StorageService().init();
  await ThemeController().load();

  // Try to initialize Supabase (will fail gracefully if not configured)
  try {
    await SupabaseService().init();
  } catch (e) {
    // Continue in local-only mode if Supabase is not configured
    debugPrint('Supabase not configured: $e');
    debugPrint('Running in local-only mode');
  }

  // Try to initialize AI service (will fail gracefully if not configured)
  try {
    final aiService = AIService();
    final initialized = await aiService.init();
    if (initialized) {
      debugPrint('AI service initialized successfully');
    } else {
      debugPrint('AI service not configured (no API key found)');
    }
  } catch (e) {
    debugPrint('AI service initialization failed: $e');
    debugPrint('AI features will run in demo mode');
  }

  runApp(const App());
}
