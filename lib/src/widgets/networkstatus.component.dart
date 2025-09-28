import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

class NetworkStatusComponent extends StatelessWidget {
  const NetworkStatusComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: OnboardSDK.getMetroStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingComponent();
        } else if (snapshot.hasError || snapshot.data == null) {
          return ErrorComponent(error: snapshot.error ?? "Nessun dato");
        }
        final List<LineStatus> linesWithError = [];
        for (final line in snapshot.data!.lines) {
          if (!line.regular()) {
            linesWithError.add(line);
          }
        }
        return Column(
          children: materialCardList(
            // Spread the widgets from materialCardList into the ListView
            children: [
              MaterialCard.variable(
                isError: !snapshot.data!.regular(),
                child: ListTile(
                  onTap: (snapshot.data!.regular()
                      ? null
                      : () {
                          context.push('/status/metro', extra: snapshot.data!);
                        }),
                  title: const Text("Stato metro"),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:
                          (List<Widget>.generate(linesWithError.length, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    // Corrected: BoxBorder.all to Border.all
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(linesWithError[i].line.color),
                                ),
                                width: 10,
                                height: 20,
                              ),
                            );
                          })) +
                          (snapshot.data!.regular()
                              ? [const Text("Regolare")] // Added const
                              : <Widget>[
                                  const Icon(
                                    opticalSize: 24,
                                    Symbols.chevron_right_rounded,
                                  ),
                                ]),
                    ),
                  ),
                ),
              ),
              MaterialCard(
                child: ListTile(
                  onTap: () {
                    context.push('/status/surface');
                  },
                  title: Text("Informazioni in tempo reale"),
                  trailing: Icon(
                    Symbols.chevron_right_rounded,
                    opticalSize: 24,
                  ),
                ),
              ),
            ],
            context: context,
          ),
        );
      },
    );
  }
}
