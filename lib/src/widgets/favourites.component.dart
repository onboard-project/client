import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_client/src/widgets/waitingtimeicon.dart';
import 'package:onboard_sdk/onboard_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

///The component to be hosted on the home page, fetches and displays the favourite lines and stops
class FavouritesComponent extends StatelessWidget {
  const FavouritesComponent({super.key});

  ///Gets the favourite lines and stops from the shared preferences
  Future<Map<String, List>> getFavourites() async {
    try {
      //Init shared preferences
      final sharedPreferences = await SharedPreferences.getInstance();

      //Read the favourites as a string representing their ID
      List favoriteLines =
          sharedPreferences.getStringList('favouriteLines') ?? [];
      List favoriteStops =
          sharedPreferences.getStringList('favouriteStops') ?? [];

      //Init the lists
      List<Line> lines = [];
      List<Stop> stops = [];

      //Get the details of the lines and stops
      for (final line in favoriteLines) {
        final lineDetails = await OnboardSDK.getLineDetails(line);
        lines.add(lineDetails);
      }
      for (final stop in favoriteStops) {
        final stopDetails = await OnboardSDK.getStopDetails(stop);
        stops.add(stopDetails);
      }

      return {'lines': lines, 'stops': stops};
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFavourites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingComponent();
        } else if (snapshot.hasError || snapshot.data == null) {
          return ErrorComponent(error: snapshot.error ?? "Nessun dato");
        }
        final lines = snapshot.data!['lines'];
        final stops = snapshot.data!['stops'];
        return Column(
          children: MaterialCard.list(
            children: [
              ...List.generate(stops!.length, (i) {
                return MaterialCard(
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          context.push('/details/stops/${stops[i].id}');
                        },
                        title: Text(stops[i].name),
                        trailing: Icon(
                          Symbols.chevron_right_rounded,
                          opticalSize: 24,
                        ),
                        leading: Text(stops[i].id),
                      ),
                      ...List.generate(stops[i].lines.length, (j) {
                        return ListTile(
                          onTap: () {
                            context.push(
                              '/details/lines/${stops[i].lines[j].id}',
                            );
                          },
                          title: Text(stops[i].lines[j].terminus),
                          leading: Text(stops[i].lines[j].headcode),
                          trailing: Waitingtimeicon(
                            waitingTime: stops[i].lines[j].waitingTime,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
              ...List.generate(lines!.length, (i) {
                return MaterialCard(
                  child: ListTile(
                    leading: Text(lines[i].headcode),
                    title: Text(lines[i].terminus),
                    subtitle: Text(lines[i].start),
                    trailing: Icon(
                      Symbols.chevron_right_rounded,
                      opticalSize: 24,
                    ),
                    onTap: () {
                      context.push('/details/lines/${lines[i].id}');
                    },
                  ),
                );
              }),
            ],
            context: context,
          ),
        );
      },
    );
  }
}
