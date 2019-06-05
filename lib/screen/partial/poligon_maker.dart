import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:poligonic/component/hitbox.dart';
import 'package:poligonic/component/poligon.dart';
import 'package:poligonic/component/poligon_struct.dart';
import 'package:poligonic/core/colision_detector.dart';
import 'package:poligonic/core/joystick.dart';
import 'package:poligonic/core/ring_selector.dart';

class PoligonMaker extends PositionComponent {
  var _ring = RingSelector<PoligonStruct>();
  final Paint paint;
  final Rect area;
  final Joystick joystick;

  ColisionDetector get colision => ColisionDetector.fromRect(area);
  PoligonStruct get selected => _ring.selected;
  List<PoligonStruct> get list => _ring.list;

  PoligonMaker.fromRect(this.area, MaterialColor color) :
    this.paint = Paint()..color = color,
    this.joystick = Joystick(1);

  @override
  void render(Canvas c) {
    _ring.list.forEach(
      (f) => f.render(c)
    );
  }

  @override
  void update(double t) {
  }


  void tapInput(Offset action) {
    if(_ring.selected != null) {
      var internalArea = _ring.selected.internalArea;
      joystick.tapInput(action, Offset(internalArea.left, internalArea.top));
    }
  }

  void dragInput(Offset action) {
    if(_ring.selected != null) {
      var value = joystick.dragInput(action);
      var copy = _ring.selected.copy();
      copy.setPosition(value.dx, value.dy);
      if(copy.colision.anyOutside(colision))
        return;
      else
        _ring.selected.setPosition(value.dx, value.dy);
    }
  }

  void killSelected() => _ring.removeSelected();

  void addStruct(PoligonStruct p) {
    _ring.add(p);
  }

  void moveSelected(int x) => _ring.moveIterator(x);

  void selectedToUp() => _ring.moveSelected(1);

  void selectedToDown() => _ring.moveSelected(-1);
}

/*
    var rawPoligon = List<PoligonStruct>.from(
      _ring.list.map<PoligonStruct>((f) {
        var area = ColisionDetector(f.routes).area;
        return PoligonStruct(
          f.routes.map((f) => Offset(
            (f.dx - area.left) / area.width,
            (f.dy - area.top) / area.height)
          ),
          f.paint
        );
      })
    );

    return Poligon("", 0, rawPoligon, Hitbox(maxColision));
  }

  ColisionDetector get maxColision {
    var x = SplayTreeSet();
    var y = SplayTreeSet();
    _ring.list.forEach(
      (f) => f.routes.forEach(
        (f) {
          x.add(f.dx);
          y.add(f.dy);
        })
    );
    return ColisionDetector.fromLTRB(x.first, y.first, x.last, y.last);
*/