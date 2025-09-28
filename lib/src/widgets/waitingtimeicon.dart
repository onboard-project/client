import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

@Preview(name: 'Waiting Time Skeleton', size: Size(300, 300))
Widget mySampleText() {
  return Center(
    child: ListView(
      children: [
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(waitingTime: WaitingTime.none()),
          ),
        ),
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(
              waitingTime: WaitingTime(type: WaitingTimeType.reloading),
            ),
          ),
        ),
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(
              waitingTime: WaitingTime(type: WaitingTimeType.plus30),
            ),
          ),
        ),
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(
              waitingTime: WaitingTime(type: WaitingTimeType.time, value: 7),
            ),
          ),
        ),
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(
              waitingTime: WaitingTime(type: WaitingTimeType.arriving),
            ),
          ),
        ),
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(
              waitingTime: WaitingTime(type: WaitingTimeType.nightly),
            ),
          ),
        ),
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(
              waitingTime: WaitingTime(type: WaitingTimeType.noService),
            ),
          ),
        ),
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(
              waitingTime: WaitingTime(type: WaitingTimeType.suspended),
            ),
          ),
        ),
        MaterialCard(
          child: ListTile(
            title: Text("Helloworld"),
            trailing: const Waitingtimeicon(
              waitingTime: WaitingTime(type: WaitingTimeType.waiting),
            ),
          ),
        ),
      ],
    ),
  );
}

class Waitingtimeicon extends StatelessWidget {
  final WaitingTime waitingTime;
  const Waitingtimeicon({super.key, required this.waitingTime});

  @override
  Widget build(BuildContext context) {
    switch (waitingTime.type) {
      case WaitingTimeType.none:
        return _WaitingTimeSkeleton(
          startLineColor: Colors.grey,
          endLineColor: Colors.grey,
          boxColor: Colors.grey,
          animated: false,
          child: Text(
            "N/D",
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        );
      case WaitingTimeType.reloading:
        return _WaitingTimeSkeleton(
          startLineColor: Colors.grey,
          endLineColor: Colors.grey,
          boxColor: Colors.grey,
          animated: false,
          child: Icon(
            Symbols.sync,
            color: Colors.black,
            opticalSize: 16,
            size: 16,
          ),
        );
      case WaitingTimeType.plus30:
        return _WaitingTimeSkeleton(
          startLineColor: Theme.of(context).colorScheme.primary,
          endLineColor: Theme.of(context).colorScheme.primary,
          boxColor: Theme.of(context).colorScheme.primary,
          animated: false,
          child: Text(
            "+30",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
            ),
          ),
        );
      case WaitingTimeType.time:
        return _WaitingTimeSkeleton(
          startLineColor: Theme.of(context).colorScheme.primary,
          endLineColor: Theme.of(context).colorScheme.primary,
          boxColor: Theme.of(context).colorScheme.primary,
          animated: false,
          child: Text(
            waitingTime.value!.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
            ),
          ),
        );
      case WaitingTimeType.nightly:
        return _WaitingTimeSkeleton(
          startLineColor: Colors.blue[900]!,
          endLineColor: Colors.blue[900]!,
          boxColor: Colors.blue[900]!,
          animated: false,
          child: Icon(
            Symbols.dark_mode_rounded,
            color: Colors.white,
            fill: 1,
            opticalSize: 16,
            size: 16,
          ),
        );
      case WaitingTimeType.arriving:
        return _WaitingTimeSkeleton(
          startLineColor: Colors.deepOrange,
          endLineColor: Colors.deepOrange,
          boxColor: Colors.deepOrange,
          animated: true,
          child: Icon(
            Symbols.directions_bus_rounded,
            color: Colors.white,
            opticalSize: 16,
            size: 16,
          ),
        );
      case WaitingTimeType.waiting:
        return _WaitingTimeSkeleton(
          startLineColor: Colors.grey,
          endLineColor: Colors.grey,
          boxColor: Colors.grey,
          animated: false,
          child: Icon(
            Symbols.traffic_jam_rounded,
            color: Colors.black,
            opticalSize: 16,
            size: 16,
          ),
        );
      case WaitingTimeType.noService:
        return _WaitingTimeSkeleton(
          startLineColor: Colors.grey,
          endLineColor: Colors.grey,
          boxColor: Colors.grey,
          animated: false,
          child: Text(
            "N/A",
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        );
      case WaitingTimeType.suspended:
        return _WaitingTimeSkeleton(
          startLineColor: Colors.grey,
          endLineColor: Colors.grey,
          boxColor: Colors.grey,
          animated: false,
          child: Icon(
            Symbols.no_transfer_rounded,
            color: Colors.black,
            opticalSize: 16,
            size: 16,
          ),
        );
    }
  }
}

class _WaitingTimeSkeleton extends StatelessWidget {
  final Color startLineColor;
  final Color endLineColor;
  final Color boxColor;
  final Widget child;
  final bool animated;
  const _WaitingTimeSkeleton({
    required this.startLineColor,
    required this.endLineColor,
    required this.boxColor,
    required this.child,
    required this.animated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 7,
          width: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            color: startLineColor,
          ),
        ),
        SizedBox(height: 2),
        Stack(
          children: [
            if (animated)
              _BlinkingWidget(
                end: 45 / 30,
                start: 30 / 30,
                child: Container(
                  height: 20,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: boxColor.withAlpha((0.15 * 255).round()),
                  ),
                ),
              ),
            Container(
              height: 20,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: boxColor,
              ),
              child: Center(child: child),
            ),
          ],
        ),
        SizedBox(height: 2),
        Container(
          height: 7,
          width: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            color: endLineColor,
          ),
        ),
      ],
    );
  }
}

class _BlinkingWidget extends StatefulWidget {
  final double start;
  final double end;
  final Widget child;

  const _BlinkingWidget({
    super.key,
    required this.child,
    required this.start,
    required this.end,
  });

  @override
  State<_BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<_BlinkingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      //duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true, period: Duration(seconds: 1));
    _animation = Tween<double>(begin: widget.start, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}
