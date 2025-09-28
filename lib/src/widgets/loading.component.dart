import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'cardlist.material.component.dart';

class LoadingComponent extends StatelessWidget {
  const LoadingComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          const <Widget>[
            LinearProgressIndicator(year2023: false),
            SizedBox(height: 12),
          ] +
          materialCardList(
            children: List.generate(
              3,
              (i) => Skeletonizer(
                child: MaterialCard(
                  child: ListTile(
                    title: Text("Fermata nascosta"),
                    subtitle: Text("00000"),
                    leading: Icon(
                      opticalSize: 24,
                      Symbols.directions_bus_rounded,
                    ),
                  ),
                ),
              ),
            ),
            context: context,
          ),
    );
  }
}
