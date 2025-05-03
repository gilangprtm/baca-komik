
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;

enum UrlType {
  baseUrl,
  customUrl, // For handling complete URLs
}

class HttpResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  HttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  dynamic get decodedBody => jsonDecode(body);

  Map<String, dynamic> get decodedBodyAsMap =>
      decodedBody as Map<String, dynamic>;

  List<dynamic> get decodedBodyAsList => decodedBody as List<dynamic>;
}

class HttpError implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  HttpError({
    required this.message,
    this.statusCode,
    this.body,
  });

  @override
  String toString() => message;
}

class HttpService {
  // Timeout duration used for all requests
  static const Duration defaultTimeout = Duration(seconds: 15);

  static String getBaseUrl(UrlType urlType) {
    switch (urlType) {
      case UrlType.baseUrl:
        return "https://pokeapi.co/api/v2";
      case UrlType.customUrl:
        return ""; // Empty string as we'll use the full path for custom URLs
    }
  }

  // Helper to construct the URL
  static String _constructUrl(String path, UrlType urlType, bool isFullUrl) {
    return isFullUrl ? path : getBaseUrl(urlType) + path;
  }

  // Helper to add authorization header
  static Future<Map<String, String>> _getHeaders(
      {Map<String, String>? headers}) async {
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization token
    final String? token = await _getToken();
    if (token != null) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }

    // Merge with custom headers if provided
    return headers != null ? {...defaultHeaders, ...headers} : defaultHeaders;
  }

  // GET request
  static Future<HttpResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    UrlType urlType = UrlType.baseUrl,
    bool isFullUrl = false,
  }) async {
    final url = Uri.parse(_constructUrl(path, urlType, isFullUrl))
        .replace(queryParameters: queryParameters);

    final requestHeaders = await _getHeaders(headers: headers);

    try {
      final response =
          await http.get(url, headers: requestHeaders).timeout(defaultTimeout);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  static Future<HttpResponse> post(
    String path, {
    dynamic data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    UrlType urlType = UrlType.baseUrl,
    bool isFullUrl = false,
  }) async {
    final url = Uri.parse(_constructUrl(path, urlType, isFullUrl))
        .replace(queryParameters: queryParameters);

    final requestHeaders = await _getHeaders(headers: headers);
    final String body = data != null ? jsonEncode(data) : '';

    try {
      final response = await http
          .post(url, headers: requestHeaders, body: body)
          .timeout(defaultTimeout);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  static Future<HttpResponse> put(
    String path, {
    dynamic data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    UrlType urlType = UrlType.baseUrl,
    bool isFullUrl = false,
  }) async {
    final url = Uri.parse(_constructUrl(path, urlType, isFullUrl))
        .replace(queryParameters: queryParameters);

    final requestHeaders = await _getHeaders(headers: headers);
    final String body = data != null ? jsonEncode(data) : '';

    try {
      final response = await http
          .put(url, headers: requestHeaders, body: body)
          .timeout(defaultTimeout);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  static Future<HttpResponse> patch(
    String path, {
    dynamic data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    UrlType urlType = UrlType.baseUrl,
    bool isFullUrl = false,
  }) async {
    final url = Uri.parse(_constructUrl(path, urlType, isFullUrl))
        .replace(queryParameters: queryParameters);

    final requestHeaders = await _getHeaders(headers: headers);
    final String body = data != null ? jsonEncode(data) : '';

    try {
      final response = await http
          .patch(url, headers: requestHeaders, body: body)
          .timeout(defaultTimeout);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  static Future<HttpResponse> delete(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    UrlType urlType = UrlType.baseUrl,
    bool isFullUrl = false,
  }) async {
    final url = Uri.parse(_constructUrl(path, urlType, isFullUrl))
        .replace(queryParameters: queryParameters);

    final requestHeaders = await _getHeaders(headers: headers);

    try {
      final response = await http
          .delete(url, headers: requestHeaders)
          .timeout(defaultTimeout);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST multipart request for form data
  static Future<HttpResponse> postFormData(
    String path, {
    required Map<String, dynamic> fields,
    List<http.MultipartFile>? files,
    Map<String, String>? queryParameters,
    UrlType urlType = UrlType.baseUrl,
    bool isFullUrl = false,
  }) async {
    final url = Uri.parse(_constructUrl(path, urlType, isFullUrl))
        .replace(queryParameters: queryParameters);

    var request = http.MultipartRequest('POST', url);

    // Add auth token
    final String? token = await _getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add form fields
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add files if provided
    if (files != null) {
      for (var file in files) {
        request.files.add(file);
      }
    }

    try {
      final streamedResponse = await request.send().timeout(defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT multipart request for form data
  static Future<HttpResponse> putFormData(
    String path, {
    required Map<String, dynamic> fields,
    List<http.MultipartFile>? files,
    Map<String, String>? queryParameters,
    UrlType urlType = UrlType.baseUrl,
    bool isFullUrl = false,
  }) async {
    final url = Uri.parse(_constructUrl(path, urlType, isFullUrl))
        .replace(queryParameters: queryParameters);

    var request = http.MultipartRequest('PUT', url);

    // Add auth token
    final String? token = await _getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add form fields
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add files if provided
    if (files != null) {
      for (var file in files) {
        request.files.add(file);
      }
    }

    try {
      final streamedResponse = await request.send().timeout(defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH multipart request for form data
  static Future<HttpResponse> patchFormData(
    String path, {
    required Map<String, dynamic> fields,
    List<http.MultipartFile>? files,
    Map<String, String>? queryParameters,
    UrlType urlType = UrlType.baseUrl,
    bool isFullUrl = false,
  }) async {
    final url = Uri.parse(_constructUrl(path, urlType, isFullUrl))
        .replace(queryParameters: queryParameters);

    var request = http.MultipartRequest('PATCH', url);

    // Add auth token
    final String? token = await _getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add form fields
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add files if provided
    if (files != null) {
      for (var file in files) {
        request.files.add(file);
      }
    }

    try {
      final streamedResponse = await request.send().timeout(defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Process the HTTP response
  static HttpResponse _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    // Check for HTTP errors
    if (statusCode >= 400) {
      final error = HttpError(
        message: 'HTTP Error: $statusCode',
        statusCode: statusCode,
        body: body,
      );

      // Handle token refresh for 401 errors
      if (statusCode == 401) {
        // Try to refresh token and retry the request
        _refreshToken();
      }

      throw error;
    }

    return HttpResponse(
      statusCode: statusCode,
      body: body,
      headers: response.headers,
    );
  }

  // Handle errors from HTTP requests
  static HttpError _handleError(dynamic error) {
    if (error is SocketException) {
      return HttpError(
        message: 'No Internet connection.',
      );
    } else if (error is FormatException) {
      return HttpError(
        message: 'Bad response format.',
      );
    } else if (error is TimeoutException) {
      return HttpError(
        message: 'Connection timeout, please try again later.',
      );
    } else if (error is HttpError) {
      return error;
    } else {
      return HttpError(
        message: 'Unknown error: ${error.toString()}',
      );
    }
  }

  // Get the authentication token
  static Future<String?> _getToken() async {
    // Implement token fetching logic here
    return 'your-token';
  }

  // Refresh the authentication token
  static Future<String?> _refreshToken() async {
    // Implement token refresh logic here
    return 'new-token';
  }
}
