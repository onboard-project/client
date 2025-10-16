import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A top-level shell that wraps the entire application to provide a custom
/// window title bar on Windows desktop platforms.
class SystemShell extends StatelessWidget {
  final Widget child;

  const SystemShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // On web and mobile, this shell does nothing and just returns the child.
    return AnnotatedRegion(
      value: FlexColorScheme.themedSystemNavigationBar(
        context,
        systemNavBarStyle: FlexSystemNavBarStyle.transparent,
        useDivider: false,
      ),
      child: (kIsWeb || !Platform.isWindows)
          ? child
          :
            // On Windows, it builds a Scaffold with a custom title bar.
            Scaffold(
              body: Column(
                children: [
                  _buildWindowsTitleBar(context),
                  // The rest of the app is expanded to fill the remaining space.
                  Expanded(child: child),
                ],
              ),
            ),
    );
  }

  /// Builds the custom title bar widget.
  Widget _buildWindowsTitleBar(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColors = WindowButtonColors(
      iconNormal: theme.colorScheme.onSurface,
      iconMouseDown: theme.colorScheme.onError,
      iconMouseOver: theme.colorScheme.onError,
      mouseDown: theme.colorScheme.error,
      mouseOver: theme.colorScheme.error,
    );
    final closeButtonColors = WindowButtonColors(
      iconNormal: theme.colorScheme.onSurface,
      iconMouseDown: theme.colorScheme.onError,
      iconMouseOver: theme.colorScheme.onError,
      mouseDown: theme.colorScheme.error,
      mouseOver: theme.colorScheme.error,
    );

    return SizedBox(
      height: 48,
      child: Container(
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox.square(
                dimension: 24,
                child: Image(
                  image: AssetImage(
                    'lib/assets/icons/LOGO.Onboard.rounded.png',
                  ),
                ),
              ),
              Text("Onboard", style: theme.textTheme.titleSmall),

              Expanded(child: MoveWindow()), // Allows the window to be dragged
              MinimizeWindowButton(colors: buttonColors),
              MaximizeWindowButton(colors: buttonColors),
              CloseWindowButton(colors: closeButtonColors),
            ],
          ),
        ),
      ),
    );
  }
}
