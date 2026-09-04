import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/errors.dart';

DioException _badResponse(int status, [Object? data]) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  test('non-Dio errors get the generic message', () {
    expect(
      friendlyApiError(StateError('boom')),
      'Something went wrong. Please try again.',
    );
  });

  test('timeouts and connection errors are told apart', () {
    final options = RequestOptions(path: '/x');
    expect(
      friendlyApiError(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      ),
      contains('Check your connection'),
    );
    expect(
      friendlyApiError(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      ),
      contains('Check the server URL'),
    );
  });

  test('400 surfaces the server validation details verbatim, joined', () {
    expect(
      friendlyApiError(
        _badResponse(400, {
          'details': ['username: must not be blank', 'password: too short'],
          'message': 'Validation error',
          'status': 400,
        }),
      ),
      'username: must not be blank\npassword: too short',
    );
  });

  test('400 falls back to message, then to a generic line', () {
    expect(
      friendlyApiError(_badResponse(400, {'message': 'Bad book id'})),
      'Bad book id',
    );
    expect(
      friendlyApiError(_badResponse(400, {'details': <String>[]})),
      contains('request was invalid'),
    );
    expect(
      friendlyApiError(_badResponse(400, 'not json')),
      contains('request was invalid'),
    );
  });

  test('common statuses get their own wording', () {
    expect(
      friendlyApiError(_badResponse(401)),
      contains('session has expired'),
    );
    expect(friendlyApiError(_badResponse(403)), contains("don't have access"));
    expect(friendlyApiError(_badResponse(404)), 'Not found.');
    for (final status in [500, 502, 503]) {
      expect(
        friendlyApiError(_badResponse(status)),
        contains('server ran into'),
      );
    }
    expect(
      friendlyApiError(_badResponse(418)),
      contains('Something went wrong'),
    );
  });
}
