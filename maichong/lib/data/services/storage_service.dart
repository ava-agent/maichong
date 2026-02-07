import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/event.dart';
import '../../domain/models/timeline.dart';
import '../repositories/event_repository.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  bool _isInitialized = false;
  EventRepositoryImpl? _eventRepository;

  bool get isInitialized => _isInitialized;
  EventRepositoryImpl get eventRepository {
    if (_eventRepository == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _eventRepository!;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive based on platform
      if (kIsWeb) {
        // For web, use in-memory storage (Hive works with IndexedStorage on web)
        await Hive.initFlutter();
      } else {
        // For mobile/desktop, use application documents directory
        final dir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(dir.path);
      }

      // Register adapters
      _registerAdapters();

      // Initialize repositories
      _eventRepository = EventRepositoryImpl();
      await _eventRepository!.init();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize StorageService: $e');
    }
  }

  void _registerAdapters() {
    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EventAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TimelineAdapter());
    }
  }

  Future<void> clearAllData() async {
    try {
      await eventRepository.clearAllEvents();

      // Clear web local storage if on web
      if (kIsWeb) {
        html.window.localStorage.clear();
      }
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  Future<void> close() async {
    if (_isInitialized) {
      await Hive.close();
      _isInitialized = false;
    }
  }
}
