import 'package:poligonic/component/poligon.dart';
import 'package:poligonic/core/colision_detector.dart';
import 'package:tuple/tuple.dart';

import 'poligon_struct.dart';
import 'hitbox.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';

class MasterPoligon extends PositionComponent{
  String role; // mutable in builders
  int dz; // mutable in builders
  bool _destroied = false;

  set destroied(bool v) {
    _rawPoligons.forEach((f) => f.destroied = v);
    _destroied = v;
  }

  final List<Poligon> _rawPoligons;
  final Hitbox hitbox;

  /// Principalmente usado para carregar do banco
  MasterPoligon(
    this.role,
    this._rawPoligons,
    this.hitbox
  );

  /// Principalmente usado para carregar na tela
  MasterPoligon.positioned(
    this.role,
    this._rawPoligons,
    this.hitbox,
    this.dz,
    Rect rect
  ) {
    _setPositionFromRect(this, rect);
    updateArea();
  }

  MasterPoligon.makeFromPoligons(
    List<Poligon> poligons,
    this.role,
    this.hitbox,
    this.dz,
    [Rect rect]
  ) :
  this._rawPoligons = _makeFromPoligons(poligons)
  {
    if(rect != null) {
      _setPositionFromRect(this, rect);
      updateArea();
    }
  }

  static void _setPositionFromRect(MasterPoligon m, Rect rect) {
    m.x = rect.left;
    m.y = rect.top;
    m.width = rect.width;
    m.height = rect.height;
  }

  static List<Poligon> _makeFromPoligons(List<Poligon> poligons, [Rect area]) {
    area ??= ColisionDetector(List<Offset>.from(
      poligons.map(
        (f) => f.structs.map(
          (f) => f.positionedRoutes)
        )
    )).area;

    return List<Poligon>.from(
      poligons.map((f) {
        // FIXME: tirar null
        Poligon.makeFromStruct(f.structs, null, f.role, f.dz, f.hitbox, area);
      })
    );
  }

  /// move as estruturas internas se baseando nas posiçoes atuais 
  /// e adicionando relativamente
  var _lastArea = Rect.fromLTRB(0,0,0,0);
  void updateArea() {
    var relativeX = x - _lastArea.left;
    var relativeY = y - _lastArea.top;
    var relativeWidth = width - _lastArea.width;
    var relativeHeight = height - _lastArea.height;
    _rawPoligons.forEach(
      (f) {
        f.setArea(
          Rect.fromLTWH(
          f.x + relativeX,
          f.y + relativeY,
          f.width + relativeWidth,
          f.height + relativeHeight
          )
        );
      });
    _lastArea = Rect.fromLTWH(x, y, width, height);

    // ja que a area atual é a mesma area do colisor do hitbox
    hitbox.colisionDetector.area = _lastArea;
  }

  /// Set position and call the [updatePosition]
  void setPosition(double x, double y) {
    this.x = x;
    this.y = y;
    updateArea();
  }

  /// Set area from a rect and call the [updatePosition]
  void setArea(Rect rect) {
    this.x = rect.left;
    this.y = rect.top;
    this.width = rect.width;
    this.height = rect.height;
    updateArea();
  }

  void setProportion(double proportion) {
    x -= width * proportion / 2;
    y -= height * proportion / 2;
    width += width * proportion / 2;
    height += height * proportion /2;
    updateArea(); 
  }


  @override
  void render(Canvas c) {
    _rawPoligons.forEach((f) => f.render(c));
  }

  @override
  void update(double t) {
    _rawPoligons.forEach((f) => f.update(t));
  }

  void rotate(double rotateDegree) {
    _rawPoligons.forEach((f) => f.angle = rotateDegree);
  }
  
  @override
  bool destroy() {
    return _destroied;
  }
}