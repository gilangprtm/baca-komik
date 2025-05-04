import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../base/global_state.dart';
import 'logger_service.dart';

/// Service untuk mengelola inisialisasi dan fungsionalitas Firebase
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;
  FirebaseService._internal();

  final LoggerService _logger = LoggerService.instance;
  bool _isInitialized = false;
  late FirebaseRemoteConfig _remoteConfig;
  late FirebaseAnalytics _analytics;

  /// Cek apakah Firebase telah diinisialisasi
  bool get isInitialized => _isInitialized;
  
  /// Akses ke instance Firebase Remote Config
  FirebaseRemoteConfig get remoteConfig => _remoteConfig;
  
  /// Akses ke instance Firebase Analytics
  FirebaseAnalytics get analytics => _analytics;

  /// Inisialisasi Firebase
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Inisialisasi Firebase Core
      await _initFirebaseCore();

      // Inisialisasi Firebase Remote Config
      await _initFirebaseRemoteConfig();

      // Inisialisasi Firebase Analytics (jika dibutuhkan)
      await _initFirebaseAnalytics();

      // Inisialisasi Firebase Crashlytics (jika dibutuhkan)
      await _initFirebaseCrashlytics();

      _isInitialized = true;
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase Services', error: e, stackTrace: stackTrace, tag: 'Firebase');
      rethrow;
    }
  }

  /// Inisialisasi Firebase Core
  Future<void> _initFirebaseCore() async {
    try {
      await Firebase.initializeApp();
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase Core', error: e, stackTrace: stackTrace, tag: 'Firebase');
      rethrow;
    }
  }
  
  /// Inisialisasi Firebase Remote Config
  Future<void> _initFirebaseRemoteConfig() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // Set fetch settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
      
      // Update base URL in BaseState
      final apiUrl = _remoteConfig.getString('url_api');
      if (apiUrl.isNotEmpty) {
        GlobalState.baseUrl = apiUrl;
      }

      // GlobalState.baseUrl = "http://192.168.1.12:3000/api";
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase Remote Config', error: e, stackTrace: stackTrace, tag: 'Firebase');
      rethrow;
      // Don't rethrow, continue with default values
    }
  }

  /// Inisialisasi Firebase Analytics
  Future<void> _initFirebaseAnalytics() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics.setAnalyticsCollectionEnabled(true);
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase Analytics', error: e, stackTrace: stackTrace, tag: 'Firebase');
      // Don't rethrow, continue without analytics
    }
  }

  /// Inisialisasi Firebase Crashlytics
  Future<void> _initFirebaseCrashlytics() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      
      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase Crashlytics', error: e, stackTrace: stackTrace, tag: 'Firebase');
      // Don't rethrow, continue without crashlytics
    }
  }
  
  /// Log custom event to Firebase Analytics
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      if (_isInitialized) {
        await _analytics.logEvent(
          name: name,
          parameters: parameters,
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error logging event to Firebase Analytics', error: e, stackTrace: stackTrace, tag: 'Firebase');
    }
  }
  
  /// Refresh Remote Config values
  Future<void> refreshRemoteConfig() async {
    try {
      if (_isInitialized) {
        await _remoteConfig.fetchAndActivate();
        
        // Update base URL in BaseState
        final apiUrl = _remoteConfig.getString('url_api');
        if (apiUrl.isNotEmpty) {
          GlobalState.baseUrl = apiUrl;
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error refreshing Remote Config', error: e, stackTrace: stackTrace, tag: 'Firebase');
    }
  }

}
