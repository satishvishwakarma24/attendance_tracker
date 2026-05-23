import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/theme/app_theme.dart';
import '/modules/common/module_responsive.dart';
import '/modules/common/widgets/app_nav_bar.dart';

/// Authenticated shell with drawer navigation and optional app bar actions.
class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final String currentRoute;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: text.titleLarge?.copyWith(fontSize: 18.sp),
        ),
        actions: actions,
      ),
      drawer: AppNavBar(currentRoute: currentRoute),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
