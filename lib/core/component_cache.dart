import 'dart:core';
import 'package:flame/components/component.dart';

class ComponentCache {
  static List<Component> _cache = List<Component>();
  static Component selected;

  static List<Component> get components {
    return _cache;
  }

  ComponentCache.add(Component c) {
    _cache.add(c);
  }

  static void remove(Component c) {
    _cache.removeWhere((f) => f == c);
  }

}