import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/utils/map/icons.map.util.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

import '../../src/utils/map/geolocator.map.util.dart';
import '../../src/widgets/cardlist.material.component.dart';

class AroundMePage extends StatelessWidget {
  const AroundMePage({super.key});

  Future<Map> getData() async {
    final data = {};
    try {
      data['UserLocation'] = await determinePosition().then(
        (value) => value.toLatLng(),
      );
    } catch (e) {
      return Future.error(e);
    }
    try {
      data['Stops'] = await OnboardSDK.getStops();
    } catch (e) {
      return Future.error(e);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingComponent();
        } else if (snapshot.hasError || snapshot.data == null) {
          return ErrorComponent(error: snapshot.error ?? "Nessun dato");
        }
        var stops = snapshot.data!['Stops']! as List<Stop>;
        final userLocation = snapshot.data!['UserLocation']! as LatLng;
        stops.sort((a, b) {
          return Distance()
              .as(LengthUnit.Meter, a.location, userLocation)
              .compareTo(
                Distance().as(LengthUnit.Meter, b.location, userLocation),
              );
        });
        stops = List.generate(15, (i) => stops[i]);
        return Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Fermate nelle vicinanze"),
              leading: Icon(opticalSize: 24, Symbols.near_me_rounded),
            ),
            ...MaterialCard.list(
              context: context,
              children: List.generate(stops.length, (i) {
                return MaterialCard(
                  child: ListTile(
                    onTap: () {
                      context.push('/details/stops/${stops[i].id}');
                    },
                    title: Text(stops[i].name),
                    leading: stops[i].type == StopType.surface
                        ? Text(stops[i].id)
                        : (stops[i].type == StopType.metro
                              ? MapIcons.metroIcon
                              : MapIcons.meLaIcon),
                    trailing: Text(
                      "${Distance().as(LengthUnit.Meter, stops[i].location, userLocation).round().toString()} m",
                    ),
                  ),
                );
              }),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              titleAlignment: ListTileTitleAlignment.center,
              title: DataSourcesComponent(
                sources: [
                  DataSource(
                    name: "dati statici ATM e NET /Agenzia TPL",
                    link: "https://www.agenziatpl.it/open-data/gtfs",
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
