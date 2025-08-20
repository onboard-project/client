import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:latlong2/latlong.dart';
import 'package:onboard_client/src/utils/geolocator/geolocator.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

class FullMap extends StatelessWidget {
  const FullMap({super.key});

  Future<Map> fetchData() async {
    final data = {};
    try {
      data['location'] = await determinePosition();
      data['location'] = (data['location'] as Position).toLatLng();
      data['no position'] = false;
    } catch (e) {
      print(e);
      data['location'] = LatLng(45.464664, 9.188540);
      data['no position'] = true;
    }

    try {
      data['all stops'] = await OnboardSDK.getStops();

      data['metro stops'] = (data['all stops'] as List<Stop>).where((s) {
        return s.type == StopType.metro;
      }).toList();
      data['mela stops'] = (data['all stops'] as List<Stop>).where((s) {
        return s.type == StopType.mela;
      }).toList();
      data['surface stops'] = (data['all stops'] as List<Stop>).where((s) {
        return s.type == StopType.surface;
      }).toList();

      print(data['surface stops'].toString());
    } catch (e) {
      print(e.toString());
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Errore:\n${snapshot.error.toString()}",
              textAlign: TextAlign.center,
            ),
          );
        }

        return FlutterMap(
          options: MapOptions(
            initialZoom: snapshot.data!['no position'] ? 13 : 15,
            initialCenter: snapshot.data!['location'],

            maxZoom: 17.4,
            minZoom: 10,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          children:
              <Widget>[
                TileLayer(
                  minZoom: 16.4,
                  maxZoom: 17.4,
                  urlTemplate:
                      "https://raw.githubusercontent.com/onboard-project/maps/refs/heads/master/maps/${MediaQuery.of(context).platformBrightness.name}/{z}/{x}/{y}.png",
                  // "http://localhost:8080/styles/${MediaQuery.of(context).platformBrightness.name}/256/{z}/{x}/{y}.png",
                ),
                TileLayer(
                  tileDimension: 256,
                  maxZoom: 16.4,
                  urlTemplate:
                      "https://raw.githubusercontent.com/onboard-project/maps/refs/heads/master/maps/${MediaQuery.of(context).platformBrightness.name}/{z}/{x}/{y}.png",
                  // "http://localhost:8080/styles/${MediaQuery.of(context).platformBrightness.name}/256/{z}/{x}/{y}@2x.png",
                ),
              ] +
              (snapshot.data!['no position']
                  ? <Widget>[]
                  : <Widget>[
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: snapshot.data!['location'],
                            child: CircleAvatar(),
                          ),
                        ],
                      ),
                    ]) +
              [
                MarkerLayer(
                  markers: List.generate(
                    (snapshot.data!['surface stops'] as List<Stop>).length,
                    (i) {
                      final stop =
                          (snapshot.data!['surface stops'] as List<Stop>)[i];
                      print(stop.id.toString());
                      return Marker(
                        height: 32,
                        width: 100,
                        point: LatLng(
                          stop.location.latitude,
                          stop.location.longitude,
                        ),
                        child: Container(
                          width: 100,
                          height: 32,
                          padding: EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.directions_bus_rounded, size: 12),
                              SizedBox(width: 12),
                              Text(
                                (snapshot.data!['surface stops']
                                        as List<Stop>)[i]
                                    .id,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
        );
      },
    );
  }
}
