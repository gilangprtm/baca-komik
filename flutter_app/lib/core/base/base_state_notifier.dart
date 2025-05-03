
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/logger_service.dart';

/// A base class for all state notifiers in the application that extends [StateNotifier].
///
/// It also provides error handling and logging functionality.
abstract class BaseStateNotifier<T> extends StateNotifier<T> {
  /// Reference to the ProviderContainer, used to access other providers
  final Ref _ref;

  /// BuildContext if available, can be null
  BuildContext? _context;

  // Core services made available to all providers
  final LoggerService _logger = LoggerService.instance;

  // Flag to track if onReady has been called
  bool _onReadyCalled = false;

  // Expose services to subclasses
  LoggerService get logger => _logger;

  /// Access to the Ref for dependency injection
  Ref get ref => _ref;

  /// Returns the current [BuildContext] associated with this notifier.
  BuildContext? get context => _context;

  /// Gets the tag for logging, uses the class name by default.
  /// Subclasses can override this to provide a custom tag.
  String get logTag => runtimeType.toString();

  BaseStateNotifier(super.initialState, this._ref) {
    onInit();

    // Automatically schedule onReady like GetX does
    _scheduleOnReady();
  }

  /// Schedules onReady to be called automatically after a short delay
  /// This emulates GetX's behavior of automatically calling onReady
  void _scheduleOnReady() {
    // Use a microtask to delay the execution until after the current
    // execution cycle, which usually means after the widget has been built
    Future.microtask(() {
      if (mounted && !_onReadyCalled) {
        _onReadyCalled = true;
        onReady();
      }
    });
  }

  /// Sets the [BuildContext] associated with this notifier.
  ///
  /// This allows for context-based operations such as navigation or displaying dialogs.
  /// No longer automatically calls onReady as that's handled by _scheduleOnReady.
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Called when the notifier is first created.
  ///
  /// Use this method to initialize state or setup listeners.
  void onInit() {
    _logger.i('onInit called', tag: logTag);
    // To be overridden by subclasses
  }

  /// Called after [onInit] and when the widget is ready.
  ///
  /// Use this method to perform tasks that should happen after the UI is built,
  /// such as fetching initial data.
  void onReady() {
    _logger.i('onReady called', tag: logTag);
    // To be overridden by subclasses
  }

  // Add a flag to track if the notifier is being disposed
  bool _isDisposing = false;
  bool get isDisposing => _isDisposing;

  /// Called when the notifier is about to be disposed.
  ///
  /// Use this method to clean up resources such as listeners or subscriptions.
  @override
  void dispose() {
    _isDisposing = true;
    onClose();
    super.dispose();
  }

  /// Called before [dispose] to allow cleanup.
  ///
  /// This method is separated from [dispose] to allow subclasses to perform
  /// custom cleanup without needing to call super.dispose().
  void onClose() {
    _logger.i('onClose called - cleaning up resources', tag: logTag);
    // To be overridden by subclasses
  }

  /// Helper method for handling synchronous operations with error handling
  void run(String operationName, void Function() action) {
    _logger.d('Starting operation: $operationName', tag: logTag);

    try {
      action();
      _logger.d('Completed operation: $operationName', tag: logTag);
    } catch (e, stackTrace) {
      _logger.e(
        'Error in $operationName',
        error: e,
        stackTrace: stackTrace,
        tag: logTag,
      );

      rethrow;
    }
  }

  /// Helper method for handling synchronous operations with return value and error handling
  T2 runWithResult<T2>(String operationName, T2 Function() action) {
    _logger.d('Starting operation: $operationName', tag: logTag);

    try {
      final result = action();
      _logger.d('Completed operation: $operationName', tag: logTag);
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Error in $operationName',
        error: e,
        stackTrace: stackTrace,
        tag: logTag,
      );

      rethrow;
    }
  }

  /// Helper method for handling asynchronous operations with error handling
  Future<void> runAsync(
    String operationName,
    Future<void> Function() action,
  ) async {
    _logger.d('Starting async operation: $operationName', tag: logTag);

    try {
      // Run the action but check mounted status afterward
      await action();

      if (!mounted) {
        _logger.w(
          'Operation $operationName completed after disposal',
          tag: logTag,
        );
        return;
      }

      _logger.d('Completed async operation: $operationName', tag: logTag);
    } catch (e, stackTrace) {
      if (!mounted) {
        _logger.w('Error in $operationName after disposal: $e', tag: logTag);
        return;
      }

      _logger.e(
        'Error in async $operationName',
        error: e,
        stackTrace: stackTrace,
        tag: logTag,
      );

      rethrow;
    }
  }

  /// Helper method for handling asynchronous operations with return value and error handling
  Future<T2> runAsyncWithResult<T2>(
    String operationName,
    Future<T2> Function() action,
  ) async {
    _logger.d('Starting async operation: $operationName', tag: logTag);

    try {
      final result = await action();

      if (!mounted) {
        _logger.w(
          'Operation $operationName completed after disposal',
          tag: logTag,
        );
        return result;
      }

      _logger.d('Completed async operation: $operationName', tag: logTag);
      return result;
    } catch (e, stackTrace) {
      if (!mounted) {
        _logger.w('Error in $operationName after disposal: $e', tag: logTag);
        rethrow;
      }

      _logger.e(
        'Error in async $operationName',
        error: e,
        stackTrace: stackTrace,
        tag: logTag,
      );

      rethrow;
    }
  }
}

/// Extension to provide additional helper methods for working with Riverpod
extension AsyncValueX<T> on AsyncValue<T> {
  /// Helper to handle AsyncValue states with a single builder
  R whenOrElse<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function() loading,
  }) {
    return when(data: data, error: error, loading: loading);
  }
}
