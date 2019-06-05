import 'dart:math';

import 'package:flame/components/component.dart';
import 'package:flame/svg.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:poligonic/component/player_map.dart';
import 'package:poligonic/component/poligon.dart';
import 'package:poligonic/component/poligon_struct.dart';
import 'package:poligonic/core/colision_wrapper.dart';
import 'package:poligonic/core/component_cache.dart';
import 'package:poligonic/core/gesture_wrapper.dart';
import 'package:poligonic/core/joystick.dart';
import 'package:poligonic/core/listbox.dart';
import 'package:poligonic/core/router_wrapper.dart';
import 'package:poligonic/factory/proportion_factory.dart';
import 'package:poligonic/factory/rect_factory.dart';
import 'package:poligonic/main.dart';
import 'package:poligonic/screen/master_poligon_builder.dart';
import 'package:poligonic/screen/partial/player_map_maker.dart';
import 'package:poligonic/screen/partial/poligon_maker.dart';
import 'package:poligonic/screen/poligon_struct_builder.dart';
import 'package:poligonic/component/point.dart';
import 'package:tuple/tuple.dart';

class BattleMap extends BaseGame with GestureWrapper{
  final Router _router;
  final Size screen;
  final _dragColisions = ColisionWrapper();
  final joystick = Joystick(1);
  final RouterWrapper _options;

  final Shoots shoots;

  final PlayerMap map;
  final Poligon ship;

  BattleMap(this._router, this.screen, this.map, this.ship, this._options) 
  : this.shoots = Shoots(Rect.fromLTWH(0, 0, screen.width / 80, screen.height / 80))
  {
    map.setArea(
      Rect.fromLTWH(
        0, 
        -screen.height * 2,
        screen.width, 
        screen.height * 2,
      )
    );
    ship.setArea(
      Rect.fromLTWH(
        screen.width - screen.width / 10, 
        screen.height - screen.height / 10,
        screen.width / 15, 
        screen.height / 15
      )
    );
  }

  @override
  void render(Canvas c) {
    map.render(c);
    ship.render(c);
    shoots.render(c);
  }

  // Sistema de movimento aleatorio da nave no menu
  static final Random _random = Random();
  static int _nextRandom() => 1 + _random.nextInt(10 - 1);
  var r1 = _nextRandom();
  var r2 = _nextRandom();

  bool troca = true;
  int ticktack = 0, ticktack2 = 0;
  @override
  void update(double t) {
    map.update(t);
    ship.update(t);
    shoots.update(t);
    map.setPosition(map.x, map.y + t * 50);
    if(map.y > map.height)
      _options.apply(_router);

    ticktack += 1;
    if(ticktack > 125) {
      shoots.add(Offset(ship.x + ship.width / 2, ship.y + ship.height / 3), true);
      ticktack = 0;
    }

    ticktack2 += 1;
    if(ticktack2 > 100) {
      map.positioned.forEach((f) {
        var hitbox = f.item2.hitbox.colisionDetector.area;
        shoots.add(Offset(hitbox.left + hitbox.width / 2, hitbox.bottom), false);
      });
      ticktack2 = 0;
    }

    shoots.shoots.forEach((f) {
      if(f.item2 == true) // tiro do aviao
        map.removePositioned(Offset(f.item1.dx, f.item1.dy));
      else // tiro da defesa
        if(ship.hitbox.colisionDetector.anyColision(f.item1.dx, f.item1.dy))
          _options.cancel(_router); // destroido
    });
  }

  @override
  void tapDown(Offset action) {
    joystick.tapInput(action, 
      Offset(
        ship.x,
        ship.y
      )
    );
  }

  Offset _v;
  @override
  void panUpdate(Offset action) {
    if(action != null)
      _v = joystick.dragInput(action);
      if(_v.dx >= 0 && _v.dx <= screen.width - ship.width)
        ship.setPosition(_v.dx, _v.dy);
  }
}

class Shoots extends PositionComponent {
  final Rect size;
  var shoots = List<Tuple3<Point, bool, MutableDouble>>();

  void add(Offset v, bool orientation) => shoots.add(Tuple3(Point.fromOffset(v), orientation, MutableDouble()));

  Shoots(this.size);

  @override
  void render(Canvas c) {
    shoots.forEach((f) {
      c.drawRect(Rect.fromLTWH(f.item1.dx, f.item1.dy, size.width, size.height), Paint()..color = Colors.red);
    });
  }

  @override
  void update(double t) {
    shoots.forEach((f) {
      if(f.item2)
        f.item1.dy -= t * 50;
      else
        f.item1.dy += t * 100;
      
      f.item3.value += t;
    });

    // remove balas muito antigas
    shoots = shoots.where((f) => !(f.item3.value > 10 && f.item2)).toList();
  }
}

class MutableDouble {
  double value = 0;
}