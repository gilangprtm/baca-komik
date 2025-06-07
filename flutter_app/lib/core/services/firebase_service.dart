import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../base/global_state.dart';
import 'logger_service.dart';

/// Service untuk mengelola inisialisasi dan fungsionalitas Firebase
class FirebaseService {
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
    } catch (e) {
      _logger.e('Error initializing Firebase Services',
          error: e, tag: 'Firebase');
      rethrow;
    }
  }

  /// Inisialisasi Firebase Core
  Future<void> _initFirebaseCore() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      _logger.e('Error initializing Firebase Core', error: e, tag: 'Firebase');
      rethrow;
    }
  }

  /// Inisialisasi Firebase Remote Config
  Future<void> _initFirebaseRemoteConfig() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set fetch settings with minimum cache expiration
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero, // Force fetch from server
      ));

      await _remoteConfig.fetchAndActivate();

      getApiUrl();
      await getUnderMaintenance();
    } catch (e) {
      _logger.e('Error initializing Firebase Remote Config',
          error: e, tag: 'Firebase');
    }
  }

  void getApiUrl() {
    // Update base URL in BaseState
    final apiUrl = _remoteConfig.getString('url_api');
    if (apiUrl.isNotEmpty) {
      GlobalState.baseUrl = apiUrl;
    }

    // GlobalState.baseUrl = "http://192.168.1.9:3000/api";
  }

  Future<void> getUnderMaintenance() async {
    try {
      GlobalState.packageInfo = await PackageInfo.fromPlatform();
      final remoteBuildNumber = _remoteConfig.getInt('build_number');
      final localBuildNumber =
          int.tryParse(GlobalState.packageInfo?.buildNumber ?? '0') ?? 0;

      GlobalState.underMaintenance = localBuildNumber > remoteBuildNumber;
    } catch (e) {
      GlobalState.underMaintenance = false;
    }
  }

  /// Inisialisasi Firebase Analytics
  Future<void> _initFirebaseAnalytics() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics.setAnalyticsCollectionEnabled(true);
    } catch (e) {
      _logger.e('Error initializing Firebase Analytics',
          error: e, tag: 'Firebase');
    }
  }

  /// Inisialisasi Firebase Crashlytics
  Future<void> _initFirebaseCrashlytics() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught errors to Crashlytics
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    } catch (e) {
      _logger.e('Error initializing Firebase Crashlytics',
          error: e, tag: 'Firebase');
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
    } catch (e) {
      _logger.e('Error logging event to Firebase Analytics',
          error: e, tag: 'Firebase');
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
    } catch (e) {
      _logger.e('Error refreshing Remote Config', error: e, tag: 'Firebase');
    }
  }
}
