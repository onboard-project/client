import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class MapIcons {
  static Widget meLaIcon = const _MeLaIcon();
  static Widget metroIcon = const _MetroIcon();
  static Widget surfaceIcon({bool navigates = false, String? route}) {
    return _SurfaceIcon(navigates: navigates, route: route);
  }

  static Widget userLocationIcon = const _UserLocationIcon();
  static Widget meLaAnimatedDot = const _MeLaAnimatedDot();
  static Widget metroAnimatedDot = const _MetroAnimatedDot();
  static Widget surfaceAnimatedDot = const _SurfaceAnimatedDot();
  static Widget meLaStaticDot = const _MeLaStaticDot();
  static Widget metroStaticDot = const _MetroStaticDot();
  static Widget surfaceStaticDot = const _SurfaceStaticDot();
}

class _MeLaIcon extends StatelessWidget {
  const _MeLaIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,

      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          opticalSize: 16,
          Symbols.monorail_rounded,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MetroIcon extends StatelessWidget {
  const _MetroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,

      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "M",
          style: TextStyle(
            textBaseline: TextBaseline.ideographic,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SurfaceIcon extends StatelessWidget {
  final bool navigates;
  final String? route;
  const _SurfaceIcon({this.navigates = false, this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (navigates) context.push(route!);
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            opticalSize: 16,
            Symbols.directions_bus_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _UserLocationIcon extends StatelessWidget {
  const _UserLocationIcon();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _SurfaceAnimatedDot extends StatelessWidget {
  const _SurfaceAnimatedDot();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 32,
      child: Stack(
        children: [
          Center(
            child: _BlinkingWidget(
              start: 7 / 7,
              end: 32 / 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Center(
            child: _BlinkingWidget(
              start: 16 / 7,
              end: 7 / 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetroAnimatedDot extends StatelessWidget {
  const _MetroAnimatedDot();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 32,
      child: Stack(
        children: [
          Center(
            child: _BlinkingWidget(
              start: 7 / 7,
              end: 32 / 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.red[900]?.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Center(
            child: _BlinkingWidget(
              start: 16 / 7,
              end: 7 / 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeLaAnimatedDot extends StatelessWidget {
  const _MeLaAnimatedDot();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 32,
      child: Stack(
        children: [
          Center(
            child: _BlinkingWidget(
              start: 7 / 7,
              end: 32 / 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Center(
            child: _BlinkingWidget(
              start: 16 / 7,
              end: 7 / 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceStaticDot extends StatelessWidget {
  const _SurfaceStaticDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _MetroStaticDot extends StatelessWidget {
  const _MetroStaticDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _MeLaStaticDot extends StatelessWidget {
  const _MeLaStaticDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
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
