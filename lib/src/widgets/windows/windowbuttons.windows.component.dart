import 'package:bitsdojo_window/bitsdojo_window.dart'
    show WindowButton, appWindow, WindowButtonContext;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

enum WindowsButtonType { minimize, maximize, close }

class WindowsWindowButton extends WindowButton {
  WindowsWindowButton({
    super.key,
    super.colors,
    required WindowsButtonType buttonType,
    VoidCallback? onPressed,
    bool? animate,
  }) : super(
         animate: animate ?? false,
         iconBuilder: (context) => _buildIcon(context, buttonType),
         onPressed: onPressed ?? _getOnPressed(buttonType),
       );
}

VoidCallback _getOnPressed(WindowsButtonType buttonType) {
  switch (buttonType) {
    case WindowsButtonType.minimize:
      return () => appWindow.minimize();
    case WindowsButtonType.maximize:
      return () => appWindow.maximizeOrRestore();
    case WindowsButtonType.close:
      return () => appWindow.close();
  }
}

Widget _buildIcon(WindowButtonContext context, WindowsButtonType buttonType) {
  IconData iconData;
  switch (buttonType) {
    case WindowsButtonType.minimize:
      iconData = FluentIcons.subtract_16_regular;
      break;
    case WindowsButtonType.maximize:
      iconData = appWindow.isMaximized
          ? FluentIcons.square_multiple_16_regular
          : FluentIcons.square_16_regular;
      break;
    case WindowsButtonType.close:
      iconData = FluentIcons.dismiss_16_regular;
      break;
  }
  return Icon(iconData, color: context.iconColor, size: 16);
}
