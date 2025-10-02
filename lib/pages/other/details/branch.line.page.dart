import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/navigation/src/shellnav.sub.widget.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../src/utils/map/icons.map.util.dart';

class BranchedLineDetailsPage extends StatelessWidget {
  final String lineId;
  const BranchedLineDetailsPage({super.key, required this.lineId});

  Future<Line> fetchLineDetails() {
    return OnboardSDK.getLineDetails(lineId, all: true);
  }

  Future<bool> readFavoriteLines(String lineId) async {
    final prefs = await SharedPreferences.getInstance();
    List? favoriteLines = prefs.getStringList('favouriteLines');
    if (favoriteLines == null) {
      await prefs.setStringList('favouriteLines', []);
      favoriteLines = prefs.getStringList('favouriteLines');
    }
    return favoriteLines!.contains(lineId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchLineDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShellSubNavigation(child: LoadingComponent());
        } else if (snapshot.hasError || snapshot.data == null) {
          return ShellSubNavigation(
            child: ErrorComponent(error: snapshot.error ?? "Nessun dato"),
          );
        }

        final stops = snapshot.data!.stops;

        double mapCenterX = 0;
        for (var stop in stops) {
          mapCenterX += stop!.location.latitude;
        }
        mapCenterX /= stops.length;
        double mapCenterY = 0;
        for (var stop in stops) {
          mapCenterY += stop!.location.longitude;
        }
        mapCenterY /= stops.length;

        return ShellSubNavigation(
          initialPosition: LatLng(mapCenterX, mapCenterY),
          additionalLayers: [
            PolylineLayer(
              polylines: List.generate(snapshot.data!.geometry.length, (i) {
                return Polyline(
                  color: Colors.deepOrange,
                  strokeWidth: 5,

                  strokeJoin: StrokeJoin.bevel,
                  points: snapshot.data!.geometry[i]!
                      .equalize(8, smoothPath: true)
                      .coordinates,
                );
              }),
            ),
            MarkerLayer(
              markers: List.generate(stops.length, (i) {
                final stop = stops[i]!;
                return Marker(
                  height: 32,
                  width: 32,
                  point: LatLng(
                    stop.location.latitude,
                    stop.location.longitude,
                  ),
                  child: stop.type == StopType.surface
                      ? MapIcons.surfaceIcon(
                          navigates: true,
                          route: '/details/stops/${stop.id}',
                        )
                      : (stop.type == StopType.metro
                            ? MapIcons.metroIcon
                            : MapIcons.meLaIcon),
                );
              }),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(snapshot.data!.terminus),
                subtitle: Text(snapshot.data!.start),
                trailing: Text(snapshot.data!.headcode),
                leading: IconButton(
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go('/');
                  },
                  icon: Icon(opticalSize: 24, Symbols.arrow_back_rounded),
                ),
              ),

              ...MaterialCard.list(
                children: List.generate(snapshot.data!.stops.length, (i) {
                  final stop = snapshot.data!.stops[i];
                  return MaterialCard(
                    child: ListTile(
                      onTap: () {
                        context.push('/details/stops/${stop.id}');
                      },
                      title: Text(stop!.name),
                      leading: Text(stop.id),
                      trailing: Icon(
                        Symbols.chevron_right_rounded,
                        opticalSize: 24,
                      ),
                    ),
                  );
                }),
                context: context,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                titleAlignment: ListTileTitleAlignment.center,
                title: DataSourcesComponent(
                  sources: [
                    DataSource(
                      name: "ATM/GiroMilano",
                      link: "https://giromilano.atm.it",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
