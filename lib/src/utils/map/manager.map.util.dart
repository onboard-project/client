import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

import 'geolocator.map.util.dart';
import 'icons.map.util.dart';

//Full-Map Marker Layers
ValueNotifier<Map> fullMapLayers = ValueNotifier({
  'isSomethingLoading': false,
  'content':
      [], // This list will hold Maps, where each Map has an 'id' and 'value' (a List<Widget>)
});

//Small-Map Marker Layers
ValueNotifier<Map> smallMapLayers = ValueNotifier({
  'isSomethingLoading': false,
  'content':
      [], // This list will hold Maps, where each Map has an 'id' and 'value' (a List<Widget>)
});

//region addOrEditMapLayers
// Function to add or update a layer in the notifier
void addOrEditMapLayers({
  required Map content,
  required ValueNotifier<Map> map,
}) {
  // Function body
  List newContentList = List.from(map.value['content'] as List);

  // Remove the old content if it exists.
  newContentList.removeWhere((v) {
    return v['id'] == content['id'];
  });

  // Add the new or updated content.
  newContentList.add(content);

  map.value = {
    'isSomethingLoading': map.value['isSomethingLoading'],
    'content': newContentList,
  };
}
//endregion

//region removeMapLayers
// New function to remove a layer from the notifier
void removeMapLayers({required String id, required ValueNotifier<Map> map}) {
  List newContentList = List.from(map.value['content'] as List);
  newContentList.removeWhere((v) => v['id'] == id);

  map.value = {
    'isSomethingLoading': map.value['isSomethingLoading'],
    'content': newContentList,
  };
}
//endregion

//region displayLocation
Future<void> displayLocation({required ValueNotifier<Map> map}) async {
  map.value = {
    'isSomethingLoading': true,
    'content': List.from(map.value['content']),
  };
  LatLng? location;
  try {
    location = (await determinePosition()).toLatLng();
  } catch (e) {}

  if (location != null) {
    // The 'value' key here holds a List of Widgets for the map layer.
    // For a single MarkerLayer, it's a list containing that MarkerLayer.
    final content = {
      'id': 'userLocation',
      'value': [
        CurrentLocationLayer(
          // Customize the appearance of the location marker.
          style: LocationMarkerStyle(
            marker: const DefaultLocationMarker(
              child: Icon(
                opticalSize: 24,
                Symbols.navigation,
                color: Colors.white,
              ),
            ),
            markerSize: const Size(40, 40),
            markerDirection: MarkerDirection.heading,
            showAccuracyCircle: true,
            showHeadingSector: true,
            headingSectorColor: Colors.blue.withAlpha((0.8 * 255).round()),
            headingSectorRadius: 120,
            accuracyCircleColor: Colors.blue.withAlpha((0.1 * 255).round()),
          ),
        ),
      ],
    };
    addOrEditMapLayers(content: content, map: map);
  } else {
    // If location is null, you might want to explicitly remove the layer
    // or ensure it's not added if it wasn't there before.
    // To remove:
    removeMapLayers(id: 'userLocation', map: map);
  }
}
//endregion

//region showClickableMetroStopsLayer
Future<void> showClickableMetroStopsLayer({
  required ValueNotifier<Map> map,
}) async {
  map.value = {
    'isSomethingLoading': true,
    'content': List.from(map.value['content']),
  };

  List<Stop>? stops;
  try {
    stops = await OnboardSDK.getStops();
    stops = stops.where((s) {
      return s.type == StopType.metro;
    }).toList();
  } catch (e) {}

  if (stops != null && stops.isNotEmpty) {
    // Only add if there are stops
    final content = {
      'id': 'metroStops',
      'value': [
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            centerMarkerOnClick: false,
            maxClusterRadius: 200,
            size: const Size(32, 32),
            markers: List.generate(stops.length, (i) {
              final stop = stops![i];
              return Marker(
                height: 32,
                width: 32,
                point: LatLng(stop.location.latitude, stop.location.longitude),
                child: MapIcons.metroIcon,
              );
            }),
            builder: (context, markers) {
              return MapIcons.metroAnimatedDot;
            },
          ),
        ),
      ],
    };
    addOrEditMapLayers(content: content, map: map);
  } else {
    // If no metro stops are found, remove the metro stops layer
    removeMapLayers(id: 'metroStops', map: map);
  }

  map.value = {
    'isSomethingLoading': false,
    'content': List.from(map.value['content']),
  };
}
//endregion

//region showClickableMeLaStops
Future<void> showClickableMeLaStopsLayer({
  required ValueNotifier<Map> map,
}) async {
  map.value = {
    'isSomethingLoading': true,
    'content': List.from(map.value['content']),
  };

  List<Stop>? stops;
  try {
    stops = await OnboardSDK.getStops();
    stops = stops.where((s) {
      return s.type == StopType.mela;
    }).toList();
  } catch (e) {}
  if (stops != null && stops.isNotEmpty) {
    // Only add if there are stops
    final content = {
      'id': 'meLaStops',
      'value': [
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            centerMarkerOnClick: false,
            maxClusterRadius: 200,
            size: const Size(32, 32),
            markers: List.generate(stops.length, (i) {
              final stop = stops![i];
              return Marker(
                height: 32,
                width: 32,
                point: LatLng(stop.location.latitude, stop.location.longitude),
                child: MapIcons.meLaIcon,
              );
            }),
            builder: (context, markers) {
              return MapIcons.meLaAnimatedDot;
            },
          ),
        ),
      ],
    };
    addOrEditMapLayers(content: content, map: map);
  } else {
    // If no metro stops are found, remove the metro stops layer
    removeMapLayers(id: 'meLaStops', map: map);
  }
  map.value = {
    'isSomethingLoading': false,
    'content': List.from(map.value['content']),
  };
}
//endregion

