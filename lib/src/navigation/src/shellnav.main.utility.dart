import 'package:flutter/material.dart';

class ShellNavigationDest {
  /// The route public-facing name.
  final String text;
  /// The icon to be displayed.
  final Icon icon;
  /// The route to navigate to.
  final String route;
  /// The FAB to be displayed.
  final ShellNavigationFAB? fab;

  const ShellNavigationDest({
    required this.route,
    required this.text,
    required this.icon,
    this.fab,
  });
}

class ShellNavigationFAB {
  /// The function to be called when the FAB is pressed.
  final void Function()? onPressed;
  /// The icon to be displayed.
  final Icon icon;
  /// The label to be displayed.
  final String label;

  const ShellNavigationFAB({
    this.onPressed,
    required this.icon,
    required this.label,
  });
}