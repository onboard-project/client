import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:onboard_client/src/navigation/router.dart';
import 'package:onboard_client/src/utils/themeprovider/themeprovider.util.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure that the Flutter binding is initialized before any other Flutter code.
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isWindows) {
      doWhenWindowReady(() {
        appWindow.show();
      });
    } else if (Platform.isAndroid) {
      // Now it's safe to call platform-specific code.
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          //systemNavigationBarContrastEnforced: false,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemStatusBarContrastEnforced: false,
        ),
      );
    }
  }

  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const OnboardApp(),
    ),
  );
}

class OnboardApp extends StatelessWidget {
  const OnboardApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Onboard',
          theme: FlexThemeData.light(
            scheme: FlexScheme.shadViolet,
            fontFamily: 'DINNext',
            subThemesData: FlexSubThemesData(
              switchThumbSchemeColor: SchemeColor.primaryFixedDim,
              unselectedToggleIsColored: true,
              navigationBarIndicatorSchemeColor: SchemeColor.surfaceDim,
              navigationRailIndicatorSchemeColor: SchemeColor.surfaceDim,
            ),
          ),
          // The Mandy red, dark theme.
          darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.shadViolet,
            fontFamily: 'DINNext',
            subThemesData: FlexSubThemesData(
              switchThumbSchemeColor: SchemeColor.primaryFixedDim,
              unselectedToggleIsColored: true,
            ),
          ),
          // Use dark or light theme based on system setting.
          themeMode: themeProvider.themeMode,
          routerConfig: OnboardRouter.router,
        );
      },
    );
  }
}
