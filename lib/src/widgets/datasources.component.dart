import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:markdown_widget/markdown_widget.dart';

@Preview(name: 'Sources', size: Size(300, 300))
Widget sources() {
  return DataSourcesComponent(
    sources: [
      DataSource(name: "ATM", link: "https://atm.it"),
      DataSource(name: "ATM/GIROMILANO", link: "https://giromilano.atm.it"),
    ],
  );
}

class DataSource {
  final String name;
  final String? link;

  const DataSource({required this.name, this.link});
}

class DataSourcesComponent extends StatelessWidget {
  final List<DataSource> sources;
  const DataSourcesComponent({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    String string = 'Origine dei dati: ';
    for (final source in sources) {
      if (source.link != null) {
        string += '[${source.name}](${source.link})';
      } else {
        string += source.name;
      }

      if (sources.indexOf(source) != sources.length - 1) {
        string += ', ';
      } else {
        string +=
            '- Ottenuti tramite [Onboard Project Server](https://github.com/onboard-project/server).';
      }
    }
    return Align(
      alignment: Alignment.center,
      child: MarkdownWidget(
        data: string,
        shrinkWrap: true,
        selectable: false,
        padding: EdgeInsets.zero,
        config: MarkdownConfig(
          configs: [
            PConfig(
              textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            LinkConfig(
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
