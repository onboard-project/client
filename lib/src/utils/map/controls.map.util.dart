import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/utils/map/icons.map.util.dart';
import 'package:onboard_client/src/utils/map/manager.map.util.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';

import 'geolocator.map.util.dart';

class MapControls extends StatelessWidget {
  final ValueNotifier<Map> map;
  final MapController mapController;
  final bool showDirections;
  const MapControls({
    super.key,
    required this.map,
    required this.mapController,
    this.showDirections = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton.small(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          onPressed: () {
            showLayersDialog(context, map);
          },
          child: const Icon(opticalSize: 24, Symbols.layers_rounded),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          onPressed: () async {
            try {
              dynamic location = await determinePosition();
              location = LatLng(location.latitude, location.longitude);
              mapController.move(location, 16);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Impossibile localizzare"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: const Icon(opticalSize: 24, Symbols.my_location_rounded),
        ),
        const SizedBox(height: 12),
        if (showDirections)
          FloatingActionButton.small(
            elevation: 0,
            onPressed: () {
              context.go('/404');
            },
            child: const Icon(opticalSize: 24, Symbols.directions_rounded),
          ),
      ],
    );
  }
}

void showLayersDialog(BuildContext context, ValueNotifier<Map> map) {
  showModalBottomSheet(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.4,
      minHeight: MediaQuery.of(context).size.height * 0.4,
      maxWidth: 600,
    ),
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Symbols.layers_rounded, opticalSize: 24),
                title: Text("Scegli quali livelli sono mostrati sulla mappa"),
              ),

              ...MaterialCard.list(
                children: [
                  MaterialCard(
                    child: ListTile(
                      title: const Text("Fermate linee di superficie"),
                      leading: MapIcons.surfaceIcon(),
                      trailing: Switch(
                        value: (map.value['content'] as List).any(
                          (element) => element['id'] == 'surfaceStops',
                        ),
                        onChanged: (value) {
                          (map.value['content'] as List).any(
                                (element) => element['id'] == 'surfaceStops',
                              )
                              ? removeMapLayers(id: 'surfaceStops', map: map)
                              : ((map == fullMapLayers)
                                    ? showClickableSurfaceStops(
                                        context,
                                        map: map,
                                      )
                                    : showStaticSurfaceStopsLayer(
                                        context,
                                        map: map,
                                      ));
                          context.pop();
                        },
                      ),
                    ),
                  ),
                  MaterialCard(
                    child: ListTile(
                      title: const Text("Fermate linee metropolitane"),
                      leading: MapIcons.metroIcon,
                      trailing: Switch(
                        value: (map.value['content'] as List).any(
                          (element) => element['id'] == 'metroStops',
                        ),
                        onChanged: (value) {
                          (map.value['content'] as List).any(
                                (element) => element['id'] == 'metroStops',
                              )
                              ? removeMapLayers(id: 'metroStops', map: map)
                              : ((map == fullMapLayers)
                                    ? showClickableMetroStopsLayer(map: map)
                                    : showStaticMetroStopsLayer(map: map));
                          context.pop();
                        },
                      ),
                    ),
                  ),
                  MaterialCard(
                    child: ListTile(
                      title: const Text(
                        "Fermate MeLa (C.na Gobba - H. San Raffaele",
                      ),
                      leading: MapIcons.meLaIcon,
                      trailing: Switch(
                        value: (map.value['content'] as List).any(
                          (element) => element['id'] == 'meLaStops',
                        ),
                        onChanged: (value) {
                          (map.value['content'] as List).any(
                                (element) => element['id'] == 'meLaStops',
                              )
                              ? removeMapLayers(id: 'meLaStops', map: map)
                              : ((map == fullMapLayers)
                                    ? showClickableMeLaStopsLayer(map: map)
                                    : showStaticMeLaStopsLayer(map: map));
                          context.pop();
                        },
                      ),
                    ),
                  ),
                ],
                context: context,
              ),
            ],
          ),
        ),
      );
    },
  );
}
