import 'package:flutter/material.dart';

List<Widget> materialCardList({
  required List<Widget> children,
  required BuildContext context,
  bool usesKeys = false,
  int startKey = 0,
}) {
  return List.generate(children.length, (i) {
    double topRadius = 4;
    double bottomRadius = 4;
    EdgeInsets topMargin = EdgeInsets.only(top: 4);
    if (i == 0) {
      topMargin = EdgeInsets.only(top: 0);
      topRadius = 12;
    }
    if (i == children.length - 1) {
      bottomRadius = 12;
    }

    return Container(
      key: usesKeys ? Key('${i + startKey}') : null,
      margin: topMargin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topRadius),
          bottom: Radius.circular(bottomRadius),
        ),
      ),
      child: children[i],
    );
  });
}

class MaterialCard extends StatelessWidget {
  const MaterialCard({super.key, required this.child, this.isHighest = false})
    : isError = false;
  const MaterialCard.error({super.key, required this.child})
    : isError = true,
      isHighest = false;

  const MaterialCard.variable({
    super.key,

    required this.child,
    required this.isError,
    this.isHighest = false,
  });

  final bool isError;
  final Widget child;
  final bool isHighest;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: isError
            ? Theme.of(context).colorScheme.error
            : (isHighest
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.surfaceContainerHigh),
        child: DefaultTextStyle(
          style: TextStyle(
            color: isError
                ? Theme.of(context).colorScheme.onError
                : Theme.of(context).colorScheme.onSurface,
          ),
          child: child,
        ),
      ),
    );
  }
}
