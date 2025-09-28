import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeneralMap extends StatelessWidget {
  final ValueNotifier<Map> variableLayers;
  final LatLng initialLocation;
  final double initialZoom;
  final List<Widget>? additionalLayers;
  final MapController controller;

  const GeneralMap({
    super.key,
    required this.variableLayers,
    required this.controller,
    required this.initialLocation,
    required this.initialZoom,
    this.additionalLayers,
  });

  // This helper will now extract all active layer widgets from the notifier's content
  List<Widget> _getDynamicLayers(Map data) {
    List<Widget> layers = [];
    for (final contentEntry in (data['content'] as List)) {
      // Assuming 'value' itself is a list of Widgets (e.g., [MarkerLayer(...) ] or [MarkerClusterLayerWidget(...) ])
      if (contentEntry['value'] is List<Widget>) {
        layers.addAll(contentEntry['value'] as List<Widget>);
      }
    }
    return layers;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      key: ValueKey(
        '$initialLocation-$initialZoom',
      ), // Add a key to force rebuild on changes
      mapController: controller,
      options: MapOptions(
        initialZoom: initialZoom,
        initialCenter: initialLocation,
        cameraConstraint: CameraConstraint.contain(
          bounds: LatLngBounds(
            LatLng(45.328962, 8.934631),
            LatLng(45.722420, 9.725475),
          ),
        ),
        maxZoom: 17.4,
        minZoom: 10,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onMapReady: () {
          // Explicitly move the map to the desired initial position and zoom
          // once the map is fully ready. This should override any defaults.
          controller.move(initialLocation, initialZoom);
        },
      ),
      children:
          <Widget>[
            TileLayer(
              minZoom: 16.4,
              maxZoom: 17.4,
              urlTemplate:
                  "https://raw.githubusercontent.com/onboard-project/maps/refs/heads/master/maps/${Theme.of(context).brightness.name}/{z}/{x}/{y}.png",
            ),
            TileLayer(
              tileDimension: 256,
              maxZoom: 16.4,
              fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.riccardodebellini.onboard',
              urlTemplate:
                  "https://raw.githubusercontent.com/onboard-project/maps/refs/heads/master/maps/${Theme.of(context).brightness.name}/{z}/{x}/{y}.png",
            ),

            // Fixed layers like surface stops can stay if they are always present
          ] +
          // This is the SINGLE dynamic part now
          [
            ValueListenableBuilder<Map>(
              valueListenable: variableLayers,
              builder: (context, data, child) {
                // This builder will rebuild whenever variableLayers changes.
                // It extracts ALL active layers from the 'content' list.
                return Stack(
                  children: _getDynamicLayers(data),
                ); // Use Stack to render multiple layers on top of each other
              },
            ),
            ValueListenableBuilder<Map>(
              valueListenable: variableLayers,
              builder: (context, data, child) {
                if (data['isSomethingLoading'] == true) {
                  return const Center(
                    child: CircularProgressIndicator(year2023: false),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ] +
          (additionalLayers ?? []),
    );
  }
}
