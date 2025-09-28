import 'package:flutter/material.dart';

/// A stateless widget that wraps the Material Design [SegmentedButton].
///
/// This class provides a simple wrapper around the [SegmentedButton] widget,
/// allowing for easy instantiation and configuration by passing all the
/// necessary parameters through its constructor.
class MaterialConnectedButtonGroup extends StatelessWidget {
  /// Creates a wrapper for a [SegmentedButton].
  ///
  /// All parameters are directly passed to the underlying [SegmentedButton] widget.
  const MaterialConnectedButtonGroup({
    super.key,
    required this.segments,
    required this.selected,
    this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = true,
    this.selectedIcon,
  });

  /// Descriptions of the segments in the button. [1]
  final List<ButtonSegment> segments;

  /// The set of [ButtonSegment.value]s that indicate which segments are selected. [1]
  final Set selected;

  /// The function that is called when the selection changes. [1]
  final void Function(Set)? onSelectionChanged;

  /// Determines if multiple segments can be selected at one time. [3]
  final bool multiSelectionEnabled;

  /// Determines if having no selected segments is allowed. [3]
  final bool emptySelectionAllowed;

  /// Determines if the [selectedIcon] is displayed on the selected segments. [1]
  final bool showSelectedIcon;

  /// An icon that is used to indicate a segment is selected. [1]
  final Widget? selectedIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(segments.length, (i) {
        return Padding(
          padding: EdgeInsets.only(right: (i != segments.length - 1) ? 2 : 0),

          child: FilledButton.icon(
            onPressed: segments[i].enabled
                ? () {
                    Set newSelection = {};

                    if (selected.contains(segments[i].value)) {
                      if (!emptySelectionAllowed && selected.length == 1) {
                        newSelection = selected;
                      }
                    } else {
                      if (multiSelectionEnabled) {
                        newSelection = {...selected, segments[i].value};
                      } else {
                        newSelection = {segments[i].value};
                      }
                    }

                    if (onSelectionChanged != null) {
                      onSelectionChanged!(newSelection);
                    }
                  }
                : null,
            style: ButtonStyle(
              iconSize: WidgetStatePropertyAll(20),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
              minimumSize: WidgetStatePropertyAll(Size(0, 40)),
              shape: WidgetStateProperty.resolveWith((_) {
                if (selected.isNotEmpty &&
                    selected.contains(segments[i].value)) {
                  return StadiumBorder();
                } else {
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      left: i == 0 ? Radius.circular(20) : Radius.circular(8),
                      right: i == segments.length - 1
                          ? Radius.circular(20)
                          : Radius.circular(8),
                    ), // No border radius for a connected look
                  );
                }
              }),

              backgroundColor: WidgetStateProperty.resolveWith((_) {
                if (!segments[i].enabled) {
                  return Theme.of(context).colorScheme.onSurface.withAlpha(10);
                } else if (selected.isNotEmpty &&
                    selected.contains(segments[i].value)) {
                  return Theme.of(context).colorScheme.primary;
                } else {
                  return Theme.of(context).colorScheme.surfaceContainerHighest;
                }
              }),
              foregroundColor: WidgetStateProperty.resolveWith((_) {
                if (selected.isNotEmpty &&
                    selected.contains(segments[i].value)) {
                  return Theme.of(context).colorScheme.onPrimary;
                } else {
                  return Theme.of(context).colorScheme.onSurfaceVariant;
                }
              }),
            ),

            label: segments[i].label ?? segments[i].icon!,
            icon: segments[i].label == null ? null : segments[i].icon,
          ),
        );
      }),
    );
  }
}

/*ButtonStyle(
        /*   shape: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return StadiumBorder();
          } else {
            return const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.zero, // No border radius for a connected look
            );
          }
        }),*/
        side: WidgetStatePropertyAll(BorderSide.none),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(
              context,
            ).colorScheme.primary; // Background color for the selected button
          }
          return Theme.of(context)
              .colorScheme
              .surfaceContainerHigh; // Transparent background for unselected buttons
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context)
                .colorScheme
                .onSurfaceVariant; // Text/icon color for the selected button
          }
          return Theme.of(
            context,
          ).colorScheme.onPrimary; // Text/icon color for unselected buttons
        }),
        elevation: WidgetStatePropertyAll(0), // No elevation
      )*/
