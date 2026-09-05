import 'package:flutter/material.dart';

/// The title row every bottom sheet starts with — theme-styled (so it
/// follows text scaling and the theme) instead of the hard-coded 18 px each
/// sheet used to carry.
class SheetHeader extends StatelessWidget {
  const SheetHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
