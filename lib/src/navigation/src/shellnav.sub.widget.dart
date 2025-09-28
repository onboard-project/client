import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:onboard_client/src/utils/map/controls.map.util.dart';
import 'package:onboard_client/src/utils/map/manager.map.util.dart';
import 'package:onboard_client/src/utils/map/map.util.dart';

class ShellSubNavigation extends StatefulWidget {
  /// The navigation shell widget provided by GoRouter. This contains the page content.
  final Widget child;

  /// The screen width breakpoint for switching between portrait and landscape layouts.
  final double smallBreakpoint;

  final LatLng initialPosition;
  final double initialZoom;
  final List<Widget>? additionalLayers;

  const ShellSubNavigation({
    super.key,
    required this.child,
    this.smallBreakpoint = 600.0,
    this.initialPosition = const LatLng(45.464664, 9.188540),
    this.initialZoom = 12,
    this.additionalLayers,
  });

  @override
  State<ShellSubNavigation> createState() => _ShellSubNavigationState();
}

class _ShellSubNavigationState extends State<ShellSubNavigation> {
  final MapController mapController = MapController();
  final DraggableScrollableController controller =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();

    // Add a listener to the controller to rebuild the widget when its properties change.
    controller.addListener(() {
      // Calling setState will trigger a rebuild, allowing the UI to update
      // based on the controller's new state (e.g., its size).
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed from the tree.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The main layout is a Column to accommodate the custom Windows title bar.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < widget.smallBreakpoint) {
          return _buildPortraitLayout(context);
        } else {
          return _buildLandscapeLayout(context);
        }
      },
    );
  }

  /// Builds the UI for mobile/portrait screens with a BottomNavigationBar and DraggableScrollableSheet.
  Widget _buildPortraitLayout(BuildContext context) {
    return Scaffold(
      primary: false,
      body: Stack(
        children: <Widget>[
          // 1. The persistent background map.
          GeneralMap(
            variableLayers: smallMapLayers,
            controller: mapController,
            initialLocation: widget.initialPosition,
            initialZoom: widget.initialZoom,
            additionalLayers: widget.additionalLayers,
          ),

          if (controller.isAttached)
            if (controller.size <= 0.5)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 24, top: 24),
                    child: MapControls(
                      showDirections: false,
                      map: smallMapLayers,
                      mapController: mapController,
                    ),
                  ),
                ),
              ),

          // 2. The draggable and snapping bottom sheet.
          DraggableScrollableSheet(
            controller: controller,

            initialChildSize: .4,
            // Default to 40%
            minChildSize: .2,
            // Can be dragged down to 20%
            maxChildSize: .8,
            // Can be dragged up to 80%
            snap: true,
            snapSizes: const [.4],
            // Ensures it snaps to the default size
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                // Use a CustomScrollView to combine slivers
                child: CustomScrollView(
                  // The controller from the sheet is attached here
                  controller: scrollController,
                  slivers: [
                    // Sliver #1: The Pinned Header (Our Handle)
                    // This stays visible at the top of the scroll view
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _DraggableHandleDelegate(),
                    ),

                    // Sliver #2: The Actual Page Content
                    // We use SliverToBoxAdapter to place a regular widget
                    // inside the CustomScrollView.
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the UI for desktop/landscape screens with a NavigationRail and a stacked Card.
  Widget _buildLandscapeLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * .3 > 400
                  ? MediaQuery.of(context).size.width * .3
                  : 400,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    GeneralMap(
                      variableLayers: smallMapLayers,
                      controller: mapController,
                      initialLocation: widget.initialPosition,
                      initialZoom: widget.initialZoom,
                      additionalLayers: widget.additionalLayers,
                    ),
                    Positioned(
                      top: 24,
                      right: 24,
                      child: MapControls(
                        showDirections: false,
                        map: smallMapLayers,
                        mapController: mapController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to build the pinned drag handle
class _DraggableHandleDelegate extends SliverPersistentHeaderDelegate {
  final double height = 28.0;

  _DraggableHandleDelegate();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // The handle's UI
    return SizedBox(
      height: height,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => height; // The handle is always the same size

  @override
  double get minExtent => height; // The handle is always the same size

  @override
  bool shouldRebuild(covariant _DraggableHandleDelegate oldDelegate) {
    return height != oldDelegate.height;
  }
}
