import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/utils/map/controls.map.util.dart';
import 'package:onboard_client/src/utils/map/map.util.dart';

import '../../utils/map/manager.map.util.dart';
import 'shellnav.main.utility.dart';

class ShellNavigation extends StatefulWidget {
  /// The navigation shell widget provided by GoRouter. This contains the page content.
  final StatefulNavigationShell navigationShell;

  /// The list of navigation destinations data.
  final List<ShellNavigationDest> pageData;

  /// The screen width breakpoint for switching between portrait and landscape layouts.
  final double smallBreakpoint;

  const ShellNavigation({
    super.key,
    required this.navigationShell,
    required this.pageData,
    this.smallBreakpoint = 600.0,
  });

  @override
  State<ShellNavigation> createState() => _ShellNavigationState();
}

class _ShellNavigationState extends State<ShellNavigation> {
  final MapController mapController = MapController();

  final DraggableScrollableController controller =
      DraggableScrollableController();

  late final Widget _persistentMap;

  @override
  void initState() {
    super.initState();
    _persistentMap = GeneralMap(
      initialLocation: LatLng(45.464664, 9.188540),
      initialZoom: 12,
      controller: mapController,
      variableLayers: fullMapLayers,
    );
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
    final currentPage = widget.pageData[widget.navigationShell.currentIndex];
    return Scaffold(
      primary: false,
      body: Stack(
        children: <Widget>[
          // 1. The persistent background map.
          _persistentMap,
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
              child: SearchBar(
                hintText: "Cerca fermate e linee",
                onTap: () {
                  context.push('/search');
                },
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surface,
                ),
                leading: const Icon(opticalSize: 24, Symbols.search_rounded),
                trailing: [
                  MenuAnchor(
                    builder: (context, controller, child) {
                      return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(
                          Symbols.more_horiz_rounded,
                          opticalSize: 24,
                        ),
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: const Icon(
                          Symbols.settings_rounded,
                          opticalSize: 24,
                        ),
                        onPressed: () {
                          context.push('/settings');
                        },
                        child: const Text('Impostazioni'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (controller.isAttached)
            if (controller.size <= 0.5)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 24, top: 80),
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
                        child: widget.navigationShell,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      // The floating action button changes based on the current page.
      floatingActionButton: currentPage.fab != null
          ? FloatingActionButton.extended(
              heroTag: UniqueKey(), // Prevent Hero animation conflicts
              onPressed: currentPage.fab!.onPressed,
              icon: currentPage.fab!.icon,
              label: Text(currentPage.fab!.label),
            )
          : null,
      // The bottom navigation bar that controls the page content.
      bottomNavigationBar: NavigationBar(
        maintainBottomViewPadding: true,
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Use the navigation shell to switch tabs, preserving state.
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: widget.pageData.map((page) {
          return NavigationDestination(icon: page.icon, label: page.text);
        }).toList(),
      ),
    );
  }

  /// Builds the UI for desktop/landscape screens with a NavigationRail and a stacked Card.
  Widget _buildLandscapeLayout(BuildContext context) {
    final currentPage = widget.pageData[widget.navigationShell.currentIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Row(
          children: [
            // 1. The persistent side navigation rail.
            NavigationRail(
              trailingAtBottom: true,
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  onPressed: () {
                    context.push('/settings');
                  },
                  icon: const Icon(Symbols.settings_rounded, opticalSize: 24),
                ),
              ),
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: (index) {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
              labelType: NavigationRailLabelType.all,
              leading: currentPage.fab != null
                  ? FloatingActionButton(
                      heroTag: UniqueKey(),
                      onPressed: currentPage.fab!.onPressed,
                      child: currentPage.fab!.icon,
                    )
                  : const SizedBox.shrink(),
              destinations: widget.pageData.map((page) {
                return NavigationRailDestination(
                  icon: page.icon,
                  label: Text(page.text),
                );
              }).toList(),
            ),

            // 2. The main content area.
            Expanded(
              child: Stack(
                children: [
                  // The background map.
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                      ),
                    ),
                    child: _persistentMap,
                  ),
                  Positioned(
                    top: 24,
                    right: 24,
                    child: MapControls(
                      showDirections: false,
                      map: fullMapLayers,
                      mapController: mapController,
                    ),
                  ),

                  // The "floating" card that displays the page content.
                  Positioned(
                    top: 36,
                    left: 36,
                    child: SizedBox(
                      width: 400,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SearchBar(
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 24),
                            ),
                            elevation: const WidgetStatePropertyAll(0),
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.surface,
                            ),
                            onTap: () {
                              context.push('/search');
                            },
                            leading: const Icon(
                              opticalSize: 24,
                              Symbols.search_rounded,
                            ),
                            hintText: "Cerca fermate e linee",
                            textInputAction: TextInputAction.search,
                          ),
                          Expanded(
                            child: Card(
                              elevation: 0,
                              child: CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      child: widget.navigationShell,
                                    ),
                                  ),
                                ],
                              ), // Page content goes here
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
