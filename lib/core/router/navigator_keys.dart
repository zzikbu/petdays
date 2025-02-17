import 'package:flutter/material.dart';

class NavigatorKeys {
  static final root = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final homeTab = GlobalKey<NavigatorState>(debugLabel: 'homeTab');
  static final feedTab = GlobalKey<NavigatorState>(debugLabel: 'feedTab');
  static final myTab = GlobalKey<NavigatorState>(debugLabel: 'myTab');
}