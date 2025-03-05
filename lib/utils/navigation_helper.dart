import 'package:flutter/material.dart';

class NavigationHelper {
  /*
  static push(BuildContext context, Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  static pushReplacement(BuildContext context, Widget widget) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }*/

  ///
  /// Navigate to next screen
  /// [rootNavigator] pass true to navigation on root context
  /// @return [Future] result of push method
  ///
  static Future<T> navigate<T extends Object>(
    BuildContext context,
    Widget widget, {
    bool rootNavigator = false,
    bool popSelf = false,
  }) {
    if (popSelf) {
      return Navigator.of(context, rootNavigator: rootNavigator)
          .pushReplacement(
        MaterialPageRoute(builder: (_) => widget),
      );
    }
    return Navigator.of(context, rootNavigator: rootNavigator).push(
      MaterialPageRoute(builder: (_) => widget),
    );
  }

  static Future<T> pushAndRemoveUntil<T extends Object>(
      BuildContext context, Widget widget) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => widget),
        (Route<dynamic> route) => false);
  }

  static Route createRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
