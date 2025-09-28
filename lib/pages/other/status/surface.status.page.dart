import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/navigation/src/shellnav.sub.widget.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

class SurfaceStatusPage extends StatelessWidget {
  const SurfaceStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellSubNavigation(
      child: FutureBuilder(
        future: OnboardSDK.getSurfaceStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingComponent();
          } else if (snapshot.hasError || snapshot.data == null) {
            return ErrorComponent(error: snapshot.error ?? "Nessun dato");
          }
          String content = '';
          if (snapshot.data!.content.startsWith('---')) {
            content = snapshot.data!.content.substring(3);
          } else {
            content = snapshot.data!.content;
          }
          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(snapshot.data!.title),
                leading: IconButton(
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go('/');
                  },
                  icon: const Icon(opticalSize: 24, Symbols.arrow_back_rounded),
                ),
              ),
              MarkdownWidget(
                data: content,
                shrinkWrap: true,
                selectable: false,
                config: MarkdownConfig(
                  configs: [
                    LinkConfig(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
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
          );
        },
      ),
    );
  }
}
