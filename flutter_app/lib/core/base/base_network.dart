import '../../data/datasource/network/db/dio_service.dart';
import '../services/logger_service.dart';
import '../services/performance_service.dart';

abstract class BaseRepository {
  final DioService dioService = DioService();
  final LoggerService logger = LoggerService.instance;
  String get logTag => runtimeType.toString();

  void logInfo(String message, {String? tag}) {
    logger.i(message, tag: tag ?? logTag);
  }

  void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
      tag: tag ?? logTag,
    );
  }

  void logDebug(String message, {String? tag}) {
    logger.d(message, tag: tag ?? logTag);
  }
}

abstract class BaseService {
  final LoggerService logger = LoggerService.instance;
  final PerformanceService performanceService = PerformanceService.instance;
  String get logTag => runtimeType.toString();

  Future<T> performanceAsync<T>({
    required String operationName,
    required Future<T> Function() function,
    String? tag,
  }) async {
    return performanceService.measureAsync(
      operationName,
      function,
      tag: tag ?? logTag,
    );
  }

  void performance({
    required String operationName,
    required dynamic Function() function,
    String? tag,
  }) {
    return performanceService.measure(
      operationName,
      function,
      tag: tag ?? logTag,
    );
  }
}
