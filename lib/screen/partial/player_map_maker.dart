import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:poligonic/component/hitbox.dart';
import 'package:poligonic/component/player_map.dart';
import 'package:poligonic/component/poligon.dart';
import 'package:poligonic/component/poligon_struct.dart';
import 'package:poligonic/core/colision_detector.dart';
import 'package:poligonic/core/joystick.dart';
import 'package:poligonic/core/ring_selector.dart';
import 'package:tuple/tuple.dart';

class PlayerMapMaker extends PositionComponent {
  var _ring = RingSelector<Tuple2<Rect, Poligon>>();
  final Rect area;
  final Joystick joystick;

  ColisionDetector get colision => ColisionDetector.fromRect(area);
  Tuple2<Rect, Poligon> get selected => _ring.selected;
  List<Tuple2<Rect, Poligon>> get list => _ring.list;

  PlayerMapMaker.fromRect(this.area) :
    this.joystick = Joystick(1);

  @override
  void render(Canvas c) {
    _ring.list.forEach(
      (f) => f.item2.render(c)
    );
  }

  @override
  void update(double t) {
  }

  void tapInput(Offset action) {
    // FIXME: corrigir implementaçao da movimentaçao
    if(_ring.list.any((f) {
      return ColisionDetector.fromRect(f.item1).anyColision(action.dx, action.dy);
    })) {
      _ring.selected = _ring.list.firstWhere(
        (f) => ColisionDetector.fromRect(f.item1).anyColision(action.dx, action.dy));
      joystick.tapInput(action, Offset(_ring.selected.item1.left, _ring.selected.item1.right));
    }
  }

  void dragInput(Offset action) {
    if(_ring.selected != null) {
      var value = joystick.dragInput(action);
      _ring.selected.item2.setPosition(value.dx, value.dy);
    }
  }

  void killSelected() => _ring.removeSelected();

  void addStruct(Rect r, Poligon p) {
    p.setArea(r);
    _ring.add(Tuple2(r, p));
  }

  void moveSelected(int x) => _ring.moveIterator(x);

  void selectedToUp() => _ring.moveSelected(1);

  void selectedToDown() => _ring.moveSelected(-1);

  PlayerMap make() {
    return PlayerMap.positionedLoad(this.area, _ring.list);
  }
}