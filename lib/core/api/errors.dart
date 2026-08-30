import 'package:dio/dio.dart';

/// Maps a [DioException] to a short, user-facing message.
///
/// Grimmory's actual error response shapes haven't been confirmed against a
/// live instance yet (M0) — this only handles the generic HTTP-status cases
/// every REST API shares. Extend with Grimmory-specific error bodies once
/// confirmed; don't assume any other self-hosted app's error branches apply.
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
