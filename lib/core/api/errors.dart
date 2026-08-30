import 'package:dio/dio.dart';

/// Maps a [DioException] to a short, user-facing message.
///
/// Confirmed against a live instance (grimmory.mael.is, 2026-08-30): a 400
/// validation error has the shape
/// `{"details": ["field: message", ...], "message": "Validation error",
/// "status": 400, "timestamp": ...}`, while other error statuses (401, and
/// presumably 403/404/5xx, not individually confirmed) use plain Spring
/// Boot's default `{"timestamp", "status", "error", "path"}` — no `message`/
/// `details` to surface there, hence the generic per-status text below.
String friendlyApiError(Object error) {
  if (error is! DioException) return 'Something went wrong. Please try again.';

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Could not reach the server. Check your connection and try again.';
    case DioExceptionType.connectionError:
      return 'Could not connect to the server. Check the server URL and your network.';
    case DioExceptionType.badCertificate:
      return "The server's certificate could not be verified.";
    case DioExceptionType.cancel:
      return 'Request cancelled.';
    case DioExceptionType.badResponse:
      switch (error.response?.statusCode) {
        case 400:
          final details = _validationDetails(error.response?.data);
          if (details != null) return details;
          return 'That request was invalid. Please check your input and try again.';
        case 401:
          return 'Your session has expired. Please sign in again.';
        case 403:
          return "You don't have access to this.";
        case 404:
          return 'Not found.';
        case 500:
        case 502:
        case 503:
          return 'The server ran into a problem. Please try again shortly.';
        default:
          return 'Something went wrong. Please try again.';
      }
    case DioExceptionType.unknown:
    default:
      return 'Something went wrong. Please try again.';
  }
}

/// Extracts the human-readable part of a confirmed validation-error body —
/// each entry in `details` is already "field: message" (e.g. "username:
/// Username must not be blank"), so joining them is enough without further
/// parsing.
String? _validationDetails(Object? data) {
  if (data is! Map) return null;
  final details = data['details'];
  if (details is List && details.isNotEmpty) {
    return details.whereType<String>().join('\n');
  }
  final message = data['message'];
  return message is String ? message : null;
}
