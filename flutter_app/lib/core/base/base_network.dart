
import '../../data/datasource/network/db/dio_service.dart';
import '../services/logger_service.dart';
import '../services/performance_service.dart';

abstract class BaseRepository {
  final DioService dioService = DioService();
  final LoggerService logger = LoggerService.instance;

  void logInfo(String message, {String? tag}) {
    logger.i(message, tag: tag ?? 'Repository');
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
      tag: tag ?? 'Repository',
    );
  }

  void logDebug(String message, {String? tag}) {
    logger.d(message, tag: tag ?? 'Repository');
  }
}

abstract class BaseService {
  final LoggerService logger = LoggerService.instance;
  final PerformanceService performanceService = PerformanceService.instance;

  Future<T> performanceAsync<T>({
    required String operationName,
    required Future<T> Function() function,
    String? tag,
  }) async {
    return performanceService.measureAsync(
      operationName,
      function,
      tag: tag ?? "Service",
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
      tag: tag ?? "Service",
    );
  }
}