//region showClickableSurfaceStops
Future<void> showClickableSurfaceStops(
  BuildContext context, {
  required ValueNotifier<Map> map,
}) async {
  map.value = {
    'isSomethingLoading': true,
    'content': List.from(map.value['content']),
  };

  List<Stop>? stops;
  try {
    stops = await OnboardSDK.getStops();
    stops = stops.where((s) {
      return s.type == StopType.surface;
    }).toList();
  } catch (e) {}

  if (stops != null && stops.isNotEmpty) {
    // Only add if there are stops
    final content = {
      'id': 'surfaceStops',
      'value': [
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            centerMarkerOnClick: false,
            maxClusterRadius: 200,
            size: const Size(32, 32),
            markers: List.generate(stops.length, (i) {
              final stop = stops![i];
              return Marker(
                height: 32,
                width: 32,
                point: LatLng(stop.location.latitude, stop.location.longitude),
                child: MapIcons.surfaceIcon(
                  navigates: true,
                  route: '/details/stops/${stop.id}',
                ),
              );
            }),
            builder: (context, markers) {
              return MapIcons.surfaceAnimatedDot;
            },
          ),
        ),
      ],
    };
    addOrEditMapLayers(content: content, map: map);
  } else {
    // If no metro stops are found, remove the metro stops layer
    removeMapLayers(id: 'surfaceStops', map: map);
  }
  map.value = {
    'isSomethingLoading': false,
    'content': List.from(map.value['content']),
  };
}

//endregion

//region showStaticMetroStopsLayer
Future<void> showStaticMetroStopsLayer({
  required ValueNotifier<Map> map,
}) async {
  map.value = {
    'isSomethingLoading': true,
    'content': List.from(map.value['content']),
  };

  List<Stop>? stops;
  try {
    stops = await OnboardSDK.getStops();
    stops = stops.where((s) {
      return s.type == StopType.metro;
    }).toList();
  } catch (e) {}

  if (stops != null && stops.isNotEmpty) {
    // Only add if there are stops
    final content = {
      'id': 'metroStops',
      'value': [
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            centerMarkerOnClick: false,
            maxClusterRadius: 200,
            size: const Size(32, 32),
            markers: List.generate(stops.length, (i) {
              final stop = stops![i];
              return Marker(
                height: 7,
                width: 7,
                point: LatLng(stop.location.latitude, stop.location.longitude),
                child: MapIcons.metroStaticDot,
              );
            }),
            builder: (context, markers) {
              return MapIcons.metroAnimatedDot;
            },
          ),
        ),
      ],
    };
    addOrEditMapLayers(content: content, map: map);
  } else {
    // If no metro stops are found, remove the metro stops layer
    removeMapLayers(id: 'metroStops', map: map);
  }

  map.value = {
    'isSomethingLoading': false,
    'content': List.from(map.value['content']),
  };
}

//endregion
//region showStaticMeLaStops
Future<void> showStaticMeLaStopsLayer({required ValueNotifier<Map> map}) async {
  map.value = {
    'isSomethingLoading': true,
    'content': List.from(map.value['content']),
  };

  List<Stop>? stops;
  try {
    stops = await OnboardSDK.getStops();
    stops = stops.where((s) {
      return s.type == StopType.mela;
    }).toList();
  } catch (e) {}

  if (stops != null && stops.isNotEmpty) {
    // Only add if there are stops
    final content = {
      'id': 'meLaStops',
      'value': [
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            centerMarkerOnClick: false,
            maxClusterRadius: 200,
            size: const Size(32, 32),
            markers: List.generate(stops.length, (i) {
              final stop = stops![i];
              return Marker(
                height: 7,
                width: 7,
                point: LatLng(stop.location.latitude, stop.location.longitude),
                child: MapIcons.meLaStaticDot,
              );
            }),
            builder: (context, markers) {
              return MapIcons.meLaAnimatedDot;
            },
          ),
        ),
      ],
    };
    addOrEditMapLayers(content: content, map: map);
  } else {
    // If no metro stops are found, remove the metro stops layer
    removeMapLayers(id: 'meLaStops', map: map);
  }
  map.value = {
    'isSomethingLoading': false,
    'content': List.from(map.value['content']),
  };
}

//endregion
//region showStaticSurfaceStops
Future<void> showStaticSurfaceStopsLayer(
  BuildContext context, {
  required ValueNotifier<Map> map,
}) async {
  map.value = {
    'isSomethingLoading': true,
    'content': List.from(map.value['content']),
  };

  List<Stop>? stops;
  try {
    stops = await OnboardSDK.getStops();
    stops = stops.where((s) {
      return s.type == StopType.surface;
    }).toList();
  } catch (e) {}

  if (stops != null && stops.isNotEmpty) {
    // Only add if there are stops
    final content = {
      'id': 'surfaceStops',
      'value': [
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            centerMarkerOnClick: false,
            maxClusterRadius: 200,
            size: const Size(32, 32),
            markers: List.generate(stops.length, (i) {
              final stop = stops![i];
              return Marker(
                height: 7,
                width: 7,
                point: LatLng(stop.location.latitude, stop.location.longitude),
                child: MapIcons.surfaceStaticDot,
              );
            }),
            builder: (context, markers) {
              return MapIcons.surfaceAnimatedDot;
            },
          ),
        ),
      ],
    };
    addOrEditMapLayers(content: content, map: map);
  } else {
    // If no metro stops are found, remove the metro stops layer
    removeMapLayers(id: 'surfaceStops', map: map);
  }
  map.value = {
    'isSomethingLoading': false,
    'content': List.from(map.value['content']),
  };
}

//endregion
