import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:onboard_client/src/utils/router/router.dart';

void main() {
  runApp(const OnboardApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(600, 450);
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Onboard";
    win.show();
  });

  runApp(const OnboardApp());
}

class OnboardApp extends StatelessWidget {
  const OnboardApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Onboard ',
      theme: FlexThemeData.light(
        scheme: FlexScheme.shadViolet,
        fontFamily: 'DINNext',
      ),
      // The Mandy red, dark theme.
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.shadViolet,
        fontFamily: 'DINNext',
      ),
      // Use dark or light theme based on system setting.
      themeMode: ThemeMode.system,
      routerConfig: OnboardRouter.router,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        onMapEvent: (event) {
          print(event.camera.zoom.toString());
        },
        initialZoom: 13,
        initialCenter: LatLng(45.464664, 9.188540),
        //        maxZoom: 16.9,
        maxZoom: 16.9,
        minZoom: 10,
      ),
      children: [
        TileLayer(
          tileDimension: 256,
          maxZoom: 16.4,
          urlTemplate:
              //   "https://raw.githubusercontent.com/onboard-project/maps/refs/heads/master/maps/light/{z}/{x}/{y}.png",
              "http://localhost:8080/styles/${MediaQuery.of(context).platformBrightness.name}/256/{z}/{x}/{y}@2x.png",
        ),
      ],
    );
  }
}
