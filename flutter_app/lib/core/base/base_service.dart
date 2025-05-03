import 'dart:async';

import '../services/firebase_service.dart';
import '../services/logger_service.dart';

class Service {
  static final Service _instance = Service._internal();
  static Service get instance => _instance;

  // Private constructor
  Service._internal();

  /// Inisialisasi seluruh layanan yang dibutuhkan sebelum aplikasi dijalankan
  static Future<void> init() async {
    try {
      // Inisialisasi Logger terlebih dahulu untuk bisa mencatat progress inisialisasi lainnya
      final logger = LoggerService.instance;

      // Inisialisasi Firebase
      await initFirebase();

      logger.i('✅ All services initialized successfully!', tag: 'SERVICE');
    } catch (e, stackTrace) {
      LoggerService.instance.e(
        '❌ Error initializing application services',
        error: e,
        stackTrace: stackTrace,
        tag: 'SERVICE',
      );
      rethrow;
    }
  }

  /// Determine the initial route based on application state
  static Future<String> determineInitialRoute() async {
    try {
      // Use the InitialRouteService to determine the initial route
      return '/';
    } catch (e, stackTrace) {
      LoggerService.instance.e(
        '❌ Error determining initial route',
        error: e,
        stackTrace: stackTrace,
        tag: 'SERVICE',
      );
      // Return the welcome route as fallback
      return '/';
    }
  }

  /// Inisialisasi Firebase
  static Future<void> initFirebase() async {
    try {
      await FirebaseService.instance.init();
      LoggerService.instance
          .i('✅ Firebase initialized successfully', tag: 'SERVICE');
    } catch (e, stackTrace) {
      LoggerService.instance.e(
        '❌ Error initializing Firebase',
        error: e,
        stackTrace: stackTrace,
        tag: 'SERVICE',
      );
      rethrow;
    }
  }

}
