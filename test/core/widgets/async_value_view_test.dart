import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/widgets/async_value_view.dart';
import 'package:grimmory/core/widgets/empty_state.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders the data builder', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AsyncValueView<int>(
          value: const AsyncData(7),
          onRetry: () {},
          data: (n) => Text('value $n'),
        ),
      ),
    );
    expect(find.text('value 7'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows a spinner while loading', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AsyncValueView<int>(
          value: const AsyncLoading(),
          onRetry: () {},
          data: (n) => Text('value $n'),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('value'), findsNothing);
  });

  testWidgets('maps the error and wires Retry', (tester) async {
    var retries = 0;
    final options = RequestOptions(path: '/x');
    await tester.pumpWidget(
      _wrap(
        AsyncValueView<int>(
          value: AsyncError(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response(requestOptions: options, statusCode: 404),
            ),
            StackTrace.empty,
          ),
          onRetry: () => retries++,
          data: (n) => Text('value $n'),
        ),
      ),
    );
    expect(find.text('Not found.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('a fixed errorMessage replaces the mapped one', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AsyncValueView<int>(
          value: AsyncError(StateError('boom'), StackTrace.empty),
          errorMessage: 'Could not load bookmarks.',
          onRetry: () {},
          data: (n) => Text('value $n'),
        ),
      ),
    );
    expect(find.text('Could not load bookmarks.'), findsOneWidget);
  });

  testWidgets('EmptyState centres its message', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState('No books yet.')));
    expect(find.text('No books yet.'), findsOneWidget);
    expect(find.byType(Center), findsWidgets);
  });
}
